import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:intl/intl.dart';
import 'package:eyadati_kit/core/constants/app_colors.dart';
import 'package:eyadati_kit/core/constants/app_spacing.dart';
import 'package:eyadati_kit/core/utils/time_utils.dart';
import 'package:eyadati_kit/core/widgets/buttons/primary_button.dart';
import 'package:eyadati_kit/core/widgets/inputs/app_text_field.dart';
import '../../../../models/appointment_data.dart';
import '../providers/doctor_provider.dart';

class DoctorAddAppointmentDialog extends ConsumerStatefulWidget {
  final DateTime initialDate;
  final DateTime? initialTime;

  const DoctorAddAppointmentDialog({
    super.key,
    required this.initialDate,
    this.initialTime,
  });

  @override
  ConsumerState<DoctorAddAppointmentDialog> createState() =>
      _DoctorAddAppointmentDialogState();
}

class _DoctorAddAppointmentDialogState
    extends ConsumerState<DoctorAddAppointmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _phoneFocusNode = FocusNode();
  late DateTime _selectedDate;
  TimeOfDay? _selectedSlot;
  int? _selectedDuration;
  bool _isConsultation = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(
      widget.initialDate.year,
      widget.initialDate.month,
      widget.initialDate.day,
    );
    _selectedDuration = 20;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoSelectFirstSlot();
    });
  }

  void _autoSelectFirstSlot() {
    final doctorState = ref.read(doctorProvider);
    final validStarts = doctorState.availabilityService.getValidStarts(
      _selectedDate,
      doctorState.allAppointments,
      duration: _selectedDuration,
      isConsultation: _isConsultation,
    );
    if (validStarts.isNotEmpty) {
      final firstSlot = validStarts.first;
      setState(() {
        _selectedSlot = TimeOfDay(
          hour: firstSlot.minute ~/ 60,
          minute: firstSlot.minute % 60,
        );
        _selectedDuration = firstSlot.duration;
      });
    }
  }

  void _toggleConsultation(bool val) {
    setState(() {
      _isConsultation = val;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  int _getSlotIntervalMinutes() {
    return 30;
  }

  List<int> _getAvailableDurations(
    DoctorState doctorState,
    int remainingMinutes,
  ) {
    final consultationDuration = doctorState.consultationDuration;

    // Static duration options - always show all options
    final List<int> allOptions = [10, 20, 30, 40, 50, 60];

    // Add consultation as a separate option (shown as "Consultation" in UI)
    // Filter only what fits in remaining time, but include consultation if time allows
    final filtered = allOptions.where((d) => d <= remainingMinutes).toList();

    // Always include consultation option if there's enough time
    if (remainingMinutes >= consultationDuration) {
      // Add consultation - will be shown with special label in UI
    }

    filtered.sort();
    return filtered;
  }

  String _formatDate(DateTime date) {
    return DateFormat('d MMMM yyyy', 'fr').format(date);
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, picked.day);
        _selectedSlot = null;
        _selectedDuration = null;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final doctorState = ref.read(doctorProvider);

    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un créneau'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (_selectedDuration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une durée'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final effectiveDuration = _isConsultation
        ? doctorState.consultationDuration
        : _selectedDuration!;

    final scheduledAt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedSlot!.hour,
      _selectedSlot!.minute,
    );

    final selectedSlotMinutes =
        _selectedSlot!.hour * 60 + _selectedSlot!.minute;
    final endMinutes = selectedSlotMinutes + effectiveDuration;
    final conflicts = doctorState.allAppointments.where((apt) {
      if (apt.startTime.year != _selectedDate.year ||
          apt.startTime.month != _selectedDate.month ||
          apt.startTime.day != _selectedDate.day)
        return false;
      final aptStart = apt.startTime.hour * 60 + apt.startTime.minute;
      final aptEnd =
          apt.startTime.hour * 60 + apt.startTime.minute + apt.duration;
      return selectedSlotMinutes < aptEnd && endMinutes > aptStart;
    }).toList();

    if (conflicts.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ce créneau est déjà occupé par ${conflicts.first.patientName}',
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(content: Text('Création en cours...'), duration: const Duration(seconds: 30)),
    );

    final success = await ref
        .read(doctorProvider.notifier)
        .createAppointment(
          scheduledAt: scheduledAt,
          duration: _selectedDuration,
          isConsultation: _isConsultation,
          patientName: _nameController.text.trim(),
          patientPhone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
        );

    if (mounted) {
      messenger.hideCurrentSnackBar();
      if (success) {
        Navigator.pop(context, true);
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              _isConsultation ? 'Consultation créée' : 'Rendez-vous créé',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la création'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctorState = ref.watch(doctorProvider);
    final dayAppointments = doctorState.allAppointments.where((apt) {
      return apt.startTime.year == _selectedDate.year &&
          apt.startTime.month == _selectedDate.month &&
          apt.startTime.day == _selectedDate.day;
    }).toList();

    final slotStart = _selectedSlot != null
        ? DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
            _selectedSlot!.hour,
            _selectedSlot!.minute,
          )
        : null;

    final remainingMinutes = slotStart != null
        ? _calculateRemainingMinutes(slotStart, dayAppointments)
        : _getSlotIntervalMinutes();

    final availableDurations = _getAvailableDurations(
      doctorState,
      remainingMinutes,
    );

    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth > 768 ? screenWidth * 0.5 : screenWidth * 0.95;

    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: MediaQuery.of(context).size.height * 0.9),
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Nouveau rendez-vous',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        LucideIcons.x,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                if (widget.initialTime != null)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          LucideIcons.clock,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatDate(_selectedDate),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'à ${_formatTime(_selectedSlot!)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: remainingMinutes > 0
                                ? AppColors.success.withValues(alpha: 0.2)
                                : AppColors.error.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            remainingMinutes > 0
                                ? '$remainingMinutes min dispo'
                                : 'Complet',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: remainingMinutes > 0
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            LucideIcons.calendar,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _formatDate(_selectedDate),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const Icon(
                            LucideIcons.chevronDown,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.md),
                const Divider(),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _nameController,
                  label: 'Nom du patient',
                  hint: 'Entrez le nom',
                  prefixIcon: LucideIcons.user,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _phoneFocusNode.requestFocus(),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le nom est requis';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _phoneController,
                  label: 'Téléphone',
                  hint: 'Entrez le numéro',
                  prefixIcon: LucideIcons.phone,
                  keyboardType: TextInputType.phone,
                  focusNode: _phoneFocusNode,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _save(),
                ),
                const SizedBox(height: AppSpacing.md),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _toggleConsultation(false),
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
                        onTap: () => _toggleConsultation(true),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _isConsultation
                                ? AppColors.consultationColor.withValues(
                                    alpha: 0.1,
                                  )
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
                                'Visio',
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
                if (_selectedSlot != null) ...[
                  Text(
                    _isConsultation
                        ? 'Durée: ${doctorState.consultationDuration} min (fixe)'
                        : 'Durée du rendez-vous',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (_isConsultation)
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.consultationColor.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            LucideIcons.clock,
                            size: 18,
                            color: AppColors.consultationColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${doctorState.consultationDuration} minutes',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.consultationColor,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: availableDurations.map((duration) {
                        final isSelected = _selectedDuration == duration;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDuration = duration;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.background,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.border,
                              ),
                            ),
                            child: Text(
                              '$duration min',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? AppColors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  if (availableDurations.isEmpty && !_isConsultation)
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            LucideIcons.alertCircle,
                            size: 18,
                            color: AppColors.error,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Aucun créneau disponible à cette heure',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                ] else
                  const Text(
                    'Sélectionnez un créneau ci-dessous',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                const SizedBox(height: AppSpacing.lg),
                _buildTimeSlots(doctorState),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    label: _isConsultation
                        ? 'Créer la consultation'
                        : 'Créer le rendez-vous',
                    onPressed: _save,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSlots(DoctorState doctorState) {
    final validStarts = doctorState.availabilityService.getValidStarts(
      _selectedDate,
      doctorState.allAppointments,
      duration: _selectedDuration,
      isConsultation: _isConsultation,
    );

    if (validStarts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'Aucun créneau disponible',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Créneaux disponibles',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: validStarts.map((slot) {
            final slotHour = slot.minute ~/ 60;
            final slotMinute = slot.minute % 60;
            final slotTime = TimeOfDay(hour: slotHour, minute: slotMinute);
            final isSelected = _selectedSlot == slotTime;

            final slotStart = DateTime(
              _selectedDate.year,
              _selectedDate.month,
              _selectedDate.day,
              slotHour,
              slotMinute,
            );
            final dayAppointments = doctorState.allAppointments.where((apt) {
              return apt.startTime.year == _selectedDate.year &&
                  apt.startTime.month == _selectedDate.month &&
                  apt.startTime.day == _selectedDate.day;
            }).toList();
            final remaining = _calculateRemainingMinutes(
              slotStart,
              dayAppointments,
            );

            return GestureDetector(
              onTap: remaining > 0
                  ? () {
                      setState(() {
                        _selectedSlot = slotTime;
                      });
                    }
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : (remaining > 0
                            ? AppColors.white
                            : AppColors.background),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    width: 2,
                    color: isSelected
                        ? AppColors.primary
                        : (remaining > 0
                              ? AppColors.primary.withValues(alpha: 0.3)
                              : AppColors.border),
                  ),
                ),
                child: Text(
                  TimeUtils.minutesToString(slot.minute),
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.white
                        : (remaining > 0
                              ? AppColors.textPrimary
                              : AppColors.textHint),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  int _calculateRemainingMinutes(
    DateTime slotStart,
    List<AppointmentData> appointments,
  ) {
    if (appointments.isEmpty) return 60;
    final slotMinute = slotStart.hour * 60 + slotStart.minute;
    for (final apt in appointments) {
      final aptStart = apt.startTime.hour * 60 + apt.startTime.minute;
      final aptEnd = aptStart + apt.duration;
      if (slotMinute >= aptStart && slotMinute < aptEnd) {
        return aptEnd - slotMinute;
      }
    }
    return 60;
  }
}
