import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:eyadati_kit/core/constants/app_colors.dart';
import 'package:eyadati_kit/core/constants/app_spacing.dart';
import 'package:eyadati_kit/core/constants/app_radius.dart';
import 'package:eyadati_kit/core/widgets/cards/info_card.dart';
import 'package:eyadati_kit/core/utils/phone_launcher.dart';
import 'package:eyadati_kit/l10n/app_localizations.dart';
import '../providers/providers.dart';

class DoctorDetailsPage extends ConsumerStatefulWidget {
  final String doctorId;

  const DoctorDetailsPage({super.key, required this.doctorId});

  @override
  ConsumerState<DoctorDetailsPage> createState() => _DoctorDetailsPageState();
}

class _DoctorDetailsPageState extends ConsumerState<DoctorDetailsPage>
    with SingleTickerProviderStateMixin {
  String _getInitials(String name) {
    if (name.isEmpty) return 'D';
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'D';
    final parts = trimmed.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'D';
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, 1).toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(favoritesProvider.notifier).loadFavorites(),
    );
  }

  Future<void> _callDoctor(String? phone) async {
    if (phone == null || phone.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.bookingPhoneUnavailable)),
        );
      }
      return;
    }
    final launched = await launchPhoneUrl(phone, context);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.bookingPhoneUnavailable)),
      );
    }
  }

  Future<void> _openMaps(Doctor doctor) async {
    final String url;
    if (doctor.mapsLink != null && doctor.mapsLink!.isNotEmpty) {
      url = doctor.mapsLink!;
    } else if (doctor.address.isNotEmpty) {
      final encoded = Uri.encodeComponent(doctor.address);
      url = 'https://www.google.com/maps/search/?api=1&query=$encoded';
    } else if (doctor.latitude != null && doctor.longitude != null) {
      url = 'https://www.google.com/maps/search/?api=1&query=${doctor.latitude},${doctor.longitude}';
    } else {
      return;
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showActionsDialog(Doctor doctor) {
    showDialog(
      context: context,
      builder: (ctx) => _DoctorActionsDialog(
        doctor: doctor,
        onBookOnline: () {
          Navigator.pop(ctx);
          context.push('/patient/doctors/${doctor.id}/book');
        },
        onCall: () {
          Navigator.pop(ctx);
          _callDoctor(doctor.phone);
        },
        onGps: () {
          Navigator.pop(ctx);
          _openMaps(doctor);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final doctorsState = ref.watch(doctorsProvider);
    final favoritesState = ref.watch(favoritesProvider);
    final doctor = doctorsState.doctors.firstWhere(
      (d) => d.id == widget.doctorId,
      orElse: () =>
          Doctor(id: widget.doctorId, name: l10n.roleDoctor, specialty: l10n.doctorsFilterSpecialty, address: ''),
    );
    final isFavorite = favoritesState.favoriteDoctorIds.contains(
      widget.doctorId,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.primary,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.white,
                      backgroundImage: doctor.photoUrl != null
                          ? CachedNetworkImageProvider(doctor.photoUrl!)
                          : null,
                      child: doctor.photoUrl == null
                          ? Text(
                              _getInitials(doctor.name),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      doctor.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      doctor.specialty,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => ref
                    .read(favoritesProvider.notifier)
                    .toggleFavorite(widget.doctorId, context: context),
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? AppColors.error : Colors.white,
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                  _StatItem(
                    icon: Icons.work,
                    value: doctor.specialty,
                    label: l10n.doctorsFilterSpecialty,
                    iconColor: AppColors.primary,
                  ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.doctorDetailsAbout,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    doctor.bio ?? 'Docteur.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.doctorDetailsInfo,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (doctor.city != null)
                    InfoCard(
                      title: l10n.doctorDetailsCity,
                      value: doctor.city!,
                      icon: Icons.location_on,
                      iconColor: AppColors.primary,
                    ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.card,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: _ActionBar(doctor: doctor, onTap: () => _showActionsDialog(doctor)),
        ),
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onTap;

  const _ActionBar({required this.doctor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.sparkles, size: 20, color: Colors.white),
              const SizedBox(width: AppSpacing.sm),
              Text(
                AppLocalizations.of(context)!.doctorDetailsBookNow,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoctorActionsDialog extends StatefulWidget {
  final Doctor doctor;
  final VoidCallback onBookOnline;
  final VoidCallback onCall;
  final VoidCallback onGps;

  const _DoctorActionsDialog({
    required this.doctor,
    required this.onBookOnline,
    required this.onCall,
    required this.onGps,
  });

  @override
  State<_DoctorActionsDialog> createState() => _DoctorActionsDialogState();
}

class _DoctorActionsDialogState extends State<_DoctorActionsDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: const Cubic(0.34, 1.56, 0.64, 1),
    );
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final doctor = widget.doctor;

    return AnimatedBuilder(
      animation: _fadeAnim,
      builder: (context, child) => Opacity(
        opacity: _fadeAnim.value,
        child: child,
      ),
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        contentPadding: EdgeInsets.zero,
        content: AnimatedBuilder(
          animation: _scaleAnim,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnim.value,
            child: child,
          ),
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      doctor.name.isNotEmpty
                          ? doctor.name.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase()
                          : 'DR',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  doctor.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
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
                if (doctor.address.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    doctor.address,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                const Divider(height: 1),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: LucideIcons.calendarPlus,
                        label: l10n.bookingBookOnline,
                        color: AppColors.primary,
                        delay: 0,
                        controller: _controller,
                        onTap: widget.onBookOnline,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _ActionButton(
                        icon: LucideIcons.phone,
                        label: l10n.bookingCallOffice,
                        color: AppColors.success,
                        delay: 1,
                        controller: _controller,
                        onTap: widget.onCall,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _ActionButton(
                        icon: LucideIcons.mapPin,
                        label: 'GPS',
                        color: AppColors.secondary,
                        delay: 2,
                        controller: _controller,
                        onTap: widget.onGps,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final int delay;
  final AnimationController controller;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.delay,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final delayStart = delay * 0.12;
        final t = ((controller.value - delayStart) / (1 - delayStart)).clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(0, 30 * (1 - t)),
          child: Opacity(
            opacity: t,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
