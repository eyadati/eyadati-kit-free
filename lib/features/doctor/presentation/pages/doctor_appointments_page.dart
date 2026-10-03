import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:eyadati_kit/core/constants/app_colors.dart';
import 'package:eyadati_kit/core/constants/app_spacing.dart';
import 'package:eyadati_kit/core/theme/text_styles.dart';
import 'package:eyadati_kit/models/appointment_data.dart';
import '../providers/doctor_provider.dart';
import '../widgets/appointment_details_sheet.dart';

class DoctorAppointmentsPage extends ConsumerWidget {
  const DoctorAppointmentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(doctorProvider.select((s) => s.allAppointments));

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border(
                bottom: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: TabBar(
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              labelStyle: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600),
              unselectedLabelStyle: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w300),
              tabs: [
                Tab(text: 'Tous (${all.length})'),
                Tab(text: 'Confirmés (${all.where((a) => a.status == 'upcoming').length})'),
                Tab(text: 'Annulés (${all.where((a) => a.status == 'cancelled').length})'),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(doctorProvider.notifier).refresh(),
              child: TabBarView(
                children: [
                  _buildList(context, all),
                  _buildList(context, all.where((a) => a.status == 'upcoming').toList()),
                  _buildList(context, all.where((a) => a.status == 'cancelled').toList()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<AppointmentData> appointments) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.fileText, size: 48, color: AppColors.textHint),
            const SizedBox(height: AppSpacing.md),
            Text('Aucun rendez-vous', style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final apt = appointments[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (ctx) => AppointmentDetailsSheet(appointment: apt),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: apt.status == 'cancelled'
                      ? AppColors.error.withValues(alpha: 0.3)
                      : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: apt.status == 'cancelled'
                          ? AppColors.error.withValues(alpha: 0.1)
                          : apt.isConsultation
                              ? AppColors.consultationColor.withValues(alpha: 0.1)
                              : AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      apt.isConsultation ? LucideIcons.video : LucideIcons.user,
                      size: 18,
                      color: apt.status == 'cancelled'
                          ? AppColors.error
                          : apt.isConsultation
                              ? AppColors.consultationColor
                              : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(apt.patientName, style: AppTextStyles.cardTitle.copyWith(
                          decoration: apt.status == 'cancelled' ? TextDecoration.lineThrough : null,
                        )),
                        const SizedBox(height: 4),
                        Text('${apt.startTime.day}/${apt.startTime.month}/${apt.startTime.year} à ${apt.startTime.hour.toString().padLeft(2, '0')}:${apt.startTime.minute.toString().padLeft(2, '0')}', style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w300)),
                      ],
                    ),
                  ),
                  _buildStatusBadge(apt.status),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    if (status == 'cancelled') {
      color = AppColors.error;
      label = 'Annulé';
    } else if (status == 'completed') {
      color = AppColors.success;
      label = 'Terminé';
    } else if (status == 'absent') {
      color = AppColors.textHint;
      label = 'Absent';
    } else {
      color = AppColors.warning;
      label = 'En attente';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: AppTextStyles.badge.copyWith(color: color)),
    );
  }
}