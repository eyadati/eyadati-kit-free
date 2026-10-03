import 'package:flutter_test/flutter_test.dart';

import 'package:eyadati_kit/models/schedule_slot_model.dart';

void main() {
  Map<String, dynamic> dbRow({
    Object? start = '09:00:00',
    Object? end = '17:30:00',
    Object? breakStart = '12:00:00',
    Object? breakEnd = '13:00:00',
    bool? isActive,
    String? createdAt = '2026-01-15T08:00:00Z',
  }) {
    return {
      'id': 'slot-1',
      'doctor_id': 'doc-1',
      'day_of_week': 1,
      'start_time': start,
      'end_time': end,
      'break_start': breakStart,
      'break_end': breakEnd,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      'updated_at': null,
    };
  }

  group('DaySchedule.fromDbMap', () {
    test('parses Postgres time strings into minutes', () {
      final s = DaySchedule.fromDbMap(dbRow());
      expect(s.id, 'slot-1');
      expect(s.doctorId, 'doc-1');
      expect(s.dayOfWeek, 1);
      expect(s.startTime, 540); // 09:00:00
      expect(s.endTime, 1050); // 17:30:00
      expect(s.breakStart, 720); // 12:00:00
      expect(s.breakEnd, 780); // 13:00:00
      expect(s.isActive, isTrue); // default when column absent
      expect(s.createdAt, DateTime.parse('2026-01-15T08:00:00Z'));
      expect(s.updatedAt, isNull);
      expect(s.hasBreak, isTrue);
    });

    test('accepts integer minutes and null break', () {
      final s = DaySchedule.fromDbMap(dbRow(
        start: 540,
        end: 1020,
        breakStart: null,
        breakEnd: null,
        isActive: false,
        createdAt: null,
      ));
      expect(s.startTime, 540);
      expect(s.endTime, 1020);
      expect(s.breakStart, isNull);
      expect(s.breakEnd, isNull);
      expect(s.hasBreak, isFalse);
      expect(s.isActive, isFalse);
      expect(s.createdAt, isNull);
    });

    test('fromJson behaves like fromDbMap', () {
      final s = DaySchedule.fromJson(dbRow());
      expect(s.startTime, 540);
      expect(s.breakEnd, 780);
    });
  });

  group('toJson / copyWith', () {
    test('round-trips through fromDbMap', () {
      final original = DaySchedule.fromDbMap(dbRow());
      final parsed = DaySchedule.fromDbMap(original.toJson());
      expect(parsed.id, original.id);
      expect(parsed.doctorId, original.doctorId);
      expect(parsed.dayOfWeek, original.dayOfWeek);
      expect(parsed.startTime, original.startTime);
      expect(parsed.endTime, original.endTime);
      expect(parsed.breakStart, original.breakStart);
      expect(parsed.breakEnd, original.breakEnd);
      expect(parsed.isActive, original.isActive);
    });

    test('omits null break keys', () {
      final s = DaySchedule.fromDbMap(dbRow(breakStart: null, breakEnd: null));
      final json = s.toJson();
      expect(json.containsKey('break_start'), isFalse);
      expect(json.containsKey('break_end'), isFalse);
      expect(json['is_active'], isTrue);
    });

    test('copyWith overrides only passed fields', () {
      final s = DaySchedule.fromDbMap(dbRow());
      final t = s.copyWith(startTime: 480, isActive: false);
      expect(t.startTime, 480);
      expect(t.isActive, isFalse);
      expect(t.endTime, s.endTime);
      expect(t.id, s.id);
    });
  });

  group('day names', () {
    test('english', () {
      expect(DaySchedule.dayName(0), 'Sunday');
      expect(DaySchedule.dayName(1), 'Monday');
      expect(DaySchedule.dayName(6), 'Saturday');
    });

    test('french', () {
      expect(DaySchedule.dayNameFrench(0), 'Dimanche');
      expect(DaySchedule.dayNameFrench(1), 'Lundi');
      expect(DaySchedule.dayNameFrench(5), 'Vendredi');
    });
  });
}
