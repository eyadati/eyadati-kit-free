import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/schedule_slot_model.dart';

class ScheduleRepository {
  final SupabaseClient _client;

  ScheduleRepository(this._client);

  Future<List<ScheduleSlot>> getDoctorSchedule(String doctorId) async {
    final response = await _client
        .from('doctor_schedule')
        .select()
        .eq('doctor_id', doctorId)
        .eq('is_active', true)
        .order('day_of_week')
        .order('start_time');

    return (response as List)
        .map((json) => ScheduleSlot.fromJson(json))
        .toList();
  }

  Future<List<ScheduleSlot>> getDoctorScheduleByDay(String doctorId, int dayOfWeek) async {
    final response = await _client
        .from('doctor_schedule')
        .select()
        .eq('doctor_id', doctorId)
        .eq('day_of_week', dayOfWeek)
        .eq('is_active', true)
        .order('start_time');

    return (response as List)
        .map((json) => ScheduleSlot.fromJson(json))
        .toList();
  }

  Future<ScheduleSlot> createScheduleSlot({
    required String doctorId,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
  }) async {
    final response = await _client.from('doctor_schedule').insert({
      'doctor_id': doctorId,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
    }).select().single();

    return ScheduleSlot.fromJson(response);
  }

  Future<ScheduleSlot> updateScheduleSlot({
    required String slotId,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    bool? isActive,
  }) async {
    final Map<String, dynamic> updates = {};
    if (dayOfWeek != null) updates['day_of_week'] = dayOfWeek;
    if (startTime != null) updates['start_time'] = startTime;
    if (endTime != null) updates['end_time'] = endTime;
    if (isActive != null) updates['is_active'] = isActive;

    final response = await _client
        .from('doctor_schedule')
        .update(updates)
        .eq('id', slotId)
        .select()
        .single();

    return ScheduleSlot.fromJson(response);
  }

  Future<void> deleteScheduleSlot(String slotId) async {
    await _client.from('doctor_schedule').delete().eq('id', slotId);
  }

  Future<void> deleteAllDoctorSchedule(String doctorId) async {
    await _client.from('doctor_schedule').delete().eq('doctor_id', doctorId);
  }

  Future<void> bulkCreateSchedule({
    required String doctorId,
    required List<Map<String, dynamic>> slots,
  }) async {
    final slotsWithDoctor = slots.map((slot) => {
      ...slot,
      'doctor_id': doctorId,
    }).toList();

    await _client.from('doctor_schedule').insert(slotsWithDoctor);
  }

  Future<bool> checkSlotAvailability({
    required String doctorId,
    required DateTime slotTime,
    required int duration,
  }) async {
    final response = await _client.rpc(
      'check_schedule_slot_availability',
      params: {
        'doctor_uuid': doctorId,
        'slot_time': slotTime.toIso8601String(),
        'slot_duration': duration,
      },
    );
    return response as bool;
  }
}