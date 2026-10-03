import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';

class ProfileRepository {
  final SupabaseClient _client;

  ProfileRepository(this._client);

  Future<Profile?> getProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;
      return Profile.fromDatabase(response);
    } catch (e) {
      return null;
    }
  }

  Future<Profile?> getCurrentUserProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return getProfile(user.id);
  }

  Future<ProfileResult> updateProfile({
    required String userId,
    String? fullName,
    String? phone,
    String? city,
    String? avatarUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (phone != null) updates['phone'] = phone;
      if (city != null) updates['city'] = city;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      if (updates.isEmpty) {
        return ProfileResult.failure('No fields to update');
      }

      final response = await _client
          .from('profiles')
          .update(updates)
          .eq('id', userId)
          .select()
          .maybeSingle();

      if (response == null) {
        return ProfileResult.failure('Failed to update profile');
      }

      return ProfileResult.success(Profile.fromDatabase(response));
    } catch (e) {
      return ProfileResult.failure('Failed to update profile');
    }
  }

  Future<ProfileResult> updateDoctorProfile({
    required String userId,
    String? specialty,
    String? address,
    String? city,
    String? mapsLink,
    String? bio,
    String? phone,
    int? appointmentDuration,
    int? consultationDuration,
    bool? manualPause,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (specialty != null) updates['specialty'] = specialty;
      if (address != null) updates['address'] = address;
      if (city != null) updates['city'] = city;
      if (mapsLink != null) updates['maps_link'] = mapsLink;
      if (bio != null) updates['bio'] = bio;
      if (appointmentDuration != null) {
        updates['appointment_duration'] = appointmentDuration;
      }
      if (consultationDuration != null) {
        updates['consultation_duration'] = consultationDuration;
      }
      if (manualPause != null) updates['manual_pause'] = manualPause;

      if (phone != null) {
        await _client
            .from('profiles')
            .update({'phone': phone})
            .eq('id', userId);
      }

      if (updates.isEmpty && phone == null) {
        return ProfileResult.failure('No fields to update');
      }

      final response = await _client
          .from('doctors')
          .update(updates)
          .eq('id', userId)
          .select()
          .maybeSingle();

      if (response == null) {
        return ProfileResult.failure('Failed to update doctor profile');
      }

      return ProfileResult.success(null);
    } catch (e) {
      return ProfileResult.failure('Failed to update doctor profile');
    }
  }
}

class ProfileResult {
  final bool isSuccess;
  final Profile? profile;
  final String? error;

  ProfileResult._({
    required this.isSuccess,
    this.profile,
    this.error,
  });

  factory ProfileResult.success(Profile? profile) {
    return ProfileResult._(isSuccess: true, profile: profile);
  }

  factory ProfileResult.failure(String error) {
    return ProfileResult._(isSuccess: false, error: error);
  }
}
