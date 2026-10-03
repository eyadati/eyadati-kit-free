import 'package:eyadati_kit/models/schedule_slot_model.dart';
import 'package:eyadati_kit/models/appointment_data.dart';
import 'package:eyadati_kit/core/utils/time_utils.dart';

class FreeRange {
  final int startMinute;
  final int endMinute;

  const FreeRange(this.startMinute, this.endMinute);

  int get duration => endMinute - startMinute;

  @override
  String toString() => '${TimeUtils.minutesToString(startMinute)} - ${TimeUtils.minutesToString(endMinute)}';
}

class ValidStart {
  final int minute;
  final int duration;

  const ValidStart(this.minute, this.duration);

  @override
  String toString() => TimeUtils.minutesToString(minute);
}

class DayAvailability {
  final DateTime date;
  final List<FreeRange> freeRanges;
  final List<ValidStart> validStarts;
  final bool hasSchedule;

  const DayAvailability({
    required this.date,
    required this.freeRanges,
    required this.validStarts,
    required this.hasSchedule,
  });
}

class AvailabilityService {
  final List<ScheduleSlot> scheduleSlots;
  final int appointmentDuration;
  final int consultationDuration;
  final int baseInterval;
  final int minimumLeadTimeMinutes;
  final int bufferMinutes;

  const AvailabilityService({
    required this.scheduleSlots,
    this.appointmentDuration = 20,
    this.consultationDuration = 30,
    this.baseInterval = 10,
    this.minimumLeadTimeMinutes = 30,
    this.bufferMinutes = 15,
  });

  int _getDayOfWeek(DateTime date) => date.weekday % 7;

  List<FreeRange> getOccupiedRanges(DateTime date, List<AppointmentData> appointments) {
    final dayOfWeek = _getDayOfWeek(date);
    final List<FreeRange> occupied = [];

    final daySchedules = scheduleSlots.where((s) => s.dayOfWeek == dayOfWeek && s.isActive);
    for (final slot in daySchedules) {
      if (slot.breakStart != null && slot.breakEnd != null) {
        occupied.add(FreeRange(slot.breakStart!, slot.breakEnd!));
      }
    }

    final dayAppointments = appointments.where((apt) =>
        apt.startTime.year == date.year &&
        apt.startTime.month == date.month &&
        apt.startTime.day == date.day &&
        apt.status != 'cancelled' &&
        apt.status != 'absent');

    for (final apt in dayAppointments) {
      final start = TimeUtils.extractMinuteFromDate(apt.startTime);
      final end = TimeUtils.extractMinuteFromDate(apt.endTime);
      occupied.add(FreeRange(start, end));
    }

    if (occupied.isEmpty) return [];

    occupied.sort((a, b) => a.startMinute.compareTo(b.startMinute));

    final List<FreeRange> merged = [];
    var currentStart = occupied[0].startMinute;
    var currentEnd = occupied[0].endMinute;

    for (int i = 1; i < occupied.length; i++) {
      if (occupied[i].startMinute < currentEnd) {
        if (occupied[i].endMinute > currentEnd) {
          currentEnd = occupied[i].endMinute;
        }
      } else {
        merged.add(FreeRange(currentStart, currentEnd));
        currentStart = occupied[i].startMinute;
        currentEnd = occupied[i].endMinute;
      }
    }
    merged.add(FreeRange(currentStart, currentEnd));

    return merged;
  }

  List<FreeRange> getFreeRanges(DateTime date, List<AppointmentData> appointments) {
    final dayOfWeek = _getDayOfWeek(date);
    final daySchedules = scheduleSlots.where((s) => s.dayOfWeek == dayOfWeek && s.isActive).toList();
    if (daySchedules.isEmpty) return [];

    final occupied = getOccupiedRanges(date, appointments);
    final List<FreeRange> freeRanges = [];

    for (final schedule in daySchedules) {
      var currentPos = schedule.startTime;
      final dayEnd = schedule.endTime;

      for (final occ in occupied) {
        if (occ.startMinute >= dayEnd) continue;
        if (occ.endMinute <= currentPos) continue;

        if (occ.startMinute > currentPos) {
          freeRanges.add(FreeRange(currentPos, occ.startMinute));
        }
        if (occ.endMinute > currentPos) {
          currentPos = occ.endMinute;
        }
      }

      if (currentPos < dayEnd) {
        freeRanges.add(FreeRange(currentPos, dayEnd));
      }
    }

    return freeRanges;
  }

List<ValidStart> getValidStarts(
    DateTime date,
    List<AppointmentData> appointments, {
    int? duration,
    bool isConsultation = false,
  }) {
    final effectiveDuration = duration ?? (isConsultation ? consultationDuration : appointmentDuration);
    final freeRanges = getFreeRanges(date, appointments);
    final List<ValidStart> starts = [];

    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    final nowMinutes = TimeUtils.extractMinuteFromDate(now);
    final leadTimeThreshold = nowMinutes + minimumLeadTimeMinutes;

    for (final range in freeRanges) {
      for (int m = range.startMinute; m + effectiveDuration <= range.endMinute; m += baseInterval) {
        if (isToday) {
          final slotEndMinute = m + effectiveDuration;
          final currentMinuteWithBuffer = nowMinutes + bufferMinutes;
          if (m < leadTimeThreshold) continue;
          if (slotEndMinute <= currentMinuteWithBuffer) continue;
        }
        starts.add(ValidStart(m, effectiveDuration));
      }
    }

    return starts;
  }

  bool hasScheduleForDay(DateTime date) {
    final dayOfWeek = _getDayOfWeek(date);
    return scheduleSlots.any((s) => s.dayOfWeek == dayOfWeek && s.isActive);
  }

  List<ScheduleSlot> getScheduleForDay(DateTime date) {
    final dayOfWeek = _getDayOfWeek(date);
    return scheduleSlots.where((s) => s.dayOfWeek == dayOfWeek && s.isActive).toList();
  }

  bool isTimeAvailable(DateTime date, int startMinute, int duration, List<AppointmentData> appointments) {
    final endMinute = startMinute + duration;
    
    final dayOfWeek = _getDayOfWeek(date);
    final daySchedules = scheduleSlots.where((s) => s.dayOfWeek == dayOfWeek && s.isActive);
    bool withinSchedule = false;
    for (final s in daySchedules) {
      if (startMinute >= s.startTime && endMinute <= s.endTime) {
        withinSchedule = true;
        if (s.breakStart != null && s.breakEnd != null) {
          if (TimeUtils.overlaps(startMinute, endMinute, s.breakStart!, s.breakEnd!)) {
            return false;
          }
        }
        break;
      }
    }
    
    if (!withinSchedule) return false;

    final dayAppointments = appointments.where((apt) =>
        apt.startTime.year == date.year &&
        apt.startTime.month == date.month &&
        apt.startTime.day == date.day &&
        apt.status != 'cancelled' &&
        apt.status != 'absent');

    for (final apt in dayAppointments) {
      final aptStart = TimeUtils.extractMinuteFromDate(apt.startTime);
      final aptEnd = TimeUtils.extractMinuteFromDate(apt.endTime);
      if (TimeUtils.overlaps(startMinute, endMinute, aptStart, aptEnd)) {
        return false;
      }
    }

    return true;
  }

  DayAvailability getDayAvailability(
    DateTime date,
    List<AppointmentData> appointments, {
    int? duration,
    bool isConsultation = false,
  }) {
    final hasSchedule = hasScheduleForDay(date);
    final freeRanges = hasSchedule ? getFreeRanges(date, appointments) : <FreeRange>[];
    final validStarts = hasSchedule 
        ? getValidStarts(date, appointments, duration: duration, isConsultation: isConsultation)
        : <ValidStart>[];

    return DayAvailability(
      date: date,
      freeRanges: freeRanges,
      validStarts: validStarts,
      hasSchedule: hasSchedule,
    );
  }
}