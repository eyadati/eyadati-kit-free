import 'dart:html' as html;
import 'dart:js' as js;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../theme/text_styles.dart';
import '../../providers/version_update_provider.dart';

class AppWithUpdateBanner extends ConsumerStatefulWidget {
  final Widget child;
  const AppWithUpdateBanner({super.key, required this.child});

  @override
  ConsumerState<AppWithUpdateBanner> createState() => _AppWithUpdateBannerState();
}

class _AppWithUpdateBannerState extends ConsumerState<AppWithUpdateBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _listenForSwUpdates();
  }

  void _listenForSwUpdates() {
    if (!kIsWeb) return;

    html.window.addEventListener('pwaUpdateAvailable', (_) {
      if (mounted) _animCtrl.forward();
    });
  }

  void _applyUpdate() {
    js.context.callMethod('applyAppUpdate');
  }

  void _openStore() {
    if (kIsWeb) {
      js.context.callMethod('applyAppUpdate');
    } else {
      html.window.location.reload();
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vState = ref.watch(versionUpdateProvider);
    ref.listen<VersionUpdateState>(versionUpdateProvider, (_, next) {
      if (next.isUpdateAvailable && mounted) {
        _animCtrl.forward();
      }
    });
    final showBanner = vState.isUpdateAvailable;

    if (vState.isLoading) {
      return widget.child;
    }

    if (vState.isUpdateAvailable && vState.forceUpdate) {
      return _ForceUpdateScreen(
        newVersion: vState.remoteVersion,
        changelog: vState.changelog,
        onUpdate: _openStore,
      );
    }

    return Stack(
      children: [
        widget.child,
        if (showBanner)
          SafeArea(
            child: SlideTransition(
              position: _slideAnim,
              child: Material(
                elevation: 8,
                shadowColor: AppColors.shadow,
                color: Colors.transparent,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.sm,
                    AppSpacing.md,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.system_update_rounded,
                          color: AppColors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Nouvelle version disponible',
                              style: AppTextStyles.sectionTitle.copyWith(
                                color: AppColors.white,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              vState.remoteVersion != null
                                  ? 'Version ${vState.remoteVersion} disponible'
                                  : 'Appuyez pour mettre à jour',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.white.withValues(alpha: 0.85),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          onPressed: kIsWeb ? _applyUpdate : _openStore,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.white,
                            foregroundColor: AppColors.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                          ),
                          child: const Text(
                            'Mettre à jour',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ForceUpdateScreen extends StatelessWidget {
  final String? newVersion;
  final String? changelog;
  final VoidCallback onUpdate;

  const _ForceUpdateScreen({
    this.newVersion,
    this.changelog,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.system_update_rounded,
                    size: 64,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Mise à jour requise',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  newVersion != null
                      ? 'Une nouvelle version ($newVersion) est disponible. Veuillez mettre à jour pour continuer à utiliser l\'application.'
                      : 'Une nouvelle version est disponible. Veuillez mettre à jour pour continuer.',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (changelog != null && changelog!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.border,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nouveautés :',
                          style: AppTextStyles.labelMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          changelog!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: onUpdate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Mettre à jour maintenant',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
