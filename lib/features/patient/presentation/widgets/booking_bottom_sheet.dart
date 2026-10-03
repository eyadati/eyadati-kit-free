import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/utils/supabase_client.dart';
import '../../../../core/utils/phone_launcher.dart';
import 'package:eyadati_kit/core/engine/availability_service.dart' show ValidStart;
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:eyadati_kit/models/doctor.dart';
import '../providers/patient_provider.dart';
import 'package:eyadati_kit/l10n/app_localizations.dart';

class BookingDialog extends ConsumerStatefulWidget {
  final Doctor doctor;

  const BookingDialog({super.key, required this.doctor});

  @override
  ConsumerState<BookingDialog> createState() => _BookingDialogState();
}

class _BookingDialogState extends ConsumerState<BookingDialog>
    with WidgetsBindingObserver {
  bool _showBookingChoice = true;
  DateTime? _selectedDate;
  TimeOfDay? _selectedSlot;
  bool _isLoading = false;
  bool _isConsultation = false;
  List<ValidStart> _availableSlots = [];

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _selectedDate != null) {
      _loadSlotsForDate(_selectedDate!);
    }
  }

  List<DateTime> get _next14Days {
    final today = DateTime.now();
    return List.generate(
      14,
      (index) => DateTime(today.year, today.month, today.day + index + 1),
    );
  }

  String _localizedShortDay(AppLocalizations l10n, DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:    return l10n.daysShortMon;
      case DateTime.tuesday:   return l10n.daysShortTue;
      case DateTime.wednesday: return l10n.daysShortWed;
      case DateTime.thursday:  return l10n.daysShortThu;
      case DateTime.friday:    return l10n.daysShortFri;
      case DateTime.saturday:  return l10n.daysShortSat;
      case DateTime.sunday:    return l10n.daysShortSun;
      default:                 return '';
    }
  }

  String _localizedShortMonth(AppLocalizations l10n, DateTime date, BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return DateFormat('MMM', locale).format(date);
  }

  Future<void> _loadSlotsForDate(DateTime date) async {
    setState(() => _isLoading = true);
    try {
      final doctorData = await SupabaseInitializer.client
          .from('doctors')
          .select('consultation_duration, appointment_duration')
          .eq('id', widget.doctor.id)
          .single();

      final effectiveDuration = (doctorData['appointment_duration'] as int? ?? 20);

      final slotsResult = await SupabaseInitializer.client.rpc(
        'get_available_slots_v2',
        params: {
          'p_doctor_id': widget.doctor.id,
          'p_date': DateTime(date.year, date.month, date.day).toIso8601String().split('T')[0],
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
      setState(() {
        _availableSlots = [];
        _isLoading = false;
      });
    }
  }

  Future<bool> _isSlotStillAvailable(DateTime scheduledAt, int duration) async {
    try {
      final dateStr = DateTime(scheduledAt.year, scheduledAt.month, scheduledAt.day)
          .toIso8601String()
          .split('T')[0];
      final slotsResult = await SupabaseInitializer.client.rpc(
        'get_available_slots_v2',
        params: {
          'p_doctor_id': widget.doctor.id,
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

  Widget _buildBookingChoice() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.lg),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(LucideIcons.calendarPlus, size: 32, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Réserver avec ${widget.doctor.name}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            widget.doctor.specialty,
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final phone = widget.doctor.phone;
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
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Future<void> _confirmBooking() async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedDate == null || _selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.bookingSelectDateError),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = ref.read(authProvider).userId;

      if (userId == null) {
        throw Exception(l10n.bookingUserNotConnectedError);
      }

      final scheduledAt = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedSlot!.hour,
        _selectedSlot!.minute,
      );

      final duration = _isConsultation ? widget.doctor.consultationDuration : widget.doctor.appointmentDuration;

      final stillAvailable = await _isSlotStillAvailable(scheduledAt, duration);
      if (!stillAvailable) {
        setState(() => _isLoading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.bookingSlotUnavailable),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      final appointmentId = await ref.read(patientProvider.notifier).addAppointment(
        doctorId: widget.doctor.id,
        doctorName: widget.doctor.name,
        doctorSpecialty: widget.doctor.specialty,
        doctorAvatar: widget.doctor.photoUrl,
        doctorAddress: widget.doctor.address,
        doctorPhone: widget.doctor.phone,
        mapsLink: widget.doctor.mapsLink,
        scheduledAt: scheduledAt,
        duration: duration,
        isConsultation: _isConsultation,
      );

      if (appointmentId == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorsTryAgainLater),
            backgroundColor: AppColors.error,
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      if (!mounted) return;

      Navigator.pop(context);
      Navigator.pop(context);

      _showSuccessDialog(scheduledAt, duration);
    } catch (_) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorsTryAgainLater),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showSuccessDialog(DateTime scheduledAt, int duration) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xxl),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.check,
                  size: 48,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.bookingSuccess,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.bookingSuccessWithDoctor(widget.doctor.name),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: l10n.bookingBackHome,
                  onPressed: () {
                    Navigator.pop(ctx);
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: _showBookingChoice
            ? _buildBookingChoice()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: AppColors.divider),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(AppRadius.lg),
                                      ),
                                      child: Center(
                                        child: Text(
                                          widget.doctor.name.isNotEmpty
                                              ? widget.doctor.name.substring(0, 2).toUpperCase()
                                              : 'DR',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.doctor.name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          Text(
                                            widget.doctor.specialty,
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
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                            child: Row(
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
                          ),
                          Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.bookingSelectDate,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                SizedBox(
                                  height: 80,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _next14Days.length,
                                    itemBuilder: (context, index) {
                                      final date = _next14Days[index];
                                      final isSelected = _selectedDate != null &&
                                          date.year == _selectedDate!.year &&
                                          date.month == _selectedDate!.month &&
                                          date.day == _selectedDate!.day;

                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedDate = date;
                                            _selectedSlot = null;
                                          });
                                          _loadSlotsForDate(date);
                                        },
                                        child: Container(
                                          width: 56,
                                          margin: const EdgeInsets.only(right: AppSpacing.sm),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? AppColors.primary
                                                : AppColors.background,
                                            borderRadius: BorderRadius.circular(AppRadius.lg),
                                            border: Border.all(
                                              color: isSelected
                                                  ? AppColors.primary
                                                  : AppColors.border,
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                _localizedShortDay(l10n, date),
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: isSelected
                                                      ? AppColors.white
                                                      : AppColors.textSecondary,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                DateFormat('dd').format(date),
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700,
                                                  color: isSelected
                                                      ? AppColors.white
                                                      : AppColors.textPrimary,
                                                ),
                                              ),
                                              Text(
                                                _localizedShortMonth(l10n, date, context),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: isSelected
                                                      ? AppColors.white.withValues(alpha: 0.8)
                                                      : AppColors.textHint,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_selectedDate != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.bookingSelectTime,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  if (_isLoading)
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 32),
                                      child: Center(child: CircularProgressIndicator()),
                                    )
                                  else if (_availableSlots.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 32),
                                      child: Center(
                                        child: Text(
                                          l10n.bookingNoSlotsAvailable,
                                          style: TextStyle(color: AppColors.textHint),
                                        ),
                                      ),
                                    )
                                  else
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: _availableSlots.map((slot) {
                                        final slotTime = TimeOfDay(
                                          hour: slot.minute ~/ 60,
                                          minute: slot.minute % 60,
                                        );
                                        final isSelected = _selectedSlot != null &&
                                            _selectedSlot!.hour == slotTime.hour &&
                                            _selectedSlot!.minute == slotTime.minute;

                                        return GestureDetector(
                                          onTap: () => setState(() => _selectedSlot = slotTime),
                                          child: Container(
                                            width: 72,
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppColors.primary
                                                  : AppColors.background,
                                              borderRadius: BorderRadius.circular(AppRadius.md),
                                              border: Border.all(
                                                color: isSelected
                                                    ? AppColors.primary
                                                    : AppColors.border,
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${slotTime.hour.toString().padLeft(2, '0')}:${slotTime.minute.toString().padLeft(2, '0')}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: isSelected
                                                      ? AppColors.white
                                                      : AppColors.textPrimary,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  const SizedBox(height: AppSpacing.md),
                                ],
                              ),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 32),
                              child: Center(
                                child: Text(
                                  l10n.bookingSelectDateHint,
                                  style: TextStyle(
                                    color: AppColors.textHint,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Container(
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
                        label: _isLoading
                            ? l10n.bookingLoading
                            : l10n.bookingConfirmButton,
                        isLoading: _isLoading,
                        onPressed: _selectedDate != null && _selectedSlot != null
                            ? _confirmBooking
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
