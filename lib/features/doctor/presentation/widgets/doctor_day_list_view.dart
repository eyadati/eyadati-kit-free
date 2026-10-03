import 'package:flutter/material.dart';
import 'package:eyadati_kit/core/constants/app_colors.dart';
import 'package:eyadati_kit/core/theme/text_styles.dart';
import 'package:eyadati_kit/core/utils/input_validator.dart';
import 'package:eyadati_kit/models/appointment_data.dart';

class DoctorDayListView extends StatelessWidget {
  final DateTime selectedDate;
  final List<AppointmentData> appointments;
  final int startHour;
  final int endHour;
  final void Function(AppointmentData) onAppointmentTap;
  final void Function(DateTime time) onEmptySlotTap;
  final void Function(AppointmentData)? onCallPatient;
  final void Function(AppointmentData)? onSmsPatient;

  const DoctorDayListView({
    super.key,
    required this.selectedDate,
    required this.appointments,
    required this.startHour,
    required this.endHour,
    required this.onAppointmentTap,
    required this.onEmptySlotTap,
    this.onCallPatient,
    this.onSmsPatient,
  });

  Color _appointmentColor(AppointmentData apt) {
    if (apt.status == 'cancelled') return AppColors.error;
    if (apt.bookingType == 'home') return AppColors.aptHomeVisitText;
    if (apt.isConsultation) return AppColors.aptInPersonText;
    return AppColors.primary;
  }

  Color _appointmentBg(AppointmentData apt) {
    if (apt.status == 'cancelled') return AppColors.error.withValues(alpha: 0.15);
    if (apt.bookingType == 'home') return AppColors.aptHomeVisit;
    if (apt.isConsultation) return AppColors.aptInPerson;
    return AppColors.aptVideoCall;
  }

  String _appointmentLabel(AppointmentData apt) {
    if (apt.bookingType == 'home') return 'Domicile';
    if (apt.isConsultation) return 'Consultation';
    return 'RDV';
  }

  @override
  Widget build(BuildContext context) {
    final sorted = List<AppointmentData>.from(appointments)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      children: _buildTimeline(sorted),
    );
  }

  List<Widget> _buildTimeline(List<AppointmentData> sorted) {
    final items = <Widget>[];
    int currentHour = startHour;

    for (final apt in sorted) {
      final aptHour = apt.startTime.hour;

      while (currentHour < aptHour) {
        items.add(_buildHourSlot(currentHour));
        currentHour++;
      }

      items.add(_buildAppointmentCard(apt));

      final aptEndHour = apt.startTime.hour +
          ((apt.startTime.minute + apt.duration) ~/ 60);
      currentHour = aptEndHour;
    }

    while (currentHour <= endHour) {
      items.add(_buildHourSlot(currentHour));
      currentHour++;
    }

    return items;
  }

  Widget _buildHourSlot(int hour) {
    final timeStr = '${hour.toString().padLeft(2, '0')}:00';
    final slotTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      hour,
    );

    return InkWell(
      onTap: () => onEmptySlotTap(slotTime),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 57,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            SizedBox(
              width: 46,
              child: Text(
                timeStr,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textHint,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 1,
                color: AppColors.border.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(AppointmentData apt) {
    final color = _appointmentColor(apt);
    final bgColor = _appointmentBg(apt);
    final label = _appointmentLabel(apt);
    final isCancelled = apt.status == 'cancelled';
    final timeStr =
        '${apt.startTime.hour.toString().padLeft(2, '0')}:${apt.startTime.minute.toString().padLeft(2, '0')}';
    final endStr =
        '${apt.endTime.hour.toString().padLeft(2, '0')}:${apt.endTime.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: () => onAppointmentTap(apt),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: isCancelled
                ? Border.all(color: AppColors.error.withValues(alpha: 0.4))
                : Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 57,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        apt.patientName,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isCancelled ? AppColors.error : AppColors.textPrimary,
                          decoration: isCancelled ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$timeStr - $endStr',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textHint,
                        ),
                      ),
                      if (apt.patientPhone != null) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              '📞 ${InputValidator.formatPhoneLocal(apt.patientPhone!)}',
                              style: AppTextStyles.badge.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (onCallPatient != null) ...[
                              const SizedBox(width: 4),
                              TextButton.icon(
                                icon: Icon(Icons.phone, size: 12, color: AppColors.primary),
                                label: Text('Appeler', style: TextStyle(fontSize: 10, color: AppColors.primary)),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () => onCallPatient!(apt),
                              ),
                            ],
                            if (onSmsPatient != null) ...[
                              const SizedBox(width: 4),
                              TextButton.icon(
                                icon: Icon(Icons.message, size: 12, color: AppColors.success),
                                label: Text('SMS', style: TextStyle(fontSize: 10, color: AppColors.success)),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () => onSmsPatient!(apt),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildTypeBadge(label, color, isCancelled),
                if (isCancelled) ...[
                  const SizedBox(width: 6),
                  _buildStatusBadge(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeBadge(String label, Color color, bool isCancelled) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isCancelled
            ? AppColors.error.withValues(alpha: 0.1)
            : color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTextStyles.badge.copyWith(
          color: isCancelled ? AppColors.error : color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Annulé',
        style: AppTextStyles.badge.copyWith(
          color: AppColors.error,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}
