import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:eyadati_kit/core/constants/app_colors.dart';
import 'package:eyadati_kit/core/constants/app_spacing.dart';
import 'package:eyadati_kit/core/constants/app_radius.dart';
import 'package:eyadati_kit/core/theme/text_styles.dart';
import 'package:eyadati_kit/core/widgets/cards/app_card.dart';
import 'package:eyadati_kit/core/widgets/cards/empty_state_card.dart';
import 'package:eyadati_kit/models/appointment_data.dart';
import 'package:eyadati_kit/models/patient_summary.dart';
import '../providers/patient_history_provider.dart';

class DoctorPatientsPage extends ConsumerStatefulWidget {
  final String? initialSearchQuery;

  const DoctorPatientsPage({super.key, this.initialSearchQuery});

  @override
  ConsumerState<DoctorPatientsPage> createState() => _DoctorPatientsPageState();
}

class _DoctorPatientsPageState extends ConsumerState<DoctorPatientsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialSearchQuery != null && widget.initialSearchQuery!.isNotEmpty) {
      _searchController.text = widget.initialSearchQuery!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(patientHistoryProvider.notifier).setSearchQuery(widget.initialSearchQuery!);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(patientHistoryProvider);
    final notifier = ref.read(patientHistoryProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mes patients'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(notifier),
          Expanded(
            child: asyncState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _buildErrorView(e.toString(), notifier),
              data: (state) {
                final filtered = state.filteredPatients;
                final hasQuery = state.searchQuery.isNotEmpty;
                if (filtered.isEmpty) return _buildEmptyState(hasQuery);
                return RefreshIndicator(
                  onRefresh: notifier.refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg, 0, AppSpacing.lg, 80,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return _PatientTile(
                        summary: filtered[index],
                        isExpanded: state.expandedPatientIds
                            .contains(filtered[index].patientId),
                        onToggle: () => notifier.toggleExpand(
                          filtered[index].patientId,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(PatientHistory notifier) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.sm,
      ),
      child: TextField(
        controller: _searchController,
        onChanged: notifier.setSearchQuery,
        decoration: InputDecoration(
          hintText: 'Rechercher un patient...',
          prefixIcon: const Icon(LucideIcons.search, size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(LucideIcons.x, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    notifier.setSearchQuery('');
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: AppRadius.inputRadius,
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.inputRadius,
            borderSide: BorderSide(color: AppColors.border),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(String errorMessage, PatientHistory notifier) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.alertCircle, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => notifier.refresh(),
              icon: const Icon(LucideIcons.refreshCw),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool hasQuery) {
    return Center(
      child: EmptyStateCard(
        icon: LucideIcons.users,
        title: hasQuery ? 'Aucun patient trouvé' : 'Aucun patient',
        message: hasQuery
            ? 'Essayez un autre nom ou numéro'
            : 'Les patients que vous avez reçus apparaîtront ici',
      ),
    );
  }

}

class _PatientTile extends StatelessWidget {
  final PatientSummary summary;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _PatientTile({
    required this.summary,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final lastVisitStr = _formatDate(summary.lastVisitDate);

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: AppCard(
        onTap: onToggle,
        child: Column(
          children: [
            _buildClosedRow(lastVisitStr),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _buildExpandedContent(),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClosedRow(String lastVisitStr) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Text(
            summary.patientName.isNotEmpty
                ? summary.patientName[0].toUpperCase()
                : 'P',
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(summary.patientName, style: AppTextStyles.cardTitle),
              if (summary.patientPhone != null &&
                  summary.patientPhone!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  summary.patientPhone!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${summary.visitCount} visite${summary.visitCount > 1 ? 's' : ''}',
                      style: AppTextStyles.badge.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),
                  Text(
                    'Dernière: $lastVisitStr',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ],
          ),
        ),
        Icon(
          isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
          color: AppColors.textHint,
        ),
      ],
    );
  }



  Widget _buildExpandedContent() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimelineSection(),
        ],
      ),
    );
  }

  Widget _buildTimelineSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Visites précédentes', style: AppTextStyles.sectionHeader),
        const SizedBox(height: AppSpacing.sm),
        ...summary.visits.map((visit) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _VisitCard(visit: visit),
        )),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Aujourd\'hui';
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} jours';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _VisitCard extends StatelessWidget {
  final AppointmentData visit;

  const _VisitCard({required this.visit});

  Color _visitColor() {
    if (visit.status == 'cancelled') return AppColors.error;
    if (visit.bookingType == 'home') return AppColors.aptHomeVisitText;
    if (visit.isConsultation) return AppColors.aptInPersonText;
    return AppColors.primary;
  }

  Color _visitBg() {
    if (visit.status == 'cancelled') return AppColors.error.withValues(alpha: 0.15);
    if (visit.bookingType == 'home') return AppColors.aptHomeVisit;
    if (visit.isConsultation) return AppColors.aptInPerson;
    return AppColors.aptVideoCall;
  }

  String _visitLabel() {
    if (visit.bookingType == 'home') return 'Domicile';
    if (visit.isConsultation) return 'Consultation';
    return 'RDV';
  }

  @override
  Widget build(BuildContext context) {
    final color = _visitColor();
    final bgColor = _visitBg();
    final label = _visitLabel();
    final isCancelled = visit.status == 'cancelled';
    final dateStr = '${visit.startTime.day.toString().padLeft(2, '0')}/'
        '${visit.startTime.month.toString().padLeft(2, '0')}/'
        '${visit.startTime.year}';
    final timeStr =
        '${visit.startTime.hour.toString().padLeft(2, '0')}:${visit.startTime.minute.toString().padLeft(2, '0')}';
    final endStr =
        '${visit.endTime.hour.toString().padLeft(2, '0')}:${visit.endTime.minute.toString().padLeft(2, '0')}';

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: isCancelled
            ? Border.all(color: AppColors.error.withValues(alpha: 0.4))
            : Border.all(color: color.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 44,
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
                  '$dateStr • $timeStr - $endStr',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isCancelled ? AppColors.error : AppColors.textPrimary,
                    decoration: isCancelled ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isCancelled
                        ? AppColors.error.withValues(alpha: 0.1)
                        : color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isCancelled ? 'Annulé' : label,
                    style: AppTextStyles.badge.copyWith(
                      color: isCancelled ? AppColors.error : color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
