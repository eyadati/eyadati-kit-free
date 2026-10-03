import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/utils/input_validator.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/providers.dart';

class UpcomingAppointmentCard extends StatelessWidget {
  final PatientAppointmentViewModel appointment;

  const UpcomingAppointmentCard({
    super.key,
    required this.appointment,
  });

  Future<void> _openMaps() async {
    final String url;
    if (appointment.mapsLink != null && appointment.mapsLink!.isNotEmpty) {
      url = appointment.mapsLink!;
    } else if (appointment.doctorAddress != null) {
      final encodedAddress = Uri.encodeComponent(appointment.doctorAddress!);
      url = 'https://www.google.com/maps/search/?api=1&query=$encodedAddress';
    } else {
      return;
    }

    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _callDoctor(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final phone = appointment.doctorPhone;
    if (phone == null || phone.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: phone));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.clipboardCopied),
          duration: Duration(seconds: 2),
        ),
      );
    }
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final timeFormat = DateFormat('HH:mm');

    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('dd').format(appointment.dateTime),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    DateFormat('MMM').format(appointment.dateTime).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
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
                  Text(
                    appointment.doctorName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    appointment.doctorSpecialty,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (appointment.doctorPhone != null && appointment.doctorPhone!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(LucideIcons.phone, size: 12, color: AppColors.textHint),
                        const SizedBox(width: 4),
                        Text(
                          InputValidator.formatPhoneLocal(appointment.doctorPhone!),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              LucideIcons.clock,
                              size: 12,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              timeFormat.format(appointment.dateTime),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          _getStatusLabel(appointment.status, l10n),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                if (appointment.doctorPhone != null && appointment.doctorPhone!.isNotEmpty) ...[
                  GestureDetector(
                    onTap: () => _callDoctor(context),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Icon(
                        LucideIcons.phone,
                        size: 18,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                ],
                if (appointment.mapsLink != null || appointment.doctorAddress != null)
                  GestureDetector(
                    onTap: _openMaps,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Icon(
                        LucideIcons.mapPin,
                        size: 18,
                        color: AppColors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusLabel(String status, AppLocalizations l10n) {
    switch (status) {
      case 'upcoming':
        return l10n.appointmentsUpcoming;
      case 'confirmed':
        return l10n.appointmentsStatusConfirmed;
      case 'cancelled':
        return l10n.appointmentsStatusCancelled;
      case 'completed':
        return l10n.appointmentsStatusCompleted;
      default:
        return status;
    }
  }
}