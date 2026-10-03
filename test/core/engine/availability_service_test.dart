import 'package:flutter_test/flutter_test.dart';

import 'package:eyadati_kit/core/engine/availability_service.dart';
import 'package:eyadati_kit/models/appointment_data.dart';
import 'package:eyadati_kit/models/schedule_slot_model.dart';

/// Future date (never today) whose `weekday` matches, so the deterministic
/// schedule rules are exercised without the "today" lead-time filter.
DateTime dateForWeekday(int weekday, {DateTime? after}) {
  var d = after ?? DateTime.now();
  d = DateTime(d.year, d.month, d.day + 1);
  while (d.weekday != weekday) {
    d = d.add(const Duration(days: 1));
  }
  return d;
}

ScheduleSlot slot({
  required int dayOfWeek,
  int start = 540,
  int end = 1020,
  int? breakStart = 720,
  int? breakEnd = 780,
  bool isActive = true,
}) {
  return ScheduleSlot(
    id: 'slot-$dayOfWeek',
    doctorId: 'doc-1',
    dayOfWeek: dayOfWeek,
    startTime: start,
    endTime: end,
    breakStart: breakStart,
    breakEnd: breakEnd,
    isActive: isActive,
  );
}

AppointmentData aptOn(
  DateTime date, {
  required int startMinute,
  int minutes = 60,
  String status = 'upcoming',
  String id = 'apt-1',
}) {
  final s = DateTime(date.year, date.month, date.day)
      .add(Duration(minutes: startMinute));
  return AppointmentData(
    id: id,
    startTime: s,
    endTime: s.add(Duration(minutes: minutes)),
    patientName: 'Patient',
    status: status,
  );
}

List<int> startsOf(List<ValidStart> starts) =>
    starts.map((s) => s.minute).toList();

void main() {
  group('FreeRange / ValidStart', () {
    test('helpers', () {
      const r = FreeRange(540, 720);
      expect(r.duration, 180);
      expect(r.toString(), '09:00 - 12:00');
      const v = ValidStart(600, 30);
      expect(v.toString(), '10:00');
    });
  });

  group('AvailabilityService with no schedule', () {
    final date = dateForWeekday(1);
    const service = AvailabilityService(scheduleSlots: []);

    test('everything empty', () {
      expect(service.hasScheduleForDay(date), isFalse);
      expect(service.getFreeRanges(date, []), isEmpty);
      expect(service.getValidStarts(date, []), isEmpty);
      expect(service.getScheduleForDay(date), isEmpty);
      final day = service.getDayAvailability(date, []);
      expect(day.hasSchedule, isFalse);
      expect(day.freeRanges, isEmpty);
      expect(day.validStarts, isEmpty);
    });
  });

  group('AvailabilityService (Monday schedule with break)', () {
    final monday = dateForWeekday(1);
    final service = AvailabilityService(scheduleSlots: [
      slot(dayOfWeek: monday.weekday % 7),
    ]);

    test('hasScheduleForDay matches weekday only', () {
      expect(service.hasScheduleForDay(monday), isTrue);
      expect(service.hasScheduleForDay(dateForWeekday(3)), isFalse);
      expect(service.getScheduleForDay(monday), hasLength(1));
    });

    test('inactive slot does not count', () {
      final inactive = AvailabilityService(scheduleSlots: [
        slot(dayOfWeek: monday.weekday % 7, isActive: false),
      ]);
      expect(inactive.hasScheduleForDay(monday), isFalse);
      expect(inactive.getFreeRanges(monday, []), isEmpty);
    });

    test('free ranges exclude the break', () {
      final ranges = service.getFreeRanges(monday, []);
      expect(ranges, hasLength(2));
      expect(ranges[0].startMinute, 540);
      expect(ranges[0].endMinute, 720);
      expect(ranges[1].startMinute, 780);
      expect(ranges[1].endMinute, 1020);
    });

    test('occupied appointment splits the free ranges', () {
      final ranges =
          service.getFreeRanges(monday, [aptOn(monday, startMinute: 600)]);
      expect(ranges.map((r) => [r.startMinute, r.endMinute]).toList(), [
        [540, 600],
        [660, 720],
        [780, 1020],
      ]);
    });

    test('overlapping appointments are merged', () {
      final ranges = service.getFreeRanges(monday, [
        aptOn(monday, startMinute: 600, minutes: 60, id: 'a'),
        aptOn(monday, startMinute: 630, minutes: 60, id: 'b'),
      ]);
      expect(ranges.map((r) => [r.startMinute, r.endMinute]).toList(), [
        [540, 600],
        [690, 720],
        [780, 1020],
      ]);
    });

    test('cancelled and absent appointments are ignored', () {
      final ranges = service.getFreeRanges(monday, [
        aptOn(monday, startMinute: 600, status: 'cancelled'),
        aptOn(monday, startMinute: 660, status: 'absent', id: 'a2'),
      ]);
      expect(ranges, hasLength(2));
      expect(ranges[0].startMinute, 540);
      expect(ranges[0].endMinute, 720);
    });

    test('appointments on other dates are ignored', () {
      final tuesday = dateForWeekday(2);
      final ranges =
          service.getFreeRanges(monday, [aptOn(tuesday, startMinute: 600)]);
      expect(ranges, hasLength(2));
      expect(ranges[0].endMinute, 720);
    });

    test('getValidStarts(duration: 30) step 10 inside free ranges', () {
      final starts = service.getValidStarts(monday, [], duration: 30);
      expect(starts.every((s) => s.duration == 30), isTrue);
      expect(starts.first.minute, 540);
      // First range 540..720 -> 540, 550, ..., 690 (16 starts).
      final firstRange =
          starts.where((s) => s.minute < 720).map((s) => s.minute).toList();
      expect(firstRange, [for (var m = 540; m <= 690; m += 10) m]);
      // Second range 780..1020 -> 780 .. 990 (22 starts).
      final secondRange =
          starts.where((s) => s.minute >= 780).map((s) => s.minute).toList();
      expect(secondRange, [for (var m = 780; m <= 990; m += 10) m]);
      // No start overlaps the break.
      expect(starts.any((s) => s.minute >= 720 && s.minute < 780), isFalse);
    });

    test('default duration comes from appointmentDuration (20)', () {
      final starts = service.getValidStarts(monday, []);
      expect(starts.every((s) => s.duration == 20), isTrue);
      expect(starts.first.minute, 540);
      expect(starts.last.minute, 1000);
    });

    test('isConsultation uses consultationDuration (30)', () {
      final starts =
          service.getValidStarts(monday, [], isConsultation: true);
      expect(starts.every((s) => s.duration == 30), isTrue);
    });

    test('long duration shrinks the candidate set', () {
      final starts = service.getValidStarts(monday, [], duration: 120);
      // 540..720 fits (m <= 600); 780..1020 fits (m <= 900).
      expect(starts.first.minute, 540);
      expect(starts.any((s) => s.minute > 600 && s.minute < 780), isFalse);
      expect(starts.any((s) => s.minute > 900), isFalse);
    });

    group('isTimeAvailable', () {
      test('inside schedule, no conflicts', () {
        expect(service.isTimeAvailable(monday, 540, 30, []), isTrue);
        expect(service.isTimeAvailable(monday, 660, 60, []), isTrue);
      });

      test('conflicting appointment rejected, cancelled ignored', () {
        final apt = aptOn(monday, startMinute: 600);
        expect(service.isTimeAvailable(monday, 600, 30, [apt]), isFalse);
        expect(service.isTimeAvailable(monday, 540, 30, [apt]), isTrue);
        expect(
            service.isTimeAvailable(
                monday,
                600,
                30,
                [
                  aptOn(monday, startMinute: 600, status: 'cancelled'),
                ]),
            isTrue);
      });

      test('break and schedule bounds rejected', () {
        expect(service.isTimeAvailable(monday, 720, 30, []), isFalse);
        expect(service.isTimeAvailable(monday, 700, 30, []), isFalse);
        expect(service.isTimeAvailable(monday, 990, 60, []), isFalse);
        expect(service.isTimeAvailable(monday, 480, 30, []), isFalse);
      });

      test('no schedule that day rejected', () {
        final wednesday = dateForWeekday(3);
        expect(service.isTimeAvailable(wednesday, 540, 30, []), isFalse);
      });
    });
  });

  group('today lead-time and buffer', () {
    final today = DateTime.now();
    final service = AvailabilityService(
      scheduleSlots: [
        for (var day = 0; day <= 6; day++) slot(dayOfWeek: day),
      ],
    );

    test('starts respect lead time and buffer', () {
      final starts = service.getValidStarts(today, [], duration: 30);
      final nowMinutes = today.hour * 60 + today.minute;
      for (final s in starts) {
        expect(s.minute >= nowMinutes + 30, isTrue,
            reason: 'start ${s.minute} must respect 30 min lead time');
        expect(s.minute + 30 > nowMinutes + 15, isTrue,
            reason: 'start ${s.minute} must beat the 15 min buffer');
      }
    });
  });

  group('getDayAvailability', () {
    final monday = dateForWeekday(1);
    final service = AvailabilityService(scheduleSlots: [
      slot(dayOfWeek: monday.weekday % 7),
    ]);

    test('mirrors the underlying results when scheduled', () {
      final day = service.getDayAvailability(monday, [], duration: 30);
      expect(day.hasSchedule, isTrue);
      expect(day.date, monday);
      List<List<int>> pairs(List<FreeRange> ranges) =>
          ranges.map((r) => [r.startMinute, r.endMinute]).toList();
      expect(pairs(day.freeRanges), pairs(service.getFreeRanges(monday, [])));
      expect(startsOf(day.validStarts),
          startsOf(service.getValidStarts(monday, [], duration: 30)));
    });

    test('empty when the day has no schedule', () {
      final wednesday = dateForWeekday(3);
      final day = service.getDayAvailability(wednesday, [], duration: 30);
      expect(day.hasSchedule, isFalse);
      expect(day.freeRanges, isEmpty);
      expect(day.validStarts, isEmpty);
    });
  });
}
