import 'package:flutter_test/flutter_test.dart';

import 'package:eyadati_kit/models/appointment_data.dart';

void main() {
  AppointmentData build({
    DateTime? start,
    int minutes = 60,
    String status = 'upcoming',
  }) {
    final s = start ?? DateTime.now().add(const Duration(hours: 1));
    return AppointmentData(
      id: 'apt-1',
      startTime: s,
      endTime: s.add(Duration(minutes: minutes)),
      patientName: 'Amina',
      status: status,
    );
  }

  group('constructor defaults', () {
    test('sane defaults', () {
      final a = build();
      expect(a.bookingType, 'online');
      expect(a.duration, 30);
      expect(a.isConsultation, isFalse);
      expect(a.doctorId, '');
      expect(a.doctorName, '');
      expect(a.patientAvatar, isNull);
      expect(a.patientPhone, isNull);
      expect(a.notes, isNull);
      expect(a.patientId, isNull);
      expect(a.attendanceStatus, isNull);
      expect(a.totalVisits, isNull);
      expect(a.noShowCount, isNull);
    });
  });

  group('isWithinNextHours', () {
    test('upcoming appointment inside the window', () {
      final a = build(start: DateTime.now().add(const Duration(minutes: 30)));
      expect(a.isWithinNextHours(2), isTrue);
      expect(a.isWithinNextHours(1), isTrue);
    });

    test('upcoming appointment beyond the window', () {
      final a = build(start: DateTime.now().add(const Duration(hours: 5)));
      expect(a.isWithinNextHours(2), isFalse);
      expect(a.isWithinNextHours(8), isTrue);
    });

    test('only future starts count', () {
      final a = build(start: DateTime.now().subtract(const Duration(hours: 1)));
      expect(a.isWithinNextHours(3), isFalse);
    });

    test('non-upcoming statuses never count', () {
      final start = DateTime.now().add(const Duration(minutes: 30));
      expect(build(start: start, status: 'cancelled').isWithinNextHours(2),
          isFalse);
      expect(build(start: start, status: 'done').isWithinNextHours(2), isFalse);
      expect(build(start: start, status: 'absent').isWithinNextHours(2),
          isFalse);
    });
  });
}
