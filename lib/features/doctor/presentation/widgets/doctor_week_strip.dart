import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../models/appointment_data.dart';

class DoctorWeekStrip extends StatelessWidget {
  final DateTime selectedDate;
  final List<AppointmentData> appointments;
  final ValueChanged<DateTime> onDateSelected;
  const DoctorWeekStrip({
    super.key,
    required this.selectedDate,
    required this.appointments,
    required this.onDateSelected,
  });

  DateTime get _startOfWeek {
    final daysFromMonday = (selectedDate.weekday - 1) % 7;
    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day - daysFromMonday,
    );
  }

  DateTime get _endOfWeek => _startOfWeek.add(const Duration(days: 6));

  bool _hasAppointments(DateTime date) {
    return appointments.any(
      (a) =>
          a.startTime.year == date.year &&
          a.startTime.month == date.month &&
          a.startTime.day == date.day,
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _formatWeekRange() {
    final months = [
      '', 'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
      'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc',
    ];
    final start = _startOfWeek;
    final end = _endOfWeek;
    if (start.month == end.month) {
      return '${start.day} - ${end.day} ${months[start.month]} ${start.year}';
    }
    return '${start.day} ${months[start.month]} - ${end.day} ${months[end.month]} ${end.year}';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final start = _startOfWeek;
    final isCurrentWeek =
        (start.isBefore(now) || start.isAtSameMomentAs(now)) &&
            !_endOfWeek.isBefore(now);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.chevronLeft, size: 20),
                  onPressed: () {
                    final newStart = start.subtract(const Duration(days: 7));
                    onDateSelected(newStart.add(const Duration(days: 3)));
                  },
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  padding: EdgeInsets.zero,
                ),
                Expanded(
                  child: Text(
                    _formatWeekRange(),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.chevronRight, size: 20),
                  onPressed: () {
                    final newStart = start.add(const Duration(days: 7));
                    onDateSelected(newStart.add(const Duration(days: 3)));
                  },
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                if (!isCurrentWeek)
                  GestureDetector(
                    onTap: () => onDateSelected(now),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Auj.',
                        style: AppTextStyles.badge.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                if (!isCurrentWeek) const Spacer(),
                ...List.generate(7, (i) {
                  final date = start.add(Duration(days: i));
                  final isSelected = date.year == selectedDate.year &&
                      date.month == selectedDate.month &&
                      date.day == selectedDate.day;
                  final today = _isToday(date);
                  final hasApts = _hasAppointments(date);
                  final dayNames = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onDateSelected(date),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : today
                                  ? AppColors.primary.withValues(alpha: 0.1)
                                  : null,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              dayNames[i],
                              style: AppTextStyles.badge.copyWith(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.85)
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${date.day}',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight:
                                    isSelected || today ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : today
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                              ),
                            ),
                            if (hasApts && !isSelected)
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  color: AppColors.secondary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            if (!hasApts && !isSelected)
                              const SizedBox(height: 7),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

              ],
            ),
          ],
        ),
      ),
    );
  }
}
