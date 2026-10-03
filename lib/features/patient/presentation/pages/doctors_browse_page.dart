import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/inputs/app_search_field.dart';
import '../../../../core/widgets/cards/empty_state_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/providers.dart';
import '../widgets/search_filter_dialog.dart';

class DoctorsBrowsePage extends ConsumerStatefulWidget {
  const DoctorsBrowsePage({super.key});

  @override
  ConsumerState<DoctorsBrowsePage> createState() => _DoctorsBrowsePageState();
}

class _DoctorsBrowsePageState extends ConsumerState<DoctorsBrowsePage> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(doctorsProvider.notifier).loadDoctors();
      ref.read(favoritesProvider.notifier).loadFavorites();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(doctorsProvider.notifier).setSearchQuery(value);
    });
  }

  Future<void> _refresh() async {
    await ref.read(doctorsProvider.notifier).refresh();
    await ref.read(favoritesProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final doctorsState = ref.watch(doctorsProvider);
    final favoritesState = ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.doctorsBrowseTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.filter),
            onPressed: () => showDialog(
              context: context,
              builder: (ctx) => const SearchFilterDialog(),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: AppSearchField(
              hint: l10n.doctorsSearchPlaceholder,
              controller: _searchController,
              onChanged: _onSearchChanged,
              onClear: () => ref.read(doctorsProvider.notifier).clearSearch(),
            ),
          ),
          Expanded(
            child: Skeletonizer(
              enabled: doctorsState.isLoading,
              child: doctorsState.errorMessage != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              doctorsState.errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.error),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            ElevatedButton(
                              onPressed: () => ref.read(doctorsProvider.notifier).loadDoctors(),
                              child: Text(l10n.commonRetry),
                            ),
                          ],
                        ),
                      ),
                    )
                  : doctorsState.doctors.isEmpty && !doctorsState.isLoading
                      ? Center(
                          child: EmptyStateCard(
                            icon: Icons.search_off,
                            title: l10n.doctorsNoResults,
                            message: l10n.doctorsNoResults,
                          ),
                        )
                  : RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: doctorsState.doctors.length,
                        itemBuilder: (context, index) {
                          final doctor = doctorsState.doctors[index];
                          final isFav = favoritesState.favoriteDoctorIds.contains(doctor.id);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: _DoctorListCard(
                              doctor: doctor,
                              isFavorite: isFav,
                              onTap: () => context.push('/patient/doctors/${doctor.id}'),
                              onFavoriteToggle: () => ref.read(favoritesProvider.notifier).toggleFavorite(doctor.id, context: context),

                            ),
                          );
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BottomNavigationBar(
      currentIndex: 1,
      onTap: (index) {
        switch (index) {
          case 0:
            context.go(RouteNames.patientHome);
            break;
          case 1:
            break;
          case 2:
            context.push(RouteNames.patientAppointments);
            break;
          case 3:
            context.push(RouteNames.patientFavorites);
            break;
          case 4:
            context.push(RouteNames.patientProfile);
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: l10n.navHome),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: l10n.navDoctors),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: l10n.navAppointments),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: l10n.navFavorites),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: l10n.navProfile),
      ],
    );
  }
}

class _DoctorListCard extends StatelessWidget {
  final Doctor doctor;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const _DoctorListCard({
    required this.doctor,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                doctor.name.isNotEmpty ? doctor.name[0].toUpperCase() : 'D',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    doctor.specialty,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: onFavoriteToggle,
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? AppColors.error : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
