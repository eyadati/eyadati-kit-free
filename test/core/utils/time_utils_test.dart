import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eyadati_kit/core/utils/time_utils.dart';

void main() {
  group('TimeUtils.minutes <-> TimeOfDay', () {
    test('timeOfDayToMinutes', () {
      expect(TimeUtils.timeOfDayToMinutes(const TimeOfDay(hour: 9, minute: 30)),
          570);
      expect(TimeUtils.timeOfDayToMinutes(const TimeOfDay(hour: 0, minute: 0)),
          0);
      expect(TimeUtils.timeOfDayToMinutes(const TimeOfDay(hour: 23, minute: 59)),
          1439);
    });

    test('minutesToTimeOfDay', () {
      expect(TimeUtils.minutesToTimeOfDay(570),
          const TimeOfDay(hour: 9, minute: 30));
      expect(TimeUtils.minutesToTimeOfDay(1439),
          const TimeOfDay(hour: 23, minute: 59));
    });
  });

  group('TimeUtils string conversions', () {
    test('minutesToString pads to HH:mm', () {
      expect(TimeUtils.minutesToString(0), '00:00');
      expect(TimeUtils.minutesToString(5), '00:05');
      expect(TimeUtils.minutesToString(540), '09:00');
      expect(TimeUtils.minutesToString(1439), '23:59');
    });

    test('stringToMinutes parses HH:mm and Postgres HH:mm:ss', () {
      expect(TimeUtils.stringToMinutes('09:00'), 540);
      expect(TimeUtils.stringToMinutes('09:00:00'), 540);
      expect(TimeUtils.stringToMinutes('17:30:00'), 1050);
    });

    test('roundtrip minutes -> string -> minutes', () {
      for (final m in [0, 1, 59, 60, 540, 600, 1439]) {
        expect(TimeUtils.stringToMinutes(TimeUtils.minutesToString(m)), m);
      }
    });

    test('formatMinutes delegates to minutesToString', () {
      expect(TimeUtils.formatMinutes(540), '09:00');
    });
  });

  group('TimeUtils.overlaps', () {
    test('overlapping intervals', () {
      expect(TimeUtils.overlaps(600, 660, 630, 700), isTrue);
      expect(TimeUtils.overlaps(630, 700, 600, 660), isTrue);
      expect(TimeUtils.overlaps(600, 700, 620, 640), isTrue); // containment
    });

    test('touching intervals do not overlap (half-open ranges)', () {
      expect(TimeUtils.overlaps(600, 660, 660, 720), isFalse);
      expect(TimeUtils.overlaps(660, 720, 600, 660), isFalse);
    });

    test('disjoint intervals', () {
      expect(TimeUtils.overlaps(600, 630, 700, 730), isFalse);
      expect(TimeUtils.overlaps(700, 730, 600, 630), isFalse);
    });
  });

  test('extractMinuteFromDate', () {
    expect(TimeUtils.extractMinuteFromDate(DateTime(2026, 1, 1, 9, 30)), 570);
    expect(TimeUtils.extractMinuteFromDate(DateTime(2026, 1, 1, 0, 0)), 0);
  });
}
