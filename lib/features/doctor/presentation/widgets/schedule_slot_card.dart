import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:eyadati_kit/core/constants/app_colors.dart';
import 'package:eyadati_kit/core/constants/app_spacing.dart';
import 'package:eyadati_kit/core/theme/text_styles.dart';
import 'package:eyadati_kit/core/utils/time_utils.dart';
import 'package:eyadati_kit/models/schedule_slot_model.dart';

class ScheduleSlotCard extends StatelessWidget {
  final ScheduleSlot slot;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ScheduleSlotCard({
    super.key,
    required this.slot,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final startDisplay = TimeUtils.minutesToString(slot.startTime);
    final endDisplay = TimeUtils.minutesToString(slot.endTime);
    final breakDisplay = slot.hasBreak
        ? ' ${TimeUtils.minutesToString(slot.breakStart!)} - ${TimeUtils.minutesToString(slot.breakEnd!)}'
        : '';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: slot.isActive ? AppColors.secondary.withValues(alpha: 0.3) : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: slot.isActive ? AppColors.secondary : AppColors.textHint,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$startDisplay - $endDisplay$breakDisplay',
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: slot.isActive ? AppColors.textPrimary : AppColors.textHint,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: slot.isActive 
                            ? AppColors.secondary.withValues(alpha: 0.1)
                            : AppColors.textHint.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        slot.isActive ? 'Actif' : 'Inactif',
                        style: AppTextStyles.badge.copyWith(
                          color: slot.isActive ? AppColors.secondary : AppColors.textHint,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      ScheduleSlot.dayNameFrench(slot.dayOfWeek),
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(LucideIcons.pencil),
            color: AppColors.textSecondary,
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(LucideIcons.trash2),
            color: AppColors.error,
          ),
        ],
      ),
    );
  }
}