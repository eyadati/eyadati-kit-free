import 'package:freezed_annotation/freezed_annotation.dart';

part 'doctor.freezed.dart';
part 'doctor.g.dart';

@freezed
class Doctor with _$Doctor {
  const factory Doctor({
    required String id,
    required String name,
    required String specialty,
    required String address,
    String? city,
    String? mapsLink,
    double? latitude,
    double? longitude,
    String? bio,
    String? photoUrl,
    @Default(20) int appointmentDuration,
    @Default(40) int consultationDuration,
    @Default(false) bool manualPause,
    @Default(false) bool isTest,
    String? phone,
    DateTime? createdAt,
  }) = _Doctor;

  factory Doctor.fromJson(Map<String, dynamic> json) => _$DoctorFromJson(json);

  factory Doctor.fromDatabase(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Docteur',
      specialty: json['specialty'] as String? ?? '',
      address: json['address'] as String? ?? '',
      city: json['city'] as String?,
      mapsLink: json['maps_link'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      bio: json['bio'] as String?,
      photoUrl: json['photo_url'] as String?,
      appointmentDuration: json['appointment_duration'] as int? ?? 20,
      consultationDuration: json['consultation_duration'] as int? ?? 40,
      manualPause: json['manual_pause'] as bool? ?? false,
      isTest: json['is_test'] as bool? ?? false,
      phone: json['phone'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  factory Doctor.withProfile(Doctor doctor, String fullName, String? avatarUrl) {
    return doctor.copyWith(
      photoUrl: avatarUrl,
    );
  }
}

@freezed
class DoctorWithProfile with _$DoctorWithProfile {
  const factory DoctorWithProfile({
    required Doctor doctor,
    required String fullName,
    String? avatarUrl,
  }) = _DoctorWithProfile;
}

class DoctorFilter {
  final String? specialty;
  final String? city;
  final String? searchQuery;

  const DoctorFilter({
    this.specialty,
    this.city,
    this.searchQuery,
  });

  bool get hasFilters => specialty != null || city != null || searchQuery != null;
}
