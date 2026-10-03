import 'package:flutter/material.dart';

class TimeUtils {
  static int timeOfDayToMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  static TimeOfDay minutesToTimeOfDay(int m) =>
      TimeOfDay(hour: m ~/ 60, minute: m % 60);

  static String minutesToString(int m) =>
      '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';

  static int stringToMinutes(String s) {
    final parts = s.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  static String formatMinutes(int m) => minutesToString(m);

  static int extractMinuteFromDate(DateTime dt) => dt.hour * 60 + dt.minute;

  static bool overlaps(int startA, int endA, int startB, int endB) =>
      startA < endB && startB < endA;
}