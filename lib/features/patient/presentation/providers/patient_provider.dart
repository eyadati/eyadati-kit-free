import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eyadati_kit/core/utils/supabase_client.dart';
import 'package:eyadati_kit/features/auth/presentation/providers/auth_provider.dart';
import 'package:eyadati_kit/repositories/profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PatientState {
  final String name;
  final String email;
  final String phone;
  final String city;
  final String avatarUrl;
  final int upcomingCount;
  final int favoritesCount;
  final List<PatientAppointmentViewModel> upcomingAppointments;
  final List<PatientAppointmentViewModel> pastAppointments;
  final List<PatientAppointmentViewModel> cancelledAppointments;

  const PatientState({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.city = '',
    this.avatarUrl = '',
    this.upcomingCount = 0,
    this.favoritesCount = 0,
    this.upcomingAppointments = const [],
    this.pastAppointments = const [],
    this.cancelledAppointments = const [],
  });

  PatientState copyWith({
    String? name,
    String? email,
    String? phone,
    String? city,
    String? avatarUrl,
    int? upcomingCount,
    int? favoritesCount,
    List<PatientAppointmentViewModel>? upcomingAppointments,
    List<PatientAppointmentViewModel>? pastAppointments,
    List<PatientAppointmentViewModel>? cancelledAppointments,
  }) {
    return PatientState(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      upcomingCount: upcomingCount ?? this.upcomingCount,
      favoritesCount: favoritesCount ?? this.favoritesCount,
      upcomingAppointments: upcomingAppointments ?? this.upcomingAppointments,
      pastAppointments: pastAppointments ?? this.pastAppointments,
      cancelledAppointments:
          cancelledAppointments ?? this.cancelledAppointments,
    );
  }
}

class PatientAppointmentViewModel {
  final String id;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final String? doctorAvatar;
  final String? doctorAddress;
  final String? doctorPhone;
  final String? mapsLink;
  final DateTime dateTime;
  final int duration;
  final String status;
  final bool isConsultation;
  final String? notes;

  PatientAppointmentViewModel({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    this.doctorAvatar,
    this.doctorAddress,
    this.doctorPhone,
    this.mapsLink,
    required this.dateTime,
    required this.duration,
    required this.status,
    this.isConsultation = false,
    this.notes,
  });

  factory PatientAppointmentViewModel.fromMap(
    Map<String, dynamic> map,
    String doctorName,
    String doctorSpecialty,
    String? doctorAvatar,
    String? doctorAddress,
    String? doctorPhone,
    String? mapsLink,
  ) {
    return PatientAppointmentViewModel(
      id: map['id'] as String,
      doctorId: map['doctor_id'] as String,
      doctorName: doctorName,
      doctorSpecialty: doctorSpecialty,
      doctorAvatar: doctorAvatar,
      doctorAddress: doctorAddress,
      doctorPhone: doctorPhone,
      mapsLink: mapsLink,
      dateTime: DateTime.parse(map['scheduled_at'] as String).toLocal(),
      duration: map['duration'] as int? ?? 30,
      status: map['status'] as String? ?? 'upcoming',
      isConsultation: map['is_consultation'] as bool? ?? false,
      notes: map['notes'] as String?,
    );
  }
}

final patientProvider =
    AsyncNotifierProvider<PatientNotifier, PatientState>(() {
  return PatientNotifier();
});

class PatientNotifier extends AsyncNotifier<PatientState> {
  SupabaseClient get _client => SupabaseInitializer.client;
  RealtimeChannel? _appointmentsChannel;
  Timer? _debounceTimer;
  bool _isFetching = false;
  StreamSubscription? _authSubscription;

  @override
  Future<PatientState> build() async {
    _subscribeToAppointments();
    _listenToAuth();
    return _load();
  }

  void dispose() {
    _appointmentsChannel?.unsubscribe();
    _debounceTimer?.cancel();
    _authSubscription?.cancel();
  }

  void _listenToAuth() {
    _authSubscription = _client.auth.onAuthStateChange.listen((data) {
      if (data.session == null) {
        _appointmentsChannel?.unsubscribe();
        _appointmentsChannel = null;
      } else {
        _subscribeToAppointments();
      }
    });
  }

  void _subscribeToAppointments() {
    final user = _client.auth.currentUser;
    if (user == null) return;

    _appointmentsChannel?.unsubscribe();
    _appointmentsChannel = _client
        .channel('patient_appointments_${user.id}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'appointments',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'patient_id',
            value: user.id,
          ),
          callback: (_) => _silentRefresh(),
        )
        .subscribe((status, error) {
          if (error != null) {
            print('PatientAppt: Realtime error: $error');
          }
          if (status == RealtimeSubscribeStatus.channelError ||
              status == RealtimeSubscribeStatus.timedOut) {
            Future.delayed(const Duration(seconds: 5), () {
              try {
                _subscribeToAppointments();
              } catch (_) {}
            });
          }
        });
  }

  void _silentRefresh() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (_isFetching) return;
      _isFetching = true;
      try {
        final result = await _fetchData();
        if (result != null) state = AsyncData(result);
      } catch (_) {
      } finally {
        _isFetching = false;
      }
    });
  }

  Future<PatientState?> _fetchData() async {
    final userId = ref.read(authProvider).userId;
    if (userId == null) return null;

    final profileResult = await _client
        .from('profiles')
        .select('full_name, email, phone, city, avatar_url')
        .eq('id', userId)
        .maybeSingle();

    final now = DateTime.now();
    final appointmentsResult = await _client
        .from('appointments')
        .select(
          'id, doctor_id, scheduled_at, duration, status, is_consultation, notes, doctors(specialty, address, maps_link, photo_url)',
        )
        .eq('patient_id', userId)
        .order('scheduled_at', ascending: false)
        .limit(50);

    final favoritesResult = await _client
        .from('favorites')
        .select('doctor_id')
        .eq('patient_id', userId);

    final doctorIds = appointmentsResult
        .map((r) => r['doctor_id'] as String)
        .toSet()
        .toList();

    final Map<String, Map<String, dynamic>> doctorProfileMap = {};
    if (doctorIds.isNotEmpty) {
      try {
        final profiles = await _client
            .rpc('get_doctor_profiles', params: {'doctor_ids': doctorIds});
        for (final p in profiles) {
          doctorProfileMap[p['id'] as String] = p as Map<String, dynamic>;
        }
      } catch (e) {
        try {
          final profiles = await _client
              .from('profiles')
              .select('id, full_name, avatar_url, phone')
              .inFilter('id', doctorIds);
          for (final p in profiles) {
            doctorProfileMap[p['id'] as String] = p;
          }
        } catch (_) {}
      }
    }

    List<PatientAppointmentViewModel> upcoming = [];
    List<PatientAppointmentViewModel> past = [];
    List<PatientAppointmentViewModel> cancelled = [];

    for (final row in appointmentsResult) {
      final docMap = row['doctors'] as Map<String, dynamic>?;
      final doctorId = row['doctor_id'] as String;
      final profileData = doctorProfileMap[doctorId];

      final doctorName = profileData?['full_name'] as String? ?? 'Docteur';
      final doctorSpecialty = docMap?['specialty'] as String? ?? '';
      final doctorAvatar =
          profileData?['avatar_url'] as String? ?? docMap?['photo_url'] as String?;
      final doctorAddress = docMap?['address'] as String?;
      final doctorPhone = profileData?['phone'] as String?;
      final mapsLink = docMap?['maps_link'] as String?;

      final apt = PatientAppointmentViewModel(
        id: row['id'] as String,
        doctorId: row['doctor_id'] as String,
        doctorName: doctorName,
        doctorSpecialty: doctorSpecialty,
        doctorAvatar: doctorAvatar,
        doctorAddress: doctorAddress,
        doctorPhone: doctorPhone,
        mapsLink: mapsLink,
        dateTime: DateTime.parse(row['scheduled_at'] as String).toLocal(),
        duration: row['duration'] as int? ?? 30,
        status: row['status'] as String? ?? 'upcoming',
        isConsultation: row['is_consultation'] as bool? ?? false,
        notes: row['notes'] as String?,
      );

      if (row['status'] == 'cancelled') {
        cancelled.add(apt);
      } else if (apt.dateTime.isAfter(now)) {
        upcoming.add(apt);
      } else {
        past.add(apt);
      }
    }

    return PatientState(
      name: profileResult?['full_name'] as String? ?? '',
      email: profileResult?['email'] as String? ?? '',
      phone: profileResult?['phone'] as String? ?? '',
      city: profileResult?['city'] as String? ?? '',
      avatarUrl: profileResult?['avatar_url'] as String? ?? '',
      upcomingCount: upcoming.length,
      favoritesCount: (favoritesResult as List).length,
      upcomingAppointments: upcoming,
      pastAppointments: past,
      cancelledAppointments: cancelled,
    );
  }

  Future<PatientState> _load() async {
    if (_isFetching) return state.valueOrNull ?? const PatientState();
    _isFetching = true;
    try {
      final result = await _fetchData();
      return result ?? const PatientState();
    } finally {
      _isFetching = false;
    }
  }

  Future<void> loadPatientData() async {
    state = const AsyncLoading<PatientState>().copyWithPrevious(state);
    state = await AsyncValue.guard(() => _load());
  }

  Future<String?> addAppointment({
    required String doctorId,
    required String doctorName,
    required String doctorSpecialty,
    String? doctorAvatar,
    String? doctorAddress,
    String? doctorPhone,
    String? mapsLink,
    required DateTime scheduledAt,
    required int duration,
    String? notes,
    bool isConsultation = false,
  }) async {
    final currentState = state.valueOrNull ?? const PatientState();
    if (currentState.name.isEmpty) return null;

    try {
      final result = await _client.rpc('book_appointment', params: {
        'p_doctor_id': doctorId,
        'p_scheduled_at': scheduledAt.toUtc().toIso8601String(),
        'p_duration': duration,
        'p_patient_name_snapshot': currentState.name,
        if (currentState.phone.isNotEmpty) 'p_patient_phone_snapshot': currentState.phone,
        'p_is_consultation': isConsultation,
        if (notes != null && notes.isNotEmpty) 'p_notes': notes,
      });

      if (result is! Map || result.containsKey('error')) return null;

      final appointmentId = result['id'] as String;

      final viewModel = PatientAppointmentViewModel(
        id: appointmentId,
        doctorId: doctorId,
        doctorName: doctorName,
        doctorSpecialty: doctorSpecialty,
        doctorAvatar: doctorAvatar,
        doctorAddress: doctorAddress,
        doctorPhone: doctorPhone,
        mapsLink: mapsLink,
        dateTime: scheduledAt,
        duration: duration,
        status: 'upcoming',
        isConsultation: isConsultation,
        notes: notes,
      );

      state = AsyncData(currentState.copyWith(
        upcomingAppointments: [viewModel, ...currentState.upcomingAppointments],
        upcomingCount: currentState.upcomingCount + 1,
      ));

      return appointmentId;
    } catch (e) {
      loadPatientData();
      return null;
    }
  }

  Future<bool> cancelAppointment(String appointmentId) async {
    try {
      await _client
          .from('appointments')
          .update({'status': 'cancelled'})
          .eq('id', appointmentId);
      await loadPatientData();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> refreshAppointments() async {
    await loadPatientData();
  }

  Future<bool> updateProfile({
    required String fullName,
    required String phone,
    required String city,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return false;

      final repo = ProfileRepository(_client);
      final result = await repo.updateProfile(
        userId: userId,
        fullName: fullName,
        phone: phone,
        city: city,
      );

      if (result.isSuccess) {
        await loadPatientData();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
