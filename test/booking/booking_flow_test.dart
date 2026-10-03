import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:eyadati_kit/core/engine/availability_service.dart';
import 'package:eyadati_kit/models/appointment_data.dart';
import 'package:eyadati_kit/models/schedule_slot_model.dart';
import 'package:eyadati_kit/repositories/appointment_repository.dart';

const patientId = '11111111-1111-4111-8111-111111111111';
const doctorId = '22222222-2222-4222-8222-222222222222';

const jsonHeaders = {'content-type': 'application/json'};

/// Minimal signed-looking JWT with a future exp (gotrue only decodes it).
String fakeJwt() {
  String b64(Map<String, Object> obj) => base64Url
      .encode(utf8.encode(jsonEncode(obj)))
      .replaceAll('=', '');
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  return '${b64({'alg': 'HS256', 'typ': 'JWT'})}.'
      '${b64({'sub': patientId, 'iat': now, 'exp': now + 3600, 'role': 'authenticated'})}.'
      'c2ln'; // base64url("sig") — gotrue decodes every segment
}

/// Fake gateway: serves the gotrue `/user` endpoint (for setSession) and
/// records `appointments` inserts, echoing the row back like PostgREST.
class FlowServer {
  final restRequests = <http.Request>[];
  final inserts = <Map<String, dynamic>>[];

  SupabaseClient build() {
    final mock = MockClient((request) async {
      if (request.url.path == '/auth/v1/user') {
        return http.Response(
          jsonEncode({
            'id': patientId,
            'aud': 'authenticated',
            'role': 'authenticated',
            'email': 'patient@test.dz',
            'created_at': '2026-01-01T00:00:00.000Z',
            'updated_at': '2026-01-01T00:00:00.000Z',
          }),
          200,
          headers: jsonHeaders,
          request: request,
        );
      }
      if (request.url.path == '/rest/v1/appointments' &&
          request.method == 'POST') {
        restRequests.add(request);
        final data = jsonDecode(request.body) as Map<String, dynamic>;
        inserts.add(data);
        final row = <String, dynamic>{
          'id': '33333333-3333-4333-8333-333333333333',
          'created_at': DateTime.now().toUtc().toIso8601String(),
          'attendance_status': null,
          ...data,
        };
        return http.Response(
          jsonEncode(row),
          201,
          headers: jsonHeaders,
          request: request,
        );
      }
      return http.Response(
        jsonEncode({'message': 'unhandled ${request.method} ${request.url}'}),
        404,
        headers: jsonHeaders,
        request: request,
      );
    });
    return SupabaseClient(
      'https://test-project.supabase.co',
      'anon-key',
      httpClient: mock,
    );
  }
}

/// Next date whose `weekday` matches (always at least tomorrow).
DateTime dateForWeekday(int weekday) {
  var d = DateTime.now();
  d = DateTime(d.year, d.month, d.day + 1);
  while (d.weekday != weekday) {
    d = d.add(const Duration(days: 1));
  }
  return d;
}

void main() {
  late FlowServer server;
  late SupabaseClient client;
  late AppointmentRepository repo;

  setUp(() {
    server = FlowServer();
    client = server.build();
    repo = AppointmentRepository(client);
  });

  test('end-to-end booking: session, engine pick, insert, slot re-check',
      () async {
    // 1. Patient signs in (fake session against the mocked auth endpoint).
    await client.auth.setSession('refresh-token-abc', accessToken: fakeJwt());
    expect(client.auth.currentUser?.id, patientId);

    // 2. Doctor works Monday 09:00-17:00 with a lunch break.
    final monday = dateForWeekday(1);
    final engine = AvailabilityService(
      scheduleSlots: [
        ScheduleSlot(
          id: 'slot-1',
          doctorId: doctorId,
          dayOfWeek: monday.weekday % 7,
          startTime: 540,
          endTime: 1020,
          breakStart: 720,
          breakEnd: 780,
        ),
      ],
    );

    final starts = engine.getValidStarts(monday, [], duration: 30);
    expect(starts, isNotEmpty);
    final chosen = starts.first;
    expect(chosen.minute, 540); // 09:00, first slot of the day

    // 3. Book it through the repository.
    final scheduledAt = DateTime(monday.year, monday.month, monday.day)
        .add(Duration(minutes: chosen.minute));
    final result = await repo.createAppointment(
      doctorId: doctorId,
      scheduledAt: scheduledAt,
      duration: 30,
      patientName: '<b>Amina</b>',
      patientPhone: '0555123456',
    );

    expect(result.isSuccess, isTrue, reason: result.error);
    expect(server.inserts, hasLength(1));

    // 4. The INSERT carries the contract: ids, status, sanitized snapshot.
    final insert = server.inserts.single;
    expect(insert['doctor_id'], doctorId);
    expect(insert['patient_id'], patientId);
    expect(insert['status'], 'upcoming');
    expect(insert['booking_type'], 'online');
    expect(insert['is_consultation'], false);
    expect(insert['duration'], 30);
    expect(insert['patient_name_snapshot'], 'Amina'); // tags stripped
    expect(insert['patient_phone_snapshot'], '0555123456');
    expect(
      DateTime.parse(insert['scheduled_at'] as String).toUtc(),
      scheduledAt.toUtc(),
    );

    // 5. The booked slot disappears from availability.
    final apt = result.appointment!;
    final booked = AppointmentData(
      id: apt.id,
      startTime: apt.scheduledAt,
      endTime: apt.scheduledAt.add(const Duration(minutes: 30)),
      patientName: 'Amina',
      status: 'upcoming',
    );

    expect(
      engine.isTimeAvailable(monday, chosen.minute, 30, [booked]),
      isFalse,
    );
    final after = engine.getValidStarts(monday, [booked], duration: 30);
    expect(after.map((s) => s.minute), isNot(contains(chosen.minute)));
    expect(after, isNotEmpty); // the rest of the day is still bookable
  });

  test('invalid doctor id fails before any insert', () async {
    await client.auth.setSession('refresh-token-abc', accessToken: fakeJwt());

    final result = await repo.createAppointment(
      doctorId: 'not-a-uuid',
      scheduledAt: DateTime.now().add(const Duration(days: 1)),
      duration: 30,
      patientName: 'Amina',
    );

    expect(result.isSuccess, isFalse);
    expect(result.error, 'Invalid doctor ID');
    expect(server.restRequests, isEmpty);
    expect(server.inserts, isEmpty);
  });

  test('past dates fail validation before any insert', () async {
    await client.auth.setSession('refresh-token-abc', accessToken: fakeJwt());

    final result = await repo.createAppointment(
      doctorId: doctorId,
      scheduledAt: DateTime.now().subtract(const Duration(hours: 2)),
      duration: 30,
      patientName: 'Amina',
    );

    expect(result.isSuccess, isFalse);
    expect(result.error, 'Cannot book appointments in the past');
    expect(server.restRequests, isEmpty);
  });

  test('without a session booking is rejected up front', () async {
    final result = await repo.createAppointment(
      doctorId: doctorId,
      scheduledAt: DateTime.now().add(const Duration(days: 1)),
      duration: 30,
      patientName: 'Amina',
    );

    expect(result.isSuccess, isFalse);
    expect(result.error, 'User not authenticated');
    expect(server.restRequests, isEmpty);
  });
}
