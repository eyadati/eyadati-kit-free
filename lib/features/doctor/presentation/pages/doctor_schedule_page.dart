import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:eyadati_kit/core/constants/app_colors.dart';
import 'package:eyadati_kit/core/constants/app_spacing.dart';
import 'package:eyadati_kit/core/theme/text_styles.dart';
import 'package:eyadati_kit/models/schedule_slot_model.dart';
import '../providers/doctor_provider.dart';
import '../widgets/schedule_slot_card.dart';
import '../widgets/add_schedule_dialog.dart';

class DoctorSchedulePage extends ConsumerStatefulWidget {
  const DoctorSchedulePage({super.key});

  @override
  ConsumerState<DoctorSchedulePage> createState() => _DoctorSchedulePageState();
}

class _DoctorSchedulePageState extends ConsumerState<DoctorSchedulePage> {
  int _selectedDay = DateTime.now().weekday % 7;
  bool _isLoading = false;

  final List<String> _days = ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSchedule();
    });
  }

  Future<void> _loadSchedule() async {
    setState(() => _isLoading = true);
    await ref.read(doctorProvider.notifier).refresh();
    if (mounted) setState(() => _isLoading = false);
  }

  List<ScheduleSlot> _getFilteredSlots(List<ScheduleSlot> allSlots) {
    return allSlots.where((s) => s.dayOfWeek == _selectedDay).toList();
  }

  void _showAddSlotDialog() {
    showDialog(
      context: context,
      builder: (context) => AddScheduleDialog(
        doctorId: ref.read(doctorProvider).userId ?? '',
        initialDay: _selectedDay,
        onSave: (day, start, end, {int? breakStart, int? breakEnd}) async {
          await ref
              .read(doctorProvider.notifier)
              .addScheduleSlot(
                dayOfWeek: day,
                startTime: start,
                endTime: end,
                breakStart: breakStart,
                breakEnd: breakEnd,
              );
          await _loadSchedule();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final doctorState = ref.watch(doctorProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Emploi du temps'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadSchedule,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jours de travail',
                      style: AppTextStyles.sectionHeader,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: List.generate(7, (index) {
                        final hasSlots = doctorState.scheduleSlots
                            .where((s) => s.dayOfWeek == index)
                            .isNotEmpty;
                        final isSelected = _selectedDay == index;

                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (_selectedDay != index) {
                                setState(() => _selectedDay = index);
                                _loadSchedule();
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : hasSlots
                                    ? AppColors.secondary.withValues(alpha: 0.1)
                                    : AppColors.background,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: hasSlots && !isSelected
                                      ? AppColors.secondary
                                      : Colors.transparent,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    _days[index],
                                    style: AppTextStyles.labelMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : hasSlots
                                          ? AppColors.secondary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                  if (hasSlots) ...[
                                    const SizedBox(height: 4),
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.secondary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getDayFullName(_selectedDay),
                    style: AppTextStyles.sectionTitle,
                  ),
                  TextButton.icon(
                    onPressed: _showAddSlotDialog,
                    icon: Icon(LucideIcons.plus, size: 20),
                    label: const Text('Ajouter'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (_isLoading)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else
                ..._buildSlotList(doctorState),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSlotList(DoctorState doctorState) {
    final filteredSlots = _getFilteredSlots(doctorState.scheduleSlots);
    if (filteredSlots.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              Icon(LucideIcons.clock, size: 48, color: AppColors.textHint),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Aucun créneau',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Appuyez sur "Ajouter" pour créer un créneau pour ${_getDayFullName(_selectedDay)}',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w300,
                  color: AppColors.textHint,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ];
    }
    return filteredSlots.map((slot) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: ScheduleSlotCard(
          slot: slot,
          onEdit: () {
            showDialog(
              context: context,
              builder: (context) => AddScheduleDialog(
                doctorId: slot.doctorId,
                initialDay: slot.dayOfWeek,
                initialStartTime: slot.startTime,
                initialEndTime: slot.endTime,
                existingSlot: slot,
                onSave: (day, start, end, {int? breakStart, int? breakEnd}) async {
                  await ref
                      .read(doctorProvider.notifier)
                      .updateScheduleSlot(
                        slotId: slot.id,
                        startTime: start,
                        endTime: end,
                        breakStart: breakStart,
                        breakEnd: breakEnd,
                      );
                  await _loadSchedule();
                },
              ),
            );
          },
          onDelete: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Supprimer le créneau'),
                content: const Text('Voulez-vous supprimer ce créneau ?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Annuler'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text('Supprimer', style: TextStyle(color: AppColors.error)),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              await ref.read(doctorProvider.notifier).deleteScheduleSlot(slot.id);
              await _loadSchedule();
            }
          },
        ),
      );
    }).toList();
  }

  String _getDayFullName(int day) {
    const days = [
      'Dimanche',
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
    ];
    return days[day];
  }
}
