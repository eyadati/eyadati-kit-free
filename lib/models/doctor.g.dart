// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doctor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DoctorImpl _$$DoctorImplFromJson(Map<String, dynamic> json) => _$DoctorImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  specialty: json['specialty'] as String,
  address: json['address'] as String,
  city: json['city'] as String?,
  mapsLink: json['mapsLink'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  bio: json['bio'] as String?,
  photoUrl: json['photoUrl'] as String?,
  appointmentDuration: (json['appointmentDuration'] as num?)?.toInt() ?? 20,
  consultationDuration: (json['consultationDuration'] as num?)?.toInt() ?? 40,
  manualPause: json['manualPause'] as bool? ?? false,
  isTest: json['isTest'] as bool? ?? false,
  phone: json['phone'] as String?,
  subscriptionEnd: json['subscriptionEnd'] == null
      ? null
      : DateTime.parse(json['subscriptionEnd'] as String),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$DoctorImplToJson(_$DoctorImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'specialty': instance.specialty,
      'address': instance.address,
      'city': instance.city,
      'mapsLink': instance.mapsLink,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'bio': instance.bio,
      'photoUrl': instance.photoUrl,
      'appointmentDuration': instance.appointmentDuration,
      'consultationDuration': instance.consultationDuration,
      'manualPause': instance.manualPause,
      'isTest': instance.isTest,
      'phone': instance.phone,
      'subscriptionEnd': instance.subscriptionEnd?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
    };
