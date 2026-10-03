import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/providers.dart';
import '../widgets/doctor_card.dart';
import '../widgets/booking_bottom_sheet.dart';

class DoctorResultsSheet extends ConsumerStatefulWidget {
  final String? city;
  final String? specialty;

  const DoctorResultsSheet({
    super.key,
    this.city,
    this.specialty,
  });

  @override
  ConsumerState<DoctorResultsSheet> createState() => _DoctorResultsSheetState();
}

class _DoctorResultsSheetState extends ConsumerState<DoctorResultsSheet> {
  bool _showFavoritesOnly = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final doctorsState = ref.watch(doctorsProvider);
    final favoritesState = ref.watch(favoritesProvider);

    List<Doctor> filteredDoctors = doctorsState.doctors.where((doctor) {
      if (_showFavoritesOnly) {
        return favoritesState.favoriteDoctorIds.contains(doctor.id);
      }
      return true;
    }).toList();

    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: const BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.xxl),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.doctorResultsAvailable,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (widget.city != null || widget.specialty != null)
                          Text(
                            [
                              if (widget.city != null) widget.city,
                              if (widget.specialty != null) widget.specialty,
                            ].join(' • '),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.heart,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Switch(
                          value: _showFavoritesOnly,
                          onChanged: (value) {
                            setState(() => _showFavoritesOnly = value);
                          },
                          activeThumbColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: doctorsState.isLoading
                ? _buildLoadingState()
                : filteredDoctors.isEmpty
                    ? _buildEmptyState()
                    : _buildDoctorList(filteredDoctors),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 16,
                        color: AppColors.border,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 80,
                        height: 12,
                        color: AppColors.border,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            LucideIcons.searchX,
            size: 48,
            color: AppColors.textHint,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _showFavoritesOnly
                ? l10n.doctorResultsNoFavorites
                : l10n.doctorsNoResults,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _showFavoritesOnly
                ? l10n.doctorResultsAddFavorites
                : l10n.doctorResultsTryOther,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorList(List<Doctor> doctors) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: doctors.length,
      itemBuilder: (context, index) {
        final doctor = doctors[index];
        return DoctorCard(
          doctor: doctor,
          onBookNow: () => _showBookingSheet(doctor),
        );
      },
    );
  }

  void _showBookingSheet(Doctor doctor) {
    showDialog(
      context: context,
      builder: (context) => BookingDialog(doctor: doctor),
    );
  }
}