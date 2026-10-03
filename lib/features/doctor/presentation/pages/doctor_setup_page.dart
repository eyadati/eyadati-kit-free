import 'package:flutter/material.dart';
import 'package:eyadati_kit/core/constants/app_regions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../core/widgets/inputs/app_dropdown.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/doctor_provider.dart';

class DoctorSetupPage extends ConsumerStatefulWidget {
  const DoctorSetupPage({super.key});

  @override
  ConsumerState<DoctorSetupPage> createState() => _DoctorSetupPageState();
}

class _DoctorSetupPageState extends ConsumerState<DoctorSetupPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final List<String> _weekDays = ['lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche'];
  final Set<String> _selectedDays = {};
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);
  TimeOfDay? _breakStart;
  TimeOfDay? _breakEnd;
  int _consultationDuration = 20;
  int _appointmentDuration = 30;
  String? _specialty;
  String? _city;
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _mapsLinkController = TextEditingController();
  String? _photoUrl;
  bool _isUploadingPhoto = false;

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

  static const List<String> algerianCities = AppRegions.cities;

  final List<String> _cities = algerianCities;

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    _mapsLinkController.dispose();
    super.dispose();
  }

  String _formatTimeForDb(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
  }

  int _timeToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800, maxHeight: 800, imageQuality: 80);
    if (image == null) return;

    setState(() => _isUploadingPhoto = true);
    try {
      final bytes = await image.readAsBytes();
      final fileName = '${const Uuid().v4()}.jpg';
      final path = 'avatars/$fileName';

      await Supabase.instance.client.storage.from('avatars').uploadBinary(path, bytes);
      final url = Supabase.instance.client.storage.from('avatars').getPublicUrl(path);

      setState(() => _photoUrl = url);
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, message: 'Erreur lors de l\'upload de la photo');
      }
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _selectBreakTime(bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? const TimeOfDay(hour: 12, minute: 0) : const TimeOfDay(hour: 14, minute: 0),
      helpText: isStart ? 'Heure de début de pause' : 'Heure de fin de pause',
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _breakStart = picked;
        } else {
          _breakEnd = picked;
        }
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDays.isEmpty) {
      AppSnackbar.showError(context, message: 'Sélectionnez au moins un jour de travail');
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('[DoctorSetupPage] Starting setup submission...');
      
      await ref.read(doctorProvider.notifier).saveSetup(
        startTime: _timeToMinutes(_startTime),
        endTime: _timeToMinutes(_endTime),
        consultationDuration: _consultationDuration,
        appointmentDuration: _appointmentDuration,
        specialty: _specialty!,
        city: _city!,
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        workingDays: _selectedDays.toList(),
        mapsLink: _mapsLinkController.text.trim().isEmpty ? null : _mapsLinkController.text.trim(),
        photoUrl: _photoUrl,
        breakStart: _breakStart != null ? _timeToMinutes(_breakStart!) : null,
        breakEnd: _breakEnd != null ? _timeToMinutes(_breakEnd!) : null,
      );

      print('[DoctorSetupPage] Setup saved, checking state...');

      if (!mounted) return;

      final authState = ref.read(authProvider);
      print('[DoctorSetupPage] Auth state after save - setupCompleted: ${authState.setupCompleted}');
      
      final doctorState = ref.read(doctorProvider);
      print('[DoctorSetupPage] Doctor state - setupCompleted: ${doctorState.setupCompleted}');

      if (!mounted) return;

      if (doctorState.setupCompleted) {
        AppSnackbar.showSuccess(context, message: 'Configuration enregistrée !');
        
        print('[DoctorSetupPage] Refreshing setup status...');
        await ref.read(authProvider.notifier).refreshSetupStatus();
        
        if (!mounted) return;
        
        final updatedAuthState = ref.read(authProvider);
        print('[DoctorSetupPage] Updated auth state - setupCompleted: ${updatedAuthState.setupCompleted}');
        
        if (updatedAuthState.setupCompleted) {
          print('[DoctorSetupPage] Navigating to dashboard...');
          context.go('/doctor/dashboard');
        } else {
          print('[DoctorSetupPage] Setup still not completed after refresh');
          AppSnackbar.showError(context, message: 'Erreur lors de la configuration');
        }
      } else {
        print('[DoctorSetupPage] Setup not marked as completed, showing error');
        AppSnackbar.showError(context, message: 'Erreur lors de la configuration');
      }
    } catch (e) {
      print('[DoctorSetupPage] Error: $e');
      if (!mounted) return;
      AppSnackbar.showError(context, message: 'Erreur: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectTime(bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      helpText: isStart ? 'Heure de début' : 'Heure de fin',
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoBanner(),
                        const SizedBox(height: AppSpacing.xl),
                        _buildSectionCard(
                          title: 'Horaires de travail',
                          icon: LucideIcons.clock,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionLabel('Jours de travail'),
                              const SizedBox(height: AppSpacing.sm),
                              _buildDaySelector(),
                              const SizedBox(height: AppSpacing.lg),
                              _buildSectionLabel('Heures'),
                              const SizedBox(height: AppSpacing.sm),
                              _buildTimeSelectors(),
                              const SizedBox(height: AppSpacing.lg),
                              _buildSectionLabel('Pause (optionnel)'),
                              const SizedBox(height: AppSpacing.sm),
                              _buildBreakTimeSelectors(),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _buildSectionCard(
                          title: 'Durées de consultation',
                          icon: LucideIcons.timer,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionLabel('Durée des rendez-vous'),
                              const SizedBox(height: AppSpacing.sm),
                              _buildDurationSelector(
                                options: [20, 30, 45, 60],
                                selected: _appointmentDuration,
                                onChanged: (v) => setState(() => _appointmentDuration = v),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              _buildSectionLabel('Durée des consultations'),
                              const SizedBox(height: AppSpacing.sm),
                              _buildDurationSelector(
                                options: [10, 15, 20, 30],
                                selected: _consultationDuration,
                                onChanged: (v) => setState(() => _consultationDuration = v),
                                isSecondary: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _buildSectionCard(
                          title: 'Informations du cabinet',
                          icon: LucideIcons.building,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildPhotoUpload(),
                              const SizedBox(height: AppSpacing.lg),
                              AppTextField(
                                label: 'Numéro de téléphone',
                                hint: '05 XX XX XX XX',
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                prefixIcon: LucideIcons.phone,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Numéro de téléphone requis';
                                  }
                                  if (!RegExp(r'^(05|06|07|03)\d{8}$').hasMatch(value.replaceAll(' ', ''))) {
                                    return 'Format invalide (ex: 05XX XX XX XX)';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppSpacing.md),
                              AppDropdown(
                                label: 'Spécialité',
                                value: _specialty,
                                items: _specialties.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                                onChanged: (value) => setState(() => _specialty = value),
                                validator: (value) => value == null || value.isEmpty ? 'Spécialité requise' : null,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              AppTextField(
                                label: 'Adresse du cabinet',
                                hint: '123 Main Street, City',
                                controller: _addressController,
                                keyboardType: TextInputType.streetAddress,
                                prefixIcon: LucideIcons.mapPin,
                                validator: (value) => value == null || value.isEmpty ? 'Adresse requise' : null,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              AppTextField(
                                label: 'Lien Google Maps (optionnel)',
                                hint: 'https://maps.google.com/...',
                                controller: _mapsLinkController,
                                keyboardType: TextInputType.url,
                                prefixIcon: LucideIcons.map,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              AppDropdown(
                                label: 'Ville',
                                value: _city,
                                items: _cities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                                onChanged: (value) => setState(() => _city = value),
                                validator: (value) => value == null || value.isEmpty ? 'Ville requise' : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                          SizedBox(
                            width: double.infinity,
                            child: PrimaryButton(
                              label: 'Terminer la configuration',
                              isLoading: _isLoading,
                              onPressed: _handleSubmit,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Center(
                            child: Text(
                              'Vous pourrez modifier ces informations plus tard',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textHint,
                              ),
                            ),
                          ),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppSpacing.md,
        bottom: AppSpacing.lg,
        left: AppSpacing.md,
        right: AppSpacing.md,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
            onPressed: () => _showExitDialog(),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Configuration du cabinet',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Étape 1 sur 1',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.stethoscope, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(LucideIcons.info, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Complétez votre profil pour commencer à recevoir des patients.',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 18),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(title, style: AppTextStyles.cardTitle),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.border.withValues(alpha: 0.5)),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(label, style: AppTextStyles.labelMedium);
  }

  Widget _buildDaySelector() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: _weekDays.map((day) {
        final isSelected = _selectedDays.contains(day);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedDays.remove(day);
              } else {
                _selectedDays.add(day);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Text(
              day.substring(0, 3).toUpperCase(),
              style: TextStyle(
                color: isSelected ? AppColors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimeSelectors() {
    return Row(
      children: [
        Expanded(
          child: _TimeSelector(
            label: 'Début',
            time: _formatTime(_startTime),
            onTap: () => _selectTime(true),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Icon(LucideIcons.arrowRight, color: AppColors.textHint, size: 16),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _TimeSelector(
            label: 'Fin',
            time: _formatTime(_endTime),
            onTap: () => _selectTime(false),
          ),
        ),
      ],
    );
  }

  Widget _buildBreakTimeSelectors() {
    return Row(
      children: [
        Expanded(
          child: _TimeSelector(
            label: 'Début pause',
            time: _breakStart != null ? _formatTime(_breakStart!) : '--:--',
            onTap: () => _selectBreakTime(true),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Icon(LucideIcons.arrowRight, color: AppColors.textHint, size: 16),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _TimeSelector(
            label: 'Fin pause',
            time: _breakEnd != null ? _formatTime(_breakEnd!) : '--:--',
            onTap: () => _selectBreakTime(false),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoUpload() {
    return GestureDetector(
      onTap: _isUploadingPhoto ? null : _pickImage,
      child: Center(
        child: Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 2),
                image: _photoUrl != null
                    ? DecorationImage(
                        image: NetworkImage(_photoUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _photoUrl == null
                  ? Icon(LucideIcons.camera, size: 32, color: AppColors.textHint)
                  : null,
            ),
            if (_isUploadingPhoto)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    ),
                  ),
                ),
              ),
            if (_photoUrl != null && !_isUploadingPhoto)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(LucideIcons.pencil, size: 12, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationSelector({
    required List<int> options,
    required int selected,
    required ValueChanged<int> onChanged,
    bool isSecondary = false,
  }) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: options.map((minutes) {
        final isSelected = selected == minutes;
        final color = isSecondary ? AppColors.secondary : AppColors.primary;
        return GestureDetector(
          onTap: () => onChanged(minutes),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isSelected ? color : AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? color : AppColors.border,
              ),
            ),
            child: Text('$minutes min', style: AppTextStyles.labelMedium.copyWith(color: isSelected ? AppColors.white : AppColors.textPrimary)),
          ),
        );
      }).toList(),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quitter la configuration ?'),
        content: const Text(
          'Vous devrez compléter votre profil avant de pouvoir utiliser l\'application.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continuer'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(RouteNames.login);
            },
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }
}

class _TimeSelector extends StatelessWidget {
  final String label;
  final String time;
  final VoidCallback onTap;

  const _TimeSelector({
    required this.label,
    required this.time,
    required this.onTap,
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
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.labelSmall),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Icon(LucideIcons.clock, size: 16, color: AppColors.primary),
                const SizedBox(width: AppSpacing.xs),
                Text(time, style: AppTextStyles.titleSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
