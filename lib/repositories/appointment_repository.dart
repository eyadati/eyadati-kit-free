import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/appointment.dart';
import '../core/utils/input_validator.dart';
import '../core/utils/security_validator.dart';

class AppointmentRepository {
  final SupabaseClient _client;

  AppointmentRepository(this._client);

  Future<List<Appointment>> getPatientAppointments({
    String? status,
    int? limit,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      if (status != null && !_isValidStatus(status)) {
        return [];
      }

      final query = _client
          .from('appointments')
          .select()
          .eq('patient_id', userId);

      PostgrestFilterBuilder<PostgrestList> filteredQuery;
      
      if (status != null) {
        filteredQuery = query.eq('status', status);
      } else {
        filteredQuery = query;
      }

      if (limit != null) {
        final response = await filteredQuery.limit(limit).order('scheduled_at', ascending: false);
        return (response as List)
            .map((json) => Appointment.fromDatabase(json))
            .toList();
      }

      final response = await filteredQuery.order('scheduled_at', ascending: false);
      return (response as List)
          .map((json) => Appointment.fromDatabase(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Appointment>> getDoctorAppointments({
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      if (status != null && !_isValidStatus(status)) {
        return [];
      }

      var query = _client
          .from('appointments')
          .select()
          .eq('doctor_id', userId);

      if (status != null) {
        query = query.eq('status', status);
      }

      if (fromDate != null) {
        query = query.gte('scheduled_at', fromDate.toUtc().toIso8601String());
      }

      if (toDate != null) {
        query = query.lte('scheduled_at', toDate.toUtc().toIso8601String());
      }

      final response = await query.order('scheduled_at', ascending: true);
      return (response as List)
          .map((json) => Appointment.fromDatabase(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Appointment>> getDoctorAppointmentsByDate(DateTime date) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _client
          .from('appointments')
          .select()
          .eq('doctor_id', userId)
          .gte('scheduled_at', startOfDay.toUtc().toIso8601String())
          .lt('scheduled_at', endOfDay.toUtc().toIso8601String())
          .order('scheduled_at', ascending: true);

      return (response as List)
          .map((json) => Appointment.fromDatabase(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<Appointment?> getAppointment(String appointmentId) async {
    try {
      if (!SecurityValidator.isValidUuid(appointmentId)) {
        return null;
      }

      final response = await _client
          .from('appointments')
          .select()
          .eq('id', appointmentId)
          .maybeSingle();

      if (response == null) return null;
      return Appointment.fromDatabase(response);
    } catch (e) {
      return null;
    }
  }

  Future<AppointmentResult> createAppointment({
    required String doctorId,
    required DateTime scheduledAt,
    required int duration,
    required String patientName,
    String? patientPhone,
    bool isConsultation = false,
    String? notes,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return AppointmentResult.failure('User not authenticated');
      }

      if (!SecurityValidator.isValidUuid(doctorId)) {
        return AppointmentResult.failure('Invalid doctor ID');
      }

      final dateError = InputValidator.validateAppointmentDate(scheduledAt);
      if (dateError != null) {
        return AppointmentResult.failure(dateError);
      }

      final durationError = InputValidator.validateDuration(duration);
      if (durationError != null) {
        return AppointmentResult.failure(durationError);
      }

      final nameError = InputValidator.validateRequired(patientName, 'Patient name');
      if (nameError != null) {
        return AppointmentResult.failure(nameError);
      }

      if (patientPhone != null && patientPhone.isNotEmpty) {
        final phoneError = InputValidator.validatePhone(patientPhone);
        if (phoneError != null) {
          return AppointmentResult.failure(phoneError);
        }
      }

      final sanitizedName = SecurityValidator.sanitizeHtml(patientName.trim());
      final sanitizedPhone = patientPhone?.trim();
      final sanitizedNotes = notes?.trim();

      final data = {
        'doctor_id': doctorId,
        'patient_id': userId,
        'scheduled_at': scheduledAt.toUtc().toIso8601String(),
        'duration': duration,
        'status': 'upcoming',
        'booking_type': 'online',
        'is_consultation': isConsultation,
        'patient_name_snapshot': sanitizedName,
        'patient_phone_snapshot': sanitizedPhone,
        'notes': sanitizedNotes,
      };

      final response = await _client
          .from('appointments')
          .insert(data)
          .select()
          .maybeSingle();

      if (response == null) {
        return AppointmentResult.failure('Failed to create appointment');
      }

      return AppointmentResult.success(Appointment.fromDatabase(response));
    } catch (e) {
      final errorMsg = e.toString().toLowerCase();
      if (errorMsg.contains('not available') || errorMsg.contains('conflict')) {
        return AppointmentResult.failure('This time slot is not available');
      }
      if (errorMsg.contains('not available for booking')) {
        return AppointmentResult.failure('Doctor is not available for booking');
      }
      if (errorMsg.contains('invalid appointment date')) {
        return AppointmentResult.failure('Invalid appointment date. Must be at least 30 minutes in the future.');
      }
      if (errorMsg.contains('invalid duration')) {
        return AppointmentResult.failure('Invalid duration. Must be between 5 and 180 minutes.');
      }
      return AppointmentResult.failure('Failed to create appointment');
    }
  }

  Future<AppointmentResult> createManualAppointment({
    required String doctorId,
    required DateTime scheduledAt,
    required int duration,
    required String patientName,
    String? patientPhone,
    String? notes,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return AppointmentResult.failure('User not authenticated');
      }

      if (!SecurityValidator.isValidUuid(doctorId)) {
        return AppointmentResult.failure('Invalid doctor ID');
      }

      if (!SecurityValidator.isValidDoctorOwnership(userId, doctorId)) {
        return AppointmentResult.failure('Only doctors can create manual appointments');
      }

      final dateError = InputValidator.validateAppointmentDate(scheduledAt);
      if (dateError != null) {
        return AppointmentResult.failure(dateError);
      }

      final durationError = InputValidator.validateDuration(duration);
      if (durationError != null) {
        return AppointmentResult.failure(durationError);
      }

      final nameError = InputValidator.validateRequired(patientName, 'Patient name');
      if (nameError != null) {
        return AppointmentResult.failure(nameError);
      }

      if (patientPhone != null && patientPhone.isNotEmpty) {
        final phoneError = InputValidator.validatePhone(patientPhone);
        if (phoneError != null) {
          return AppointmentResult.failure(phoneError);
        }
      }

      final sanitizedName = SecurityValidator.sanitizeHtml(patientName.trim());
      final sanitizedPhone = patientPhone?.trim();
      final sanitizedNotes = notes?.trim();

      final data = {
        'doctor_id': doctorId,
        'scheduled_at': scheduledAt.toUtc().toIso8601String(),
        'duration': duration,
        'status': 'upcoming',
        'booking_type': 'manual',
        'is_consultation': false,
        'patient_name_snapshot': sanitizedName,
        'patient_phone_snapshot': sanitizedPhone,
        'notes': sanitizedNotes,
      };

      final response = await _client
          .from('appointments')
          .insert(data)
          .select()
          .maybeSingle();

      if (response == null) {
        return AppointmentResult.failure('Failed to create manual appointment');
      }

      return AppointmentResult.success(Appointment.fromDatabase(response));
    } catch (e) {
      return AppointmentResult.failure('Failed to create manual appointment');
    }
  }

  Future<AppointmentResult> cancelAppointment(String appointmentId) async {
    try {
      if (!SecurityValidator.isValidUuid(appointmentId)) {
        return AppointmentResult.failure('Invalid appointment ID');
      }

      final appointment = await getAppointment(appointmentId);
      if (appointment == null) {
        return AppointmentResult.failure('Appointment not found');
      }

      if (appointment.status != AppointmentStatus.upcoming) {
        return AppointmentResult.failure('Can only cancel upcoming appointments');
      }

      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return AppointmentResult.failure('User not authenticated');
      }

      if (!SecurityValidator.canModifyAppointment(userId, appointment.doctorId, appointment.patientId, 'upcoming')) {
        return AppointmentResult.failure('You can only cancel your own appointments');
      }

      await _client
          .from('appointments')
          .update({'status': 'cancelled'})
          .eq('id', appointmentId)
          .eq('status', 'upcoming');
      
      return AppointmentResult.success(appointment);
    } catch (e) {
      return AppointmentResult.failure('Failed to cancel appointment');
    }
  }

  Future<AppointmentResult> updateAppointmentStatus(
    String appointmentId,
    AppointmentStatus status,
  ) async {
    try {
      if (!SecurityValidator.isValidUuid(appointmentId)) {
        return AppointmentResult.failure('Invalid appointment ID');
      }

      final appointment = await getAppointment(appointmentId);
      if (appointment == null) {
        return AppointmentResult.failure('Appointment not found');
      }

      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return AppointmentResult.failure('User not authenticated');
      }

      if (!SecurityValidator.isValidDoctorOwnership(userId, appointment.doctorId)) {
        return AppointmentResult.failure('Only doctors can update appointment status');
      }

      await _client
          .from('appointments')
          .update({'status': status.name})
          .eq('id', appointmentId);
      
      return AppointmentResult.success(appointment);
    } catch (e) {
      return AppointmentResult.failure('Failed to update appointment');
    }
  }

  Future<List<TimeSlot>> generateAvailableSlots({
    required String doctorId,
    required DateTime date,
    required int durationMinutes,
  }) async {
    try {
      if (!SecurityValidator.isValidUuid(doctorId)) {
        return [];
      }

      final durationError = InputValidator.validateDuration(durationMinutes);
      if (durationError != null) {
        return [];
      }

      final dayOfWeek = _getDayOfWeek(date);
      final schedule = await _client
          .from('doctor_schedule')
          .select('start_time, end_time, break_start, break_end')
          .eq('doctor_id', doctorId)
          .eq('day_of_week', dayOfWeek)
          .maybeSingle();

      if (schedule == null) return [];

      final startMinutes = schedule['start_time'] as int;
      final endMinutes = schedule['end_time'] as int;
      final breakStart = schedule['break_start'] as int?;
      final breakEnd = schedule['break_end'] as int?;

      final existingAppointments = await getDoctorAppointmentsByDate(date);

      final slots = <TimeSlot>[];

      for (var m = startMinutes; m < endMinutes; m += durationMinutes) {
        final slotEndM = m + durationMinutes;
        if (slotEndM > endMinutes) continue;

        final startTime = DateTime(
          date.year, date.month, date.day, m ~/ 60, m % 60,
        );
        final endTime = DateTime(
          date.year, date.month, date.day, slotEndM ~/ 60, slotEndM % 60,
        );

        bool isBreak = false;
        if (breakStart != null && breakEnd != null) {
          if ((m >= breakStart && m < breakEnd) ||
              (slotEndM > breakStart && slotEndM <= breakEnd)) {
            isBreak = true;
          }
        }

        bool isBooked = existingAppointments.any((apt) {
          final aptEnd = apt.scheduledAt.add(Duration(minutes: apt.duration));
          return startTime.isBefore(aptEnd) && endTime.isAfter(apt.scheduledAt);
        });

        slots.add(TimeSlot(
          startTime: startTime,
          endTime: endTime,
          durationMinutes: durationMinutes,
          isAvailable: !isBreak && !isBooked && startTime.isAfter(DateTime.now()),
        ));
      }

      return slots;
    } catch (e) {
      return [];
    }
  }

  int _getDayOfWeek(DateTime date) {
    return date.weekday == DateTime.sunday ? 0 : date.weekday;
  }

  bool _isValidStatus(String status) {
    return ['upcoming', 'completed', 'cancelled', 'absent'].contains(status);
  }
}

class AppointmentResult {
  final bool isSuccess;
  final Appointment? appointment;
  final String? error;

  AppointmentResult._({
    required this.isSuccess,
    this.appointment,
    this.error,
  });

  factory AppointmentResult.success(Appointment appointment) {
    return AppointmentResult._(isSuccess: true, appointment: appointment);
  }

  factory AppointmentResult.failure(String error) {
    return AppointmentResult._(isSuccess: false, error: error);
  }
}
