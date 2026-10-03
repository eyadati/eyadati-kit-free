import 'package:freezed_annotation/freezed_annotation.dart';

part 'appointment.freezed.dart';
part 'appointment.g.dart';

@freezed
class Appointment with _$Appointment {
  const factory Appointment({
    required String id,
    required String doctorId,
    String? patientId,
    required DateTime scheduledAt,
    required int duration,
    required AppointmentStatus status,
    required BookingType bookingType,
    @Default(false) bool isConsultation,
    required String patientNameSnapshot,
    String? patientPhoneSnapshot,
    String? notes,
    String? attendanceStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Appointment;

  factory Appointment.fromJson(Map<String, dynamic> json) =>
      _$AppointmentFromJson(json);

  factory Appointment.fromDatabase(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String,
      doctorId: json['doctor_id'] as String,
      patientId: json['patient_id'] as String?,
      scheduledAt: DateTime.parse(json['scheduled_at'] as String).toLocal(),
      duration: json['duration'] as int,
      status: AppointmentStatus.fromString(json['status'] as String),
      bookingType: BookingType.fromString(json['booking_type'] as String),
      isConsultation: json['is_consultation'] as bool? ?? false,
      patientNameSnapshot: json['patient_name_snapshot'] as String? ?? '',
      patientPhoneSnapshot: json['patient_phone_snapshot'] as String?,
      notes: json['notes'] as String?,
      attendanceStatus: json['attendance_status'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}

enum AppointmentStatus {
  @JsonValue('upcoming')
  upcoming,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('absent')
  absent;

  static AppointmentStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppointmentStatus.completed;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      case 'absent':
        return AppointmentStatus.absent;
      default:
        return AppointmentStatus.upcoming;
    }
  }

  String get displayName {
    switch (this) {
      case AppointmentStatus.upcoming:
        return 'Upcoming';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.absent:
        return 'Absent';
    }
  }
}

enum BookingType {
  @JsonValue('online')
  online,
  @JsonValue('manual')
  manual;

  static BookingType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'manual':
        return BookingType.manual;
      default:
        return BookingType.online;
    }
  }
}

@freezed
class TimeSlot with _$TimeSlot {
  const factory TimeSlot({
    required DateTime startTime,
    required DateTime endTime,
    required int durationMinutes,
    @Default(false) bool isAvailable,
  }) = _TimeSlot;
}

@freezed
class CreateAppointmentParams with _$CreateAppointmentParams {
  const factory CreateAppointmentParams({
    required String doctorId,
    required String patientId,
    required DateTime scheduledAt,
    required int duration,
    required String patientName,
    String? patientPhone,
    @Default(false) bool isConsultation,
    String? notes,
  }) = _CreateAppointmentParams;
}
