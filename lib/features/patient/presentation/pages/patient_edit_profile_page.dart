import 'package:flutter/material.dart';
import 'package:eyadati_kit/core/constants/app_regions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../core/widgets/inputs/app_dropdown.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/providers.dart';

class PatientEditProfilePage extends ConsumerStatefulWidget {
  const PatientEditProfilePage({super.key});

  @override
  ConsumerState<PatientEditProfilePage> createState() => _PatientEditProfilePageState();
}

class _PatientEditProfilePageState extends ConsumerState<PatientEditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  String _selectedCity = '';
  bool _isLoading = false;

  static const List<String> algerianCities = AppRegions.cities;

  @override
  void initState() {
    super.initState();
    final state = ref.read(patientProvider).valueOrNull;
    _nameController = TextEditingController(text: state?.name ?? '');
    _phoneController = TextEditingController(text: state?.phone ?? '');
    _selectedCity = state?.city ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);

    try {
      final success = await ref.read(patientProvider.notifier).updateProfile(
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        city: _selectedCity,
      );

      if (mounted) {
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.profileUpdateSuccess),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.profileUpdateError),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.commonError}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.profileEditProfile),
        foregroundColor: AppColors.textPrimary,
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.profilePersonalInfo,
                style: AppTextStyles.sectionHeader,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _nameController,
                label: l10n.authNameLabel,
                hint: l10n.profileNameHint,
                prefixIcon: LucideIcons.user,
                validator: (v) => v == null || v.trim().isEmpty ? l10n.validationNameRequired : null,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _phoneController,
                label: l10n.authPhoneLabel,
                hint: '0555 00 00 00',
                prefixIcon: LucideIcons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppSpacing.md),
              AppDropdown<String>(
                label: l10n.profileCity,
                hint: l10n.profileCityHint,
                value: _selectedCity.isNotEmpty ? _selectedCity : null,
                items: algerianCities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _selectedCity = v ?? ''),
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                onPressed: _isLoading ? null : _save,
                label: l10n.commonSave,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
