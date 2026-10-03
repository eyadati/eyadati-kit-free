import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/buttons/icon_button_tile.dart';
import '../../../../core/widgets/buttons/danger_button.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/providers.dart';

class PatientProfilePage extends ConsumerStatefulWidget {
  const PatientProfilePage({super.key});

  @override
  ConsumerState<PatientProfilePage> createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends ConsumerState<PatientProfilePage> {
  Future<void> _logout() async {
    final l10nLogout = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10nLogout.profileLogout),
        content: Text(l10nLogout.settingsLogoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10nLogout.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10nLogout.profileLogout),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final authNotifier = ref.read(authProvider.notifier);
      await authNotifier.logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncPatient = ref.watch(patientProvider);
    final localeNotifier = ref.read(localeProvider.notifier);
    final currentLocale = ref.watch(localeProvider);
    final isArabic = currentLocale.languageCode == 'ar';
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.profileTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: asyncPatient.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('$err')),
        data: (patientState) => SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            patientState.name.isNotEmpty
                                ? patientState.name[0].toUpperCase()
                                : 'P',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          patientState.name.isNotEmpty ? patientState.name : 'Patient',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          patientState.email.isNotEmpty ? patientState.email : '',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (patientState.phone.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            patientState.phone,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  IconButtonTile(
                    title: l10n.profileEditProfile,
                    icon: Icons.edit_outlined,
                    onTap: () {},
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  IconButtonTile(
                    title: l10n.profileAccountSettings,
                    icon: Icons.settings_outlined,
                    onTap: () {},
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  IconButtonTile(
                    title: l10n.profileNotifications,
                    icon: Icons.notifications_outlined,
                    onTap: () {},
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  IconButtonTile(
                    title: l10n.profileLanguage,
                    subtitle: isArabic ? 'Français / العربية' : 'Français / Arabe',
                    icon: Icons.language,
                    onTap: () async {
                      final newLocale = isArabic ? 'fr' : 'ar';
                      await localeNotifier.setLocale(newLocale);
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  IconButtonTile(
                    title: l10n.settingsAbout,
                    icon: Icons.info_outline,
                    onTap: () {},
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  DangerButton(
                    label: l10n.profileLogout,
                    icon: Icons.logout,
                    onPressed: _logout,
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
    );
  }
}