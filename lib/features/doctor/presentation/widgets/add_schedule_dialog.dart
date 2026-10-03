import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:eyadati_kit/core/constants/app_colors.dart';
import 'package:eyadati_kit/core/constants/app_spacing.dart';
import 'package:eyadati_kit/core/theme/text_styles.dart';
import 'package:eyadati_kit/core/utils/time_utils.dart';
import 'package:eyadati_kit/models/schedule_slot_model.dart';

class AddScheduleDialog extends StatefulWidget {
  final String doctorId;
  final int initialDay;
  final int? initialStartTime;
  final int? initialEndTime;
  final ScheduleSlot? existingSlot;
  final Future<void> Function(int day, int start, int end, {int? breakStart, int? breakEnd})? onSave;

  const AddScheduleDialog({
    super.key,
    required this.doctorId,
    required this.initialDay,
    this.initialStartTime,
    this.initialEndTime,
    this.existingSlot,
    this.onSave,
  });

  @override
  State<AddScheduleDialog> createState() => _AddScheduleDialogState();
}

class _AddScheduleDialogState extends State<AddScheduleDialog> {
  late int _selectedDay;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  TimeOfDay? _breakStart;
  TimeOfDay? _breakEnd;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingSlot != null) {
      _selectedDay = widget.existingSlot!.dayOfWeek;
      _startTime = TimeUtils.minutesToTimeOfDay(widget.existingSlot!.startTime);
      _endTime = TimeUtils.minutesToTimeOfDay(widget.existingSlot!.endTime);
      if (widget.existingSlot!.breakStart != null) {
        _breakStart = TimeUtils.minutesToTimeOfDay(widget.existingSlot!.breakStart!);
      }
      if (widget.existingSlot!.breakEnd != null) {
        _breakEnd = TimeUtils.minutesToTimeOfDay(widget.existingSlot!.breakEnd!);
      }
    } else {
      _selectedDay = widget.initialDay;
      _startTime = widget.initialStartTime != null
          ? TimeUtils.minutesToTimeOfDay(widget.initialStartTime!)
          : const TimeOfDay(hour: 9, minute: 0);
      _endTime = widget.initialEndTime != null
          ? TimeUtils.minutesToTimeOfDay(widget.initialEndTime!)
          : const TimeOfDay(hour: 17, minute: 0);
    }
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectTime(bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _selectBreakTime(bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart
          ? (_breakStart ?? const TimeOfDay(hour: 12, minute: 0))
          : (_breakEnd ?? const TimeOfDay(hour: 14, minute: 0)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _breakStart = picked;
        } else {
          _breakEnd = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    final startMins = TimeUtils.timeOfDayToMinutes(_startTime);
    final endMins = TimeUtils.timeOfDayToMinutes(_endTime);
    if (endMins <= startMins) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("L'heure de fin doit être après l'heure de début")),
      );
      return;
    }

    if (_breakStart != null && _breakEnd != null) {
      final breakStartMins = TimeUtils.timeOfDayToMinutes(_breakStart!);
      final breakEndMins = TimeUtils.timeOfDayToMinutes(_breakEnd!);
      if (breakEndMins <= breakStartMins) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("La fin de la pause doit être après le début")),
        );
        return;
      }
      if (breakStartMins < startMins || breakEndMins > endMins) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("La pause doit être dans les horaires de travail")),
        );
        return;
      }
    }

    setState(() => _isLoading = true);
    try {
      final breakStartMins = _breakStart != null ? TimeUtils.timeOfDayToMinutes(_breakStart!) : null;
      final breakEndMins = _breakEnd != null ? TimeUtils.timeOfDayToMinutes(_breakEnd!) : null;
      await widget.onSave?.call(_selectedDay, startMins, endMins, breakStart: breakStartMins, breakEnd: breakEndMins);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const days = ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'];

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(widget.existingSlot != null ? 'Modifier le créneau' : 'Ajouter un créneau'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Jour', style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              itemBuilder: (context, index) {
                final isSelected = _selectedDay == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDay = index),
                  child: Container(
                    width: 40,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        days[index],
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Début', style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: AppSpacing.xs),
                    GestureDetector(
                      onTap: () => _selectTime(true),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.clock, size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              _formatTime(_startTime),
                              style: AppTextStyles.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Fin', style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: AppSpacing.xs),
                    GestureDetector(
                      onTap: () => _selectTime(false),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.clock, size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              _formatTime(_endTime),
                              style: AppTextStyles.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Pause (optionnel)', style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectBreakTime(true),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Text('Début pause', style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.coffee, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(_breakStart != null ? _formatTime(_breakStart!) : '--:--',
                              style: AppTextStyles.titleMedium),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectBreakTime(false),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Text('Fin pause', style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.coffee, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(_breakEnd != null ? _formatTime(_breakEnd!) : '--:--',
                              style: AppTextStyles.titleMedium),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Enregistrer'),
        ),
      ],
    );
  }
}