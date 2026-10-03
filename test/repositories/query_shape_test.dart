import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:eyadati_kit/core/utils/pagination.dart';
import 'package:eyadati_kit/repositories/appointment_repository.dart';
import 'package:eyadati_kit/repositories/doctor_repository.dart';
import 'package:eyadati_kit/repositories/favorite_repository.dart';
import 'package:eyadati_kit/repositories/schedule_repository.dart';

/// Captures every outgoing REST call and replays a canned response, so
/// tests can pin the exact PostgREST contract (table, method, filters,
/// ordering, paging) without a live database.
class RestCapture {
  final requests = <http.Request>[];
  String responseBody = '[]';
  int status = 200;

  SupabaseClient build() {
    final mock = MockClient((request) async {
      requests.add(request);
      return http.Response(
        responseBody,
        status,
        headers: {'content-type': 'application/json'},
        // postgrest reads response.request! when parsing; MockClient does
        // not attach it for us.
        request: request,
      );
    });
    return SupabaseClient(
      'https://test-project.supabase.co',
      'anon-key',
      httpClient: mock,
    );
  }

  http.Request get single => requests.single;
}

void main() {
  late RestCapture capture;

  setUp(() => capture = RestCapture());

  group('ScheduleRepository', () {
    test('getDoctorSchedule queries doctor_schedule with ordered filters',
        () async {
      capture.responseBody = jsonEncode([
        {
          'id': 's1',
          'doctor_id': 'doc-1',
          'day_of_week': 1,
          'start_time': '09:00:00',
          'end_time': '17:00:00',
          'is_active': true,
        },
      ]);

      final slots = await ScheduleRepository(capture.build())
          .getDoctorSchedule('doc-1');

      final req = capture.single;
      expect(req.method, 'GET');
      expect(req.url.path, '/rest/v1/doctor_schedule');
      expect(req.url.queryParameters['select'], '*');
      expect(req.url.queryParameters['doctor_id'], 'eq.doc-1');
      expect(req.url.queryParameters['is_active'], 'eq.true');
      expect(req.url.queryParameters['order'],
          'day_of_week.desc.nullslast,start_time.desc.nullslast');

      expect(slots, hasLength(1));
      expect(slots.single.startTime, 540); // 09:00:00 -> minutes
      expect(slots.single.endTime, 1020); // 17:00:00
      expect(slots.single.isActive, isTrue);
    });

    test('getDoctorScheduleByDay narrows by day_of_week', () async {
      final slots = await ScheduleRepository(capture.build())
          .getDoctorScheduleByDay('doc-1', 3);

      final req = capture.single;
      expect(req.method, 'GET');
      expect(req.url.queryParameters['doctor_id'], 'eq.doc-1');
      expect(req.url.queryParameters['day_of_week'], 'eq.3');
      expect(req.url.queryParameters['is_active'], 'eq.true');
      expect(req.url.queryParameters['order'], 'start_time.desc.nullslast');
      expect(slots, isEmpty);
    });

    test('createScheduleSlot POSTs the slot payload', () async {
      capture.responseBody = jsonEncode({
        'id': 's2',
        'doctor_id': 'doc-1',
        'day_of_week': 2,
        'start_time': '10:00:00',
        'end_time': '16:00:00',
        'is_active': true,
      });

      final slot = await ScheduleRepository(capture.build()).createScheduleSlot(
        doctorId: 'doc-1',
        dayOfWeek: 2,
        startTime: '10:00:00',
        endTime: '16:00:00',
      );

      final req = capture.single;
      expect(req.method, 'POST');
      expect(req.url.path, '/rest/v1/doctor_schedule');

      final body = jsonDecode(req.body) as Map<String, dynamic>;
      expect(body['doctor_id'], 'doc-1');
      expect(body['day_of_week'], 2);
      expect(body['start_time'], '10:00:00');
      expect(body['end_time'], '16:00:00');

      expect(slot.id, 's2');
      expect(slot.startTime, 600);
    });
  });

  group('DoctorRepository.getActiveDoctors', () {
    test('base query pins table, flags, and ordering', () async {
      final doctors = await DoctorRepository(capture.build()).getActiveDoctors();

      final req = capture.single;
      expect(req.method, 'GET');
      expect(req.url.path, '/rest/v1/doctors');
      expect(req.url.queryParameters['select'], '*');
      expect(req.url.queryParameters['manual_pause'], 'eq.false');
      expect(req.url.queryParameters['is_test'], 'eq.false');
      expect(req.url.queryParameters['order'], 'created_at.desc.nullslast');
      expect(doctors, isEmpty);
    });

    test('specialty and city become ilike filters', () async {
      await DoctorRepository(capture.build())
          .getActiveDoctors(specialty: 'Cardiology', city: 'Alger');

      final params = capture.single.url.queryParameters;
      expect(params['specialty'], 'ilike.%Cardiology%');
      expect(params['city'], 'ilike.%Alger%');
    });

    test('searchQuery is sanitized before it reaches the or filter', () async {
      await DoctorRepository(capture.build())
          .getActiveDoctors(searchQuery: '<b>heart</b>');

      final or = capture.single.url.queryParameters['or']!;
      expect(
        or,
        '(specialty.ilike.%heart%,address.ilike.%heart%,'
        'bio.ilike.%heart%)',
      );
      expect(or.contains('<'), isFalse);
      expect(or.contains('>'), isFalse);
    });

    test('explicit limit/offset map to PostgREST range params', () async {
      // Note: page/pageSize alone does NOT set hasPagination in
      // PaginationParams, so only explicit limit/offset reach the server.
      await DoctorRepository(capture.build()).getActiveDoctors(
        pagination: const PaginationParams(limit: 10, offset: 20),
      );

      final params = capture.single.url.queryParameters;
      expect(params['order'], 'created_at.desc.nullslast');
      expect(params['offset'], '20');
      expect(params['limit'], '10');
    });

    test('invalid doctor id short-circuits without any HTTP call', () async {
      final doctor =
          await DoctorRepository(capture.build()).getDoctor('not-a-uuid');
      expect(doctor, isNull);
      expect(capture.requests, isEmpty);
    });
  });

  group('auth guards', () {
    test('getPatientAppointments without a session makes no HTTP call',
        () async {
      final appointments = await AppointmentRepository(capture.build())
          .getPatientAppointments();
      expect(appointments, isEmpty);
      expect(capture.requests, isEmpty);
    });

    test('getFavorites without a session makes no HTTP call', () async {
      final favorites =
          await FavoriteRepository(capture.build()).getFavorites();
      expect(favorites, isEmpty);
      expect(capture.requests, isEmpty);
    });
  });
}
