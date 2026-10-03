import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:eyadati_kit/models/appointment_data.dart';
import 'package:eyadati_kit/models/patient_summary.dart';
import 'package:eyadati_kit/core/utils/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'patient_history_provider.g.dart';

class PatientHistoryState {
  final List<PatientSummary> patients;
  final String searchQuery;
  final Set<String> expandedPatientIds;

  const PatientHistoryState({
    this.patients = const [],
    this.searchQuery = '',
    this.expandedPatientIds = const {},
  });

  List<PatientSummary> get filteredPatients {
    if (searchQuery.isEmpty) return patients;
    final q = searchQuery.toLowerCase();
    return patients.where((p) {
      return p.patientName.toLowerCase().contains(q) ||
          (p.patientPhone?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  PatientHistoryState copyWith({
    List<PatientSummary>? patients,
    String? searchQuery,
    Set<String>? expandedPatientIds,
  }) {
    return PatientHistoryState(
      patients: patients ?? this.patients,
      searchQuery: searchQuery ?? this.searchQuery,
      expandedPatientIds: expandedPatientIds ?? this.expandedPatientIds,
    );
  }
}

@riverpod
class PatientHistory extends _$PatientHistory {
  @override
  Future<PatientHistoryState> build() async {
    return _loadPatients();
  }

  SupabaseClient get _client => SupabaseInitializer.client;

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _loadPatients());
  }

  void setSearchQuery(String query) {
    state = AsyncData(state.requireValue.copyWith(searchQuery: query));
  }

  Future<PatientHistoryState> _loadPatients() async {
    final user = _client.auth.currentUser;
    final data = await _client
        .from('appointments')
        .select('''
          id,
          scheduled_at,
          duration,
          status,
          is_consultation,
          booking_type,
          notes,
          patient_id,
          patient_name_snapshot,
          patient_phone_snapshot,
          patient:profiles!patient_id (
            id,
            full_name,
            phone,
            avatar_url
          )
        ''')
        .eq('doctor_id', user!.id)
        .eq('booking_type', 'online')
        .not('patient_id', 'is', null)
        .order('scheduled_at', ascending: false);

    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final row in data as List) {
      final pid = row['patient_id'] as String;
      grouped.putIfAbsent(pid, () => []);
      grouped[pid]!.add(row);
    }

    final summaries = <PatientSummary>[];
    for (final entry in grouped.entries) {
      final rows = entry.value;
      final first = rows.first;
      final patientData = first['patient'] as Map<String, dynamic>?;

      final visits = rows.map((r) {
        final start = DateTime.parse(r['scheduled_at'] as String).toLocal();
        final dur = r['duration'] as int? ?? 30;
        return AppointmentData(
          id: r['id'] as String,
          startTime: start,
          endTime: start.add(Duration(minutes: dur)),
          patientName: patientData?['full_name'] as String? ??
              (r['patient_name_snapshot'] as String? ?? ''),
          patientAvatar: patientData?['avatar_url'] as String?,
          patientPhone: patientData?['phone'] as String? ??
              (r['patient_phone_snapshot'] as String?),
          status: r['status'] as String,
          isConsultation: r['is_consultation'] as bool? ?? false,
          notes: r['notes'] as String?,
          duration: dur,
          patientId: entry.key,
          bookingType: 'online',
          doctorId: user.id,
        );
      }).toList();

      final lastVisit = rows
          .map((r) => DateTime.parse(r['scheduled_at'] as String).toLocal())
          .reduce((a, b) => a.isAfter(b) ? a : b);

      summaries.add(PatientSummary(
        patientId: entry.key,
        patientName: patientData?['full_name'] as String? ??
            (first['patient_name_snapshot'] as String? ?? 'Patient'),
        patientPhone: patientData?['phone'] as String? ??
            (first['patient_phone_snapshot'] as String?),
        patientAvatar: patientData?['avatar_url'] as String?,
        visitCount: rows.length,
        lastVisitDate: lastVisit,
        visits: visits,
      ));
    }

    summaries.sort((a, b) => b.lastVisitDate.compareTo(a.lastVisitDate));

    return PatientHistoryState(
      patients: summaries,
    );
  }

  void toggleExpand(String patientId) {
    final current = state.requireValue;
    final expanded = Set<String>.from(current.expandedPatientIds);
    if (expanded.contains(patientId)) {
      expanded.remove(patientId);
    } else {
      expanded.add(patientId);
    }
    state = AsyncData(current.copyWith(expandedPatientIds: expanded));
  }
}
