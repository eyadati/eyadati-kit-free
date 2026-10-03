import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eyadati_kit/core/constants/app_colors.dart';
import 'package:eyadati_kit/core/constants/app_breakpoints.dart';
import 'package:eyadati_kit/core/theme/text_styles.dart';
import 'package:eyadati_kit/features/doctor/presentation/pages/doctor_calendar_page.dart';
import 'package:eyadati_kit/features/doctor/presentation/providers/doctor_provider.dart';
import 'package:eyadati_kit/features/doctor/presentation/widgets/doctor_notification_sidebar.dart';
import 'package:eyadati_kit/features/doctor/presentation/widgets/doctor_add_appointment_dialog.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';

class DoctorDashboardPage extends ConsumerStatefulWidget {
  const DoctorDashboardPage({super.key});

  @override
  ConsumerState<DoctorDashboardPage> createState() =>
      _DoctorDashboardPageState();
}

class _DoctorDashboardPageState extends ConsumerState<DoctorDashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ValueNotifier<DateTime> _selectedDate = ValueNotifier(DateTime.now());

  void _showAddAppointmentDialog() {
    showDialog(
      context: context,
      builder: (ctx) => DoctorAddAppointmentDialog(
        initialDate: _selectedDate.value,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allAppointments = ref.watch(doctorProvider.select((s) => s.allAppointments));
    final errorMessage = ref.watch(doctorProvider.select((s) => s.errorMessage));
    final isLoading = ref.watch(doctorProvider.select((s) => s.isLoading));
    final pending = allAppointments
        .where((a) => a.status == 'upcoming' && a.bookingType == 'online')
        .toList();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      endDrawer: DoctorNotificationSidebar(appointments: pending),
      body: Column(
        children: [
          Expanded(
            child: errorMessage != null
                ? _buildErrorView(errorMessage)
                : Skeletonizer(
                    enabled: isLoading,
                    child: DoctorCalendarPage(
                      onBellPressed: () =>
                          _scaffoldKey.currentState?.openEndDrawer(),
                      selectedDateNotifier: _selectedDate,
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= AppBreakpoints.mobile) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton(
            onPressed: _showAddAppointmentDialog,
            backgroundColor: AppColors.primary,
            child: const Icon(LucideIcons.plus, color: Colors.white),
          );
        },
      ),
    );
  }

  Widget _buildErrorView(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              LucideIcons.alertCircle,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(doctorProvider.notifier).clearError();
                ref.read(doctorProvider.notifier).refresh();
              },
              icon: const Icon(LucideIcons.refreshCw),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
