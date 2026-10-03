// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppointmentImpl _$$AppointmentImplFromJson(Map<String, dynamic> json) =>
    _$AppointmentImpl(
      id: json['id'] as String,
      doctorId: json['doctorId'] as String,
      patientId: json['patientId'] as String?,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      duration: (json['duration'] as num).toInt(),
      status: $enumDecode(_$AppointmentStatusEnumMap, json['status']),
      bookingType: $enumDecode(_$BookingTypeEnumMap, json['bookingType']),
      isConsultation: json['isConsultation'] as bool? ?? false,
      patientNameSnapshot: json['patientNameSnapshot'] as String,
      patientPhoneSnapshot: json['patientPhoneSnapshot'] as String?,
      notes: json['notes'] as String?,
      attendanceStatus: json['attendanceStatus'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$AppointmentImplToJson(_$AppointmentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'doctorId': instance.doctorId,
      'patientId': instance.patientId,
      'scheduledAt': instance.scheduledAt.toIso8601String(),
      'duration': instance.duration,
      'status': _$AppointmentStatusEnumMap[instance.status]!,
      'bookingType': _$BookingTypeEnumMap[instance.bookingType]!,
      'isConsultation': instance.isConsultation,
      'patientNameSnapshot': instance.patientNameSnapshot,
      'patientPhoneSnapshot': instance.patientPhoneSnapshot,
      'notes': instance.notes,
      'attendanceStatus': instance.attendanceStatus,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$AppointmentStatusEnumMap = {
  AppointmentStatus.upcoming: 'upcoming',
  AppointmentStatus.completed: 'completed',
  AppointmentStatus.cancelled: 'cancelled',
  AppointmentStatus.absent: 'absent',
};

const _$BookingTypeEnumMap = {
  BookingType.online: 'online',
  BookingType.manual: 'manual',
};
