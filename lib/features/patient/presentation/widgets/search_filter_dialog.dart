import 'package:flutter/material.dart';
import 'package:eyadati_kit/core/constants/app_regions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/doctors_provider.dart';
import '../widgets/doctor_results_sheet.dart';

class SearchFilterDialog extends ConsumerStatefulWidget {
  const SearchFilterDialog({super.key});

  @override
  ConsumerState<SearchFilterDialog> createState() => _SearchFilterDialogState();
}

class _SearchFilterDialogState extends ConsumerState<SearchFilterDialog> {
  String? _selectedCity;
  String? _selectedSpecialty;
  bool _isLoading = false;

  static const List<String> algerianCities = AppRegions.cities;

  final List<String> _cities = algerianCities;

  final List<String> _specialties = [
    'Médecin généraliste',
    'Cardiologue',
    'Dermatologue',
    'Pédiatre',
    'Gynécologue',
    'Orthopédiste',
    'Neurologue',
    'Ophtalmologue',
    'Dentiste',
    'Psychiatre',
    'Urologue',
    'Otorhinolaryngologue',
    'Radiologue',
    'Anesthésiste',
    'Autres',
  ];

  void _search() {
    if (_selectedCity == null && _selectedSpecialty == null) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.searchFilterRequired),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    ref.read(doctorsProvider.notifier).setCity(_selectedCity);
    ref.read(doctorsProvider.notifier).setSpecialty(_selectedSpecialty ?? '');

    Navigator.pop(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DoctorResultsSheet(
        city: _selectedCity,
        specialty: _selectedSpecialty,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      backgroundColor: AppColors.card,
      title: Text(
        l10n.doctorsBrowseTitle,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.searchFilterCity,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: DropdownButtonFormField<String>(
              initialValue: _selectedCity,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                border: InputBorder.none,
              ),
              hint: Text(l10n.searchFilterCityHint),
              items: _cities.map((city) {
                return DropdownMenuItem(
                  value: city,
                  child: Text(city),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedCity = value),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.doctorsFilterSpecialty,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: DropdownButtonFormField<String>(
              initialValue: _selectedSpecialty,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                border: InputBorder.none,
              ),
              hint: Text(l10n.searchFilterSpecialtyHint),
              items: _specialties.map((specialty) {
                return DropdownMenuItem(
                  value: specialty,
                  child: Text(specialty),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedSpecialty = value),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            l10n.commonCancel,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        SizedBox(
          width: 140,
          child: PrimaryButton(
            label: l10n.commonSearch,
            isLoading: _isLoading,
            onPressed: _search,
          ),
        ),
      ],
      actionsPadding: const EdgeInsets.all(AppSpacing.md),
    );
  }
}