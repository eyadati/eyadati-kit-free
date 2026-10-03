import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

@freezed
class Profile with _$Profile {
  const factory Profile({
    required String id,
    required String role,
    required String fullName,
    String? email,
    String? phone,
    String? city,
    String? avatarUrl,
    DateTime? createdAt,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

  factory Profile.fromDatabase(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      role: json['role'] as String,
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      city: json['city'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}

enum UserRole {
  @JsonValue('patient')
  patient,
  @JsonValue('doctor')
  doctor;

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'doctor':
        return UserRole.doctor;
      default:
        return UserRole.patient;
    }
  }
}
