import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:eyadati_kit/core/constants/app_colors.dart';
import 'package:eyadati_kit/core/constants/app_spacing.dart';
import 'package:eyadati_kit/core/theme/text_styles.dart';
import 'package:eyadati_kit/core/utils/input_validator.dart';
import 'package:eyadati_kit/core/utils/phone_launcher.dart';
import 'package:eyadati_kit/models/appointment_data.dart';
import '../providers/doctor_provider.dart';

class AppointmentDetailsSheet extends ConsumerWidget {
  final AppointmentData appointment;

  const AppointmentDetailsSheet({super.key, required this.appointment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeStr = '${appointment.startTime.hour.toString().padLeft(2, '0')}:${appointment.startTime.minute.toString().padLeft(2, '0')}';
    final dateStr = '${appointment.startTime.day}/${appointment.startTime.month}/${appointment.startTime.year}';
    final isUpcoming = appointment.status == 'upcoming';
    final isCancelled = appointment.status == 'cancelled';

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Material(
      color: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: isMobile ? screenWidth * 0.9 : double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    appointment.patientName.isNotEmpty
                        ? appointment.patientName[0].toUpperCase()
                        : 'P',
                    style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appointment.patientName, style: AppTextStyles.sectionTitle),
                      if (appointment.patientId != null)
                        Text('ID: ${appointment.patientId}', style: AppTextStyles.patientId),
                      if (appointment.patientPhone != null)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.xs),
                          child: Text(
                            InputValidator.formatPhoneLocal(appointment.patientPhone!),
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (appointment.patientPhone != null) ...[
                  IconButton(
                    icon: Icon(Icons.phone, color: AppColors.primary, size: 24),
                    onPressed: () => launchUrl(Uri.parse('tel:${appointment.patientPhone}')),
                  ),
                  IconButton(
                    icon: Icon(Icons.message, color: AppColors.success, size: 24),
                    onPressed: () {
                      final msg = 'Bonjour ${appointment.patientName}, rappel de votre rendez-vous le '
                          '${appointment.startTime.day}/${appointment.startTime.month} à '
                          '${appointment.startTime.hour.toString().padLeft(2, '0')}:${appointment.startTime.minute.toString().padLeft(2, '0')}. Merci.';
                      launchSmsUrl(appointment.patientPhone!, msg, context);
                    },
                  ),
                ],
                IconButton(
                  icon: Icon(LucideIcons.x, color: AppColors.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildInfoItem(LucideIcons.calendar, dateStr),
                  Container(width: 1, height: 32, color: AppColors.border, margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md)),
                  _buildInfoItem(LucideIcons.clock, timeStr),
                  Container(width: 1, height: 32, color: AppColors.border, margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md)),
                  _buildInfoItem(LucideIcons.timer, '${appointment.duration} min'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: appointment.isConsultation
                        ? AppColors.consultationColor.withValues(alpha: 0.1)
                        : AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        appointment.isConsultation ? LucideIcons.video : LucideIcons.user,
                        size: 14,
                        color: appointment.isConsultation ? AppColors.consultationColor : AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        appointment.isConsultation ? 'Consultation' : 'Standard',
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: appointment.isConsultation ? AppColors.consultationColor : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isUpcoming
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isUpcoming ? 'À venir' : isCancelled ? 'Annulé' : appointment.status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isUpcoming ? AppColors.success : AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            if (!isCancelled) ...[
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: 'Annuler',
                      icon: LucideIcons.circleX,
                      color: AppColors.error,
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Annuler le rendez-vous'),
                            content: const Text('Êtes-vous sûr de vouloir annuler ce rendez-vous ?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Non')),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: Text('Oui, annuler', style: TextStyle(color: AppColors.error)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true && context.mounted) {
                          final messenger = ScaffoldMessenger.of(context);
                          messenger.showSnackBar(
                            SnackBar(content: Text('Annulation en cours...'), duration: const Duration(seconds: 30)),
                          );
                          final ok = await ref.read(doctorProvider.notifier).updateAppointmentStatus(appointment.id, 'cancelled');
                          if (context.mounted) {
                            messenger.hideCurrentSnackBar();
                            Navigator.pop(context);
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(ok ? 'Rendez-vous annulé' : 'Erreur lors de l\'annulation', style: TextStyle(color: AppColors.white)),
                                backgroundColor: ok ? AppColors.error : AppColors.warning,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: _ActionButton(
                  label: 'Supprimer',
                  icon: LucideIcons.trash2,
                  color: AppColors.error,
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Supprimer le rendez-vous'),
                        content: const Text('Êtes-vous sûr de vouloir supprimer ce rendez-vous ?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Non')),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text('Supprimer', style: TextStyle(color: AppColors.error)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true && context.mounted) {
                      final messenger = ScaffoldMessenger.of(context);
                      messenger.showSnackBar(
                        SnackBar(content: Text('Suppression en cours...'), duration: const Duration(seconds: 30)),
                      );
                      final ok = await ref.read(doctorProvider.notifier).deleteAppointment(appointment.id);
                      if (context.mounted) {
                        messenger.hideCurrentSnackBar();
                        Navigator.pop(context);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(ok ? 'Rendez-vous supprimé' : 'Erreur lors de la suppression', style: TextStyle(color: AppColors.white)),
                            backgroundColor: ok ? AppColors.error : AppColors.warning,
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(text, style: AppTextStyles.labelLarge),
      ],
    );
  }

}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label, style: AppTextStyles.labelLarge.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}