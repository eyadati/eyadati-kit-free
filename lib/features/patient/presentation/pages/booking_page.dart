import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:eyadati_kit/core/routing/route_names.dart';
import 'package:eyadati_kit/core/constants/app_colors.dart';
import 'package:eyadati_kit/core/constants/app_spacing.dart';
import 'package:eyadati_kit/core/widgets/buttons/primary_button.dart';
import 'package:eyadati_kit/core/utils/supabase_client.dart';
import 'package:eyadati_kit/core/utils/phone_launcher.dart';
import 'package:eyadati_kit/features/auth/presentation/providers/auth_provider.dart';
import 'package:eyadati_kit/features/patient/presentation/providers/doctors_provider.dart';
import 'package:eyadati_kit/features/patient/presentation/providers/patient_provider.dart';
import 'package:eyadati_kit/models/doctor.dart';
import 'package:eyadati_kit/core/engine/availability_service.dart' show ValidStart;
import 'package:eyadati_kit/l10n/app_localizations.dart';

class BookingPage extends ConsumerStatefulWidget {
  final String doctorId;

  const BookingPage({super.key, required this.doctorId});

  @override
  ConsumerState<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends ConsumerState<BookingPage> with WidgetsBindingObserver {
  bool _showBookingChoice = true;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay? _selectedTime;
  final _notesController = TextEditingController();
  bool _isLoading = false;
  bool _isConsultation = false;
  List<ValidStart> _availableSlots = [];

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadAvailability();
    }
  }

  Future<void> _loadAvailability() async {
    setState(() => _isLoading = true);
    try {
      final doctorData = await SupabaseInitializer.client
          .from('doctors')
          .select('consultation_duration, appointment_duration')
          .eq('id', widget.doctorId)
          .single();

      final effectiveDuration = doctorData['appointment_duration'] as int? ?? 20;

      final dateStr = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day,
      ).toIso8601String().split('T')[0];

      final slotsResult = await SupabaseInitializer.client.rpc(
        'get_available_slots_v2',
        params: {
          'p_doctor_id': widget.doctorId,
          'p_date': dateStr,
          'p_duration': effectiveDuration,
        },
      );

      final List<ValidStart> slots = (slotsResult as List).map((s) {
        final data = s as Map<String, dynamic>;
        return ValidStart(data['slot_start_minute'] as int, data['slot_duration'] as int);
      }).toList();

      setState(() {
        _availableSlots = slots;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadAvailability();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      locale: Localizations.localeOf(context),
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _loadAvailability();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _notesController.dispose();
    super.dispose();
  }

  String _getInitials(String name) {
    if (name.isEmpty || name.length < 2) return 'DR';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }

  Widget _buildBookingChoice(AppLocalizations l10n, Doctor doctor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(LucideIcons.calendarPlus, size: 36, color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Réserver avec ${doctor.name}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              doctor.specialty,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final phone = doctor.phone;
                  if (phone != null && phone.isNotEmpty) {
                    final launched = await launchPhoneUrl(phone, context);
                    if (!launched && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.bookingPhoneUnavailable)),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.bookingPhoneUnavailable)),
                    );
                  }
                },
                icon: const Icon(LucideIcons.phone, size: 20),
                label: Text(l10n.bookingCallOffice),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _showBookingChoice = false),
                icon: const Icon(LucideIcons.calendar, size: 20),
                label: Text(l10n.bookingBookOnline),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  Future<bool> _isSlotStillAvailable(DateTime scheduledAt, int duration) async {
    try {
      final dateStr = DateTime(scheduledAt.year, scheduledAt.month, scheduledAt.day)
          .toIso8601String()
          .split('T')[0];
      final slotsResult = await SupabaseInitializer.client.rpc(
        'get_available_slots_v2',
        params: {
          'p_doctor_id': widget.doctorId,
          'p_date': dateStr,
          'p_duration': duration,
        },
      );
      final startMinute = scheduledAt.hour * 60 + scheduledAt.minute;
      return (slotsResult as List).any((s) {
        final data = s as Map<String, dynamic>;
        return data['slot_start_minute'] as int == startMinute;
      });
    } catch (_) {
      return true;
    }
  }

  Future<void> _confirmBooking() async {
    final l10n = AppLocalizations.of(context)!;

    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.bookingSelectTimeError)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = ref.read(authProvider).userId;
      if (userId == null) {
        setState(() => _isLoading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.bookingUserNotConnectedError)),
        );
        return;
      }

      final scheduledAt = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final doctorsState = ref.read(doctorsProvider);
      final doctor = doctorsState.doctors.firstWhere(
        (d) => d.id == widget.doctorId,
        orElse: () => Doctor(
          id: widget.doctorId,
          name: l10n.roleDoctor,
          specialty: l10n.doctorsFilterSpecialty,
          address: '',
        ),
      );
      final duration = _isConsultation ? doctor.consultationDuration : doctor.appointmentDuration;

      final stillAvailable = await _isSlotStillAvailable(scheduledAt, duration);
      if (!stillAvailable) {
        setState(() => _isLoading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.bookingSlotUnavailable)),
        );
        return;
      }

      final appointmentId = await ref.read(patientProvider.notifier).addAppointment(
        doctorId: widget.doctorId,
        doctorName: doctor.name,
        doctorSpecialty: doctor.specialty,
        doctorAvatar: doctor.photoUrl,
        doctorAddress: doctor.address,
        doctorPhone: doctor.phone,
        mapsLink: doctor.mapsLink,
        scheduledAt: scheduledAt,
        duration: duration,
        isConsultation: _isConsultation,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      if (appointmentId == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorsTryAgainLater)),
        );
        setState(() => _isLoading = false);
        return;
      }

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 48,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.bookingSuccess,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.bookingSuccessMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      if (context.mounted) {
                        context.go(RouteNames.patientAppointments);
                      }
                    },
                    child: Text(l10n.bookingSuccessViewButton),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (_) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorsTryAgainLater)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final doctorsState = ref.watch(doctorsProvider);
    final doctor = doctorsState.doctors.firstWhere(
      (d) => d.id == widget.doctorId,
      orElse: () =>
          Doctor(id: widget.doctorId, name: l10n.roleDoctor, specialty: l10n.doctorsFilterSpecialty, address: ''),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.doctorDetailsBookNow),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _showBookingChoice
          ? _buildBookingChoice(l10n, doctor)
          : SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      _getInitials(doctor.name),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          doctor.specialty,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _isConsultation = false),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: !_isConsultation
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: !_isConsultation
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            LucideIcons.user,
                            color: !_isConsultation
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'RDV',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: !_isConsultation
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _isConsultation = true),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isConsultation
                            ? AppColors.consultationColor.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isConsultation
                              ? AppColors.consultationColor
                              : AppColors.border,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            LucideIcons.video,
                            color: _isConsultation
                                ? AppColors.consultationColor
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.bookingConsultation,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _isConsultation
                                  ? AppColors.consultationColor
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.bookingSelectDate,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.sm),
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isToday(_selectedDate) ? AppColors.primary : AppColors.border,
                    width: _isToday(_selectedDate) ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: _isToday(_selectedDate) ? AppColors.primary : AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _isToday(_selectedDate) ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                    if (_isToday(_selectedDate)) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          l10n.bookingToday,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.bookingSelectTime,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_availableSlots.isEmpty)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isToday(_selectedDate) ? Icons.access_time : Icons.event_busy,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        _isToday(_selectedDate)
                            ? l10n.bookingNoSlotsToday
                            : l10n.bookingNoSlotsDate,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _availableSlots.map((slot) {
                final isSelected =
                    _selectedTime?.hour == (slot.minute ~/ 60) &&
                    _selectedTime?.minute == (slot.minute % 60);
                final time = TimeOfDay(
                  hour: slot.minute ~/ 60,
                  minute: slot.minute % 60,
                );
                return GestureDetector(
                  onTap: () => setState(() => _selectedTime = time),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.card,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Text(
                      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.bookingAddNotes,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l10n.bookingNotesHint,
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.card,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: PrimaryButton(
            label: _isLoading ? l10n.bookingLoading : l10n.bookingConfirmButton,
            onPressed: _isLoading ? null : _confirmBooking,
          ),
        ),
      ),
    );
  }
}
