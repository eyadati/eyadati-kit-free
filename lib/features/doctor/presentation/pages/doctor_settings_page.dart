import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:eyadati_kit/core/constants/app_colors.dart';
import 'package:eyadati_kit/core/constants/app_spacing.dart';
import 'package:eyadati_kit/core/theme/text_styles.dart';
import 'package:eyadati_kit/core/providers/locale_provider.dart';
import 'package:eyadati_kit/core/routing/route_names.dart';
import 'package:eyadati_kit/core/widgets/feedback/app_snackbar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/doctor_provider.dart';
import 'doctor_change_password_page.dart';
import 'doctor_edit_profile_page.dart';
import 'doctor_privacy_page.dart';
import 'doctor_schedule_page.dart';
import 'doctor_terms_page.dart';

class DoctorSettingsPage extends ConsumerStatefulWidget {
  const DoctorSettingsPage({super.key});

  @override
  ConsumerState<DoctorSettingsPage> createState() => _DoctorSettingsPageState();
}

class _DoctorSettingsPageState extends ConsumerState<DoctorSettingsPage> {
  void _showLanguageSheet() {
    final locale = ref.read(localeProvider);
    final isArabic = locale.languageCode == 'ar';

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Langue', style: AppTextStyles.sectionTitle),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(LucideIcons.x, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildLanguageOption(ctx, 'Français', !isArabic),
              _buildLanguageOption(ctx, 'العربية', isArabic),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext ctx, String label, bool isSelected) {
    return InkWell(
      onTap: () {
        final code = label == 'Français' ? 'fr' : 'ar';
        ref.read(localeProvider.notifier).setLocale(code);
        Navigator.pop(ctx);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.06) : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(LucideIcons.check, size: 18, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deconnexion'),
        content: const Text('Voulez-vous vraiment vous deconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await Future.delayed(const Duration(milliseconds: 100));
              if (context.mounted) {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  context.go(RouteNames.login);
                }
              }
            },
            child: Text(
              'Deconnexion',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer mon compte'),
        content: const Text(
          'Cette action est irréversible. Toutes vos données (rendez-vous, '
          'notes, planning) seront définitivement effacées.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _reAuthForDelete();
            },
            child: Text(
              'Continuer',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _reAuthForDelete() {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer votre mot de passe'),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Mot de passe',
            hintText: 'Entrez votre mot de passe',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (passwordController.text.isEmpty) return;
              await _executeDeleteAccount(passwordController.text);
            },
            child: Text(
              'Supprimer',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _executeDeleteAccount(String password) async {
    final authState = ref.read(authProvider);
    final phone = authState.phone;
    final email = authState.email;

    final repo = ref.read(authRepositoryProvider);
    final reAuth = phone != null
        ? await repo.signInWithPhone(phone: phone, password: password)
        : await repo.signIn(email: email ?? '', password: password);

    if (!reAuth.isSuccess) {
      if (mounted) {
        AppSnackbar.showError(context, message: 'Mot de passe incorrect');
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

  String _getInitials(String name) {
    if (name.isEmpty) return 'DR';
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'DR';
    final parts = trimmed.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'DR';
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, 1).toUpperCase();
  }

  String _buildScheduleSummary(DoctorState state) {
    if (state.scheduleSlots.isEmpty) return 'Non configuré';
    final dayNames = ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'];
    final activeSlots = state.scheduleSlots.where((s) => s.isActive).toList();
    if (activeSlots.isEmpty) return 'Non configuré';
    final workingDays = activeSlots.map((s) => dayNames[s.dayOfWeek]).toList();
    return workingDays.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final doctorState = ref.watch(doctorProvider);
    final locale = ref.watch(localeProvider);
    final isArabic = locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Paramètres',
          style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(doctorState),
            SettingsList(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              lightTheme: SettingsThemeData(
                settingsListBackground: AppColors.background,
                titleTextColor: AppColors.textSecondary,
                leadingIconsColor: AppColors.textSecondary,
                tileDescriptionTextColor: AppColors.textHint,
                trailingTextColor: AppColors.textSecondary,
              ),
              sections: [
                SettingsSection(
                  title: const Text('Compte'),
                  tiles: [
                    SettingsTile(
                      onPressed: (_) => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DoctorEditProfilePage(),
                        ),
                      ),
                      leading: const Icon(LucideIcons.pencil, size: 20),
                      title: const Text('Modifier le profil'),
                    ),
                    SettingsTile(
                      onPressed: (_) => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DoctorSchedulePage(),
                        ),
                      ),
                      leading: const Icon(LucideIcons.clock, size: 20),
                      title: const Text('Horaires de travail'),
                      description: Text(_buildScheduleSummary(doctorState)),
                    ),
                    SettingsTile(
                      onPressed: (_) => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DoctorChangePasswordPage(),
                        ),
                      ),
                      leading: const Icon(LucideIcons.lock, size: 20),
                      title: const Text('Changer le mot de passe'),
                    ),
                    SettingsTile.switchTile(
                      onToggle: (value) async {
                        final success = await ref
                            .read(doctorProvider.notifier)
                            .togglePause(value);
                        if (success) {
                          await ref.read(doctorProvider.notifier).refresh();
                        }
                      },
                      initialValue: doctorState.isPaused,
                      leading: const Icon(LucideIcons.pauseCircle, size: 20),
                      title: const Text('Pause des rendez-vous'),
                      description: Text(
                        doctorState.isPaused ? 'En pause' : 'Visible',
                      ),
                    ),
                  ],
                ),
                SettingsSection(
                  title: const Text('Langue'),
                  tiles: [
                    SettingsTile(
                      onPressed: (_) => _showLanguageSheet(),
                      leading: const Icon(LucideIcons.languages, size: 20),
                      title: const Text('Langue'),
                      value: Text(isArabic ? 'العربية' : 'Français'),
                    ),
                  ],
                ),
                SettingsSection(
                  title: const Text('À propos'),
                  tiles: [
                    SettingsTile(
                      onPressed: (_) => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DoctorTermsPage(),
                        ),
                      ),
                      leading: const Icon(LucideIcons.fileText, size: 20),
                      title: const Text("Conditions d'utilisation"),
                    ),
                    SettingsTile(
                      onPressed: (_) => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DoctorPrivacyPage(),
                        ),
                      ),
                      leading: const Icon(LucideIcons.shield, size: 20),
                      title: const Text('Politique de confidentialité'),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmDeleteAccount(),
                  icon: const Icon(LucideIcons.trash2, size: 18),
                  label: const Text('Supprimer mon compte'),
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
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _confirmLogout,
                  icon: const Icon(LucideIcons.logOut, size: 18),
                  label: const Text('Déconnexion'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(DoctorState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      decoration: const BoxDecoration(
        color: AppColors.background,
      ),
      child: Center(
        child: CircleAvatar(
          radius: 40,
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          backgroundImage: state.avatarUrl.isNotEmpty
              ? CachedNetworkImageProvider(state.avatarUrl)
              : null,
          child: state.avatarUrl.isEmpty
              ? Text(
                  _getInitials(state.name),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                )
              : null,
        ),
      ),
    );
  }

}
