import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/widgets/buttons/danger_button.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/providers.dart';
import '../../../../l10n/app_localizations.dart';

class PatientSettingsPage extends ConsumerStatefulWidget {
  const PatientSettingsPage({super.key});

  @override
  ConsumerState<PatientSettingsPage> createState() => _PatientSettingsPageState();
}

class _PatientSettingsPageState extends ConsumerState<PatientSettingsPage> {
  Future<void> _logout() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xxl)),
        title: Text(l10n.profileLogout),
        content: Text(l10n.logoutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.profileLogout),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final authNotifier = ref.read(authProvider.notifier);
      await authNotifier.logout();
    }
  }

  void _confirmDeleteAccount() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
        ),
        title: Text(l10n.profileDeleteAccount),
        content: Text(l10n.deleteAccountConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _reAuthForDelete();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.commonContinue),
          ),
        ],
      ),
    );
  }

  void _reAuthForDelete() {
    final l10n = AppLocalizations.of(context)!;
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
        ),
        title: Text(l10n.confirmPasswordTitle),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: l10n.authPasswordLabel,
            hintText: l10n.enterPasswordHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (passwordController.text.isEmpty) return;
              await _executeDeleteAccount(passwordController.text);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
  }

  Future<void> _executeDeleteAccount(String password) async {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.read(authProvider);
    final phone = authState.phone;
    final email = authState.email;

    final repo = ref.read(authRepositoryProvider);
    final reAuth = phone != null
        ? await repo.signInWithPhone(phone: phone, password: password)
        : await repo.signIn(email: email ?? '', password: password);

    if (!reAuth.isSuccess) {
      if (mounted) {
        AppSnackbar.showError(context, message: l10n.wrongPassword);
      }
      return;
    }

    final error = await ref.read(authProvider.notifier).deleteAccount();
    if (!mounted) return;

    if (error == null) {
      context.go(RouteNames.login);
    } else {
      AppSnackbar.showError(context, message: error);
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
        backgroundColor: AppColors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          l10n.settingsTitle,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
        ),
      ),
      body: asyncPatient.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => Center(child: Text('$err')),
        data: (patientState) => SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(AppRadius.xxl),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                          ),
                          child: Center(
                            child: Text(
                              patientState.name.isNotEmpty
                                  ? patientState.name[0].toUpperCase()
                                  : 'P',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                patientState.name.isNotEmpty ? patientState.name : 'Patient',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (patientState.phone.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      LucideIcons.phone,
                                      size: 14,
                                      color: AppColors.textHint,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      patientState.phone,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (patientState.email.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(
                                      LucideIcons.mail,
                                      size: 14,
                                      color: AppColors.textHint,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        patientState.email,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.pencil, size: 18),
                          color: AppColors.primary,
                          onPressed: () => context.push(RouteNames.patientEditProfile),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.settingsPreferences,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    child: Column(
                      children: [
                        _SettingsTile(
                          icon: LucideIcons.globe,
                          title: l10n.settingsLanguage,
                          subtitle: l10n.settingsLanguage,
                          onTap: () async {
                            final newLocale = isArabic ? 'fr' : 'ar';
                            await localeNotifier.setLocale(newLocale);
                          },
                        ),
                        const Divider(height: 1, indent: 56),
                        _SettingsTile(
                          icon: LucideIcons.bell,
                          title: l10n.settingsNotifications,
                          subtitle: l10n.settingsNotificationsEnabled,
                          onTap: () {},
                        ),
                        const Divider(height: 1, indent: 56),
                        _SettingsTile(
                          icon: LucideIcons.info,
                          title: l10n.settingsAbout,
                          subtitle: '${l10n.settingsVersion} 1.0.0',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _confirmDeleteAccount,
                      icon: const Icon(LucideIcons.trash2, size: 18),
                      label: Text(l10n.profileDeleteAccount),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DangerButton(
                    label: l10n.profileLogout,
                    icon: LucideIcons.logOut,
                    onPressed: _logout,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              LucideIcons.chevronRight,
              size: 20,
              color: AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }
}