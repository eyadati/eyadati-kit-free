import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/doctor.dart';
import '../core/utils/input_validator.dart';
import '../core/utils/security_validator.dart';
import '../core/utils/pagination.dart';
import '../core/utils/cache.dart';

class DoctorRepository {
  final SupabaseClient _client;
  final MemoryCache _cache = MemoryCache();

  DoctorRepository(this._client) {
    _cache.startCleanupTimer();
  }

  Future<List<Doctor>> getActiveDoctors({
    String? specialty,
    String? city,
    String? searchQuery,
    PaginationParams? pagination,
  }) async {
    try {
      final effectivePagination = pagination ?? const PaginationParams();
      
      PostgrestFilterBuilder query = _client
          .from('doctors')
          .select()
          .eq('manual_pause', false)
          .eq('is_test', false);

      if (specialty != null && specialty.isNotEmpty) {
        final sanitizedSpecialty = SecurityValidator.sanitizeHtml(specialty.trim());
        query = query.ilike('specialty', '%$sanitizedSpecialty%');
      }

      if (city != null && city.isNotEmpty) {
        final sanitizedCity = SecurityValidator.sanitizeHtml(city.trim());
        query = query.ilike('city', '%$sanitizedCity%');
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final sanitizedQuery = SecurityValidator.sanitizeHtml(searchQuery.trim());
        query = query.or('specialty.ilike.%$sanitizedQuery%,address.ilike.%$sanitizedQuery%,bio.ilike.%$sanitizedQuery%');
      }

      if (effectivePagination.hasPagination) {
        final response = await query
            .order('created_at', ascending: false)
            .range(effectivePagination.effectiveOffset, effectivePagination.effectiveOffset + effectivePagination.effectiveLimit - 1);
        return (response as List)
            .map((json) => Doctor.fromDatabase(json))
            .toList();
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List)
          .map((json) => Doctor.fromDatabase(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<PaginatedResult<Doctor>> getActiveDoctorsPaginated({
    String? specialty,
    String? city,
    String? searchQuery,
    int page = 1,
    int pageSize = 20,
  }) async {
    final doctors = await getActiveDoctors(
      specialty: specialty,
      city: city,
      searchQuery: searchQuery,
      pagination: PaginationParams(page: page, pageSize: pageSize),
    );

    return PaginatedResult.fromItems(
      items: doctors,
      totalCount: doctors.length,
      page: page,
      pageSize: pageSize,
    );
  }

  Future<Doctor?> getDoctor(String doctorId) async {
    try {
      if (!SecurityValidator.isValidUuid(doctorId)) {
        return null;
      }

      final cacheKey = CacheKeys.doctor(doctorId);
      if (_cache.contains(cacheKey)) {
        return _cache.get<Doctor>(cacheKey);
      }

      final response = await _client
          .from('doctors')
          .select()
          .eq('id', doctorId)
          .maybeSingle();

      if (response == null) return null;

      final profile = await _client
          .from('profiles')
          .select('phone')
          .eq('id', doctorId)
          .maybeSingle();

      if (profile != null) {
        response['phone'] = profile['phone'];
      }

      final doctor = Doctor.fromDatabase(response);
      _cache.put(cacheKey, doctor, ttl: const Duration(minutes: 5));

      return doctor;
    } catch (e) {
      return null;
    }
  }

  Future<Doctor?> getMyDoctorProfile(String userId) async {
    try {
      if (!SecurityValidator.isValidUuid(userId)) {
        return null;
      }

      final response = await _client
          .from('doctors')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;

      final profile = await _client
          .from('profiles')
          .select('phone')
          .eq('id', userId)
          .maybeSingle();

      if (profile != null) {
        response['phone'] = profile['phone'];
      }

      return Doctor.fromDatabase(response);
    } catch (e) {
      return null;
    }
  }

  Future<DoctorResult> createDoctorProfile({
    required String userId,
    required String specialty,
    required String address,
    String? city,
    String? mapsLink,
    String? bio,
    int appointmentDuration = 20,
    int consultationDuration = 40,
  }) async {
    try {
      if (!SecurityValidator.isValidUuid(userId)) {
        return DoctorResult.failure('Invalid user ID');
      }

      final specialtyError = InputValidator.validateRequired(specialty, 'Specialty');
      if (specialtyError != null) {
        return DoctorResult.failure(specialtyError);
      }

      final addressError = InputValidator.validateRequired(address, 'Address');
      if (addressError != null) {
        return DoctorResult.failure(addressError);
      }

      final durationError = InputValidator.validateDuration(appointmentDuration);
      if (durationError != null) {
        return DoctorResult.failure(durationError);
      }

      final bioError = InputValidator.validateBio(bio);
      if (bioError != null) {
        return DoctorResult.failure(bioError);
      }

      final data = {
        'id': userId,
        'specialty': SecurityValidator.sanitizeHtml(specialty.trim()),
        'address': SecurityValidator.sanitizeHtml(address.trim()),
        'city': city?.trim(),
        'maps_link': mapsLink?.trim(),
        'bio': bio?.trim(),
        'appointment_duration': appointmentDuration,
        'consultation_duration': consultationDuration,
      };

      final response = await _client
          .from('doctors')
          .insert(data)
          .select()
          .maybeSingle();

      if (response == null) {
        return DoctorResult.failure('Failed to create doctor profile');
      }

      _cache.removeByPrefix(CacheKeys.doctors);

      return DoctorResult.success(Doctor.fromDatabase(response));
    } catch (e) {
      return DoctorResult.failure('Failed to create doctor profile');
    }
  }

  Future<DoctorResult> updateDoctorProfile({
    required String doctorId,
    required String userId,
    String? specialty,
    String? address,
    String? city,
    String? mapsLink,
    double? latitude,
    double? longitude,
    String? bio,
    String? photoUrl,
    String? phone,
    int? appointmentDuration,
    int? consultationDuration,
    bool? manualPause,
  }) async {
    try {
      if (!SecurityValidator.isValidUuid(doctorId)) {
        return DoctorResult.failure('Invalid doctor ID');
      }

      if (!SecurityValidator.isValidDoctorOwnership(userId, doctorId)) {
        return DoctorResult.failure('You can only update your own profile');
      }

      final updates = <String, dynamic>{};
      
      if (specialty != null) {
        final specialtyError = InputValidator.validateRequired(specialty, 'Specialty');
        if (specialtyError != null) {
          return DoctorResult.failure(specialtyError);
        }
        updates['specialty'] = SecurityValidator.sanitizeHtml(specialty.trim());
      }
      
      if (address != null) {
        final addressError = InputValidator.validateRequired(address, 'Address');
        if (addressError != null) {
          return DoctorResult.failure(addressError);
        }
        updates['address'] = SecurityValidator.sanitizeHtml(address.trim());
      }
      
      if (city != null) {
        final cityError = InputValidator.validateCity(city);
        if (cityError != null) {
          return DoctorResult.failure(cityError);
        }
        updates['city'] = city.trim();
      }
      
      if (mapsLink != null) {
        updates['maps_link'] = mapsLink.trim();
      }
      
      if (latitude != null) {
        updates['latitude'] = latitude;
      }
      
      if (longitude != null) {
        updates['longitude'] = longitude;
      }
      
      if (bio != null) {
        final bioError = InputValidator.validateBio(bio);
        if (bioError != null) {
          return DoctorResult.failure(bioError);
        }
        updates['bio'] = bio.trim();
      }
      
      if (photoUrl != null) {
        updates['photo_url'] = photoUrl.trim();
      }
      
      if (appointmentDuration != null) {
        final durationError = InputValidator.validateDuration(appointmentDuration);
        if (durationError != null) {
          return DoctorResult.failure(durationError);
        }
        updates['appointment_duration'] = appointmentDuration;
      }
      
      if (consultationDuration != null) {
        final durationError = InputValidator.validateDuration(consultationDuration);
        if (durationError != null) {
          return DoctorResult.failure(durationError);
        }
        updates['consultation_duration'] = consultationDuration;
      }
      
      if (manualPause != null) updates['manual_pause'] = manualPause;

      if (phone != null) {
        await _client
            .from('profiles')
            .update({'phone': phone})
            .eq('id', doctorId);
      }

      if (updates.isEmpty && phone == null) {
        return DoctorResult.failure('No fields to update');
      }

      final response = await _client
          .from('doctors')
          .update(updates)
          .eq('id', doctorId)
          .select()
          .maybeSingle();

      if (response == null) {
        return DoctorResult.failure('Failed to update doctor profile');
      }

      if (phone != null) {
        response['phone'] = phone;
      } else {
        final profile = await _client
            .from('profiles')
            .select('phone')
            .eq('id', doctorId)
            .maybeSingle();
        if (profile != null) {
          response['phone'] = profile['phone'];
        }
      }

      _cache.remove(CacheKeys.doctor(doctorId));
      _cache.removeByPrefix(CacheKeys.doctors);

      return DoctorResult.success(Doctor.fromDatabase(response));
    } catch (e) {
      return DoctorResult.failure('Failed to update doctor profile');
    }
  }

  Future<DoctorResult> pauseProfile(String doctorId, String userId, bool pause) async {
    try {
      if (!SecurityValidator.isValidUuid(doctorId)) {
        return DoctorResult.failure('Invalid doctor ID');
      }

      if (!SecurityValidator.isValidDoctorOwnership(userId, doctorId)) {
        return DoctorResult.failure('You can only pause your own profile');
      }

      await _client
          .from('doctors')
          .update({'manual_pause': pause})
          .eq('id', doctorId);
      
      _cache.remove(CacheKeys.doctor(doctorId));
      _cache.removeByPrefix(CacheKeys.doctors);
      
      return DoctorResult.success(Doctor(
        id: doctorId,
        name: 'Docteur',
        specialty: '',
        address: '',
        manualPause: pause,
      ));
    } catch (e) {
      return DoctorResult.failure('Failed to pause profile');
    }
  }

  Future<List<String>> getSpecialties() async {
    try {
      if (_cache.contains(CacheKeys.specialties)) {
        return _cache.get<List<String>>(CacheKeys.specialties) ?? [];
      }

      final response = await _client
          .from('doctors')
          .select('specialty')
          .eq('manual_pause', false)
          .eq('is_test', false);

      final specialties = (response as List)
          .map((e) => e['specialty'] as String)
          .toSet()
          .toList();
      specialties.sort();

      _cache.put(CacheKeys.specialties, specialties, ttl: const Duration(minutes: 15));

      return specialties;
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> getCities() async {
    try {
      if (_cache.contains(CacheKeys.cities)) {
        return _cache.get<List<String>>(CacheKeys.cities) ?? [];
      }

      final response = await _client
          .from('doctors')
          .select('city')
          .eq('manual_pause', false)
          .eq('is_test', false);

      final cities = (response as List)
          .map((e) => e['city'] as String?)
          .where((city) => city != null && city.isNotEmpty)
          .cast<String>()
          .toSet()
          .toList();
      cities.sort();

      _cache.put(CacheKeys.cities, cities, ttl: const Duration(minutes: 15));

      return cities;
    } catch (e) {
      return [];
    }
  }

  void clearCache() {
    _cache.clear();
  }
}

class DoctorResult {
  final bool isSuccess;
  final Doctor? doctor;
  final String? error;

  DoctorResult._({
    required this.isSuccess,
    this.doctor,
    this.error,
  });

  factory DoctorResult.success(Doctor doctor) {
    return DoctorResult._(isSuccess: true, doctor: doctor);
  }

  factory DoctorResult.failure(String error) {
    return DoctorResult._(isSuccess: false, error: error);
  }
}
