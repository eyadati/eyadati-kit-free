import 'package:flutter/material.dart';
import 'package:eyadati_kit/core/constants/app_regions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:eyadati_kit/core/constants/app_colors.dart';
import 'package:eyadati_kit/core/constants/app_spacing.dart';
import 'package:eyadati_kit/core/theme/text_styles.dart';
import 'package:eyadati_kit/core/widgets/buttons/primary_button.dart';
import 'package:eyadati_kit/core/widgets/inputs/app_text_field.dart';
import 'package:eyadati_kit/core/widgets/inputs/app_dropdown.dart';
import 'package:eyadati_kit/core/utils/maps_utils.dart';
import '../providers/doctor_provider.dart';
import '../../../../core/utils/supabase_client.dart';

class DoctorEditProfilePage extends ConsumerStatefulWidget {
  const DoctorEditProfilePage({super.key});

  @override
  ConsumerState<DoctorEditProfilePage> createState() => _DoctorEditProfilePageState();
}

class _DoctorEditProfilePageState extends ConsumerState<DoctorEditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _mapsLinkController;
  String _selectedCity = '';
  String _selectedSpecialty = '';
  int _appointmentDuration = 30;
  int _consultationDuration = 20;
  bool _isLoading = false;
  bool _isUploadingPhoto = false;
  String? _photoUrl;

  static const List<String> algerianCities = AppRegions.cities;

  final List<String> _specialties = [
    'Médecin généraliste',
    'Cardiologue',
    'Dermatologue',
    'Pédiatre',
    'Gynécologue',
    'Orthopédiste',
    'Neurologue',
    'Ophtalmologue',
    'Psychiatre',
    'Dentiste',
    'Urologue',
    'Otorhinolaryngologue',
    'Radiologue',
    'Anesthésiste',
    'Autres',
  ];

  @override
  void initState() {
    super.initState();
    final state = ref.read(doctorProvider);
    _nameController = TextEditingController(text: state.name);
    _phoneController = TextEditingController(text: state.phone);
    _addressController = TextEditingController(text: state.address);
    _mapsLinkController = TextEditingController(text: state.mapsLink ?? '');
    _selectedCity = state.city;
    _selectedSpecialty = state.specialty;
    _appointmentDuration = state.appointmentDuration;
    _consultationDuration = state.consultationDuration;
    _photoUrl = state.avatarUrl.isNotEmpty ? state.avatarUrl : null;
    if (_photoUrl == null && state.userId != null) {
      _loadExistingPhoto(state.userId!);
    }
  }

  Future<void> _loadExistingPhoto(String userId) async {
    try {
      final response = await SupabaseInitializer.client
          .from('doctors')
          .select('photo_url')
          .eq('id', userId)
          .maybeSingle();
      if (response != null && response['photo_url'] != null) {
        if (mounted) {
          setState(() => _photoUrl = response['photo_url'] as String);
        }
      }
    } catch (_) {
      // Silently fail — user can still upload a new photo
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _mapsLinkController.dispose();
    super.dispose();
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

      final client = SupabaseInitializer.client;
      await client.storage.from('avatars').uploadBinary(path, bytes);
      final publicUrl = client.storage.from('avatars').getPublicUrl(path);

      setState(() => _photoUrl = publicUrl);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'upload de la photo: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final userId = ref.read(doctorProvider).userId;
      if (userId == null) throw Exception('Not authenticated');

      final client = SupabaseInitializer.client;
      final mapsLink = _mapsLinkController.text.trim().isEmpty
          ? null
          : _mapsLinkController.text.trim();

      double? latitude;
      double? longitude;
      if (mapsLink != null) {
        final coords = parseGoogleMapsLink(mapsLink);
        latitude = coords.lat;
        longitude = coords.lng;
      }

      await client.from('profiles').update({
        'full_name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'city': _selectedCity,
        'avatar_url': _photoUrl,
      }).eq('id', userId);

      await client.from('doctors').update({
        'specialty': _selectedSpecialty,
        'city': _selectedCity,
        'address': _addressController.text.trim(),
        'maps_link': mapsLink,
        'latitude': latitude,
        'longitude': longitude,
        'photo_url': _photoUrl,
        'appointment_duration': _appointmentDuration,
        'consultation_duration': _consultationDuration,
      }).eq('id', userId);

      await ref.read(doctorProvider.notifier).refresh();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profil mis à jour'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Modifier le profil'),
        foregroundColor: Colors.white,
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              _buildPhotoUpload(),
              const SizedBox(height: AppSpacing.xl),
              _buildSectionCard(
                title: 'Informations personnelles',
                icon: LucideIcons.user,
                child: Column(
                  children: [
                    AppTextField(
                      controller: _nameController,
                      label: 'Nom complet',
                      hint: 'Entrez votre nom',
                      prefixIcon: LucideIcons.user,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Requis' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _phoneController,
                      label: 'Téléphone',
                      hint: '0555 00 00 00',
                      prefixIcon: LucideIcons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppDropdown<String>(
                      label: 'Spécialité',
                      hint: 'Sélectionnez votre spécialité',
                      value: _selectedSpecialty.isNotEmpty ? _selectedSpecialty : null,
                      items: _specialties.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (v) => setState(() => _selectedSpecialty = v ?? ''),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppDropdown<String>(
                      label: 'Ville',
                      hint: 'Sélectionnez votre ville',
                      value: _selectedCity.isNotEmpty ? _selectedCity : null,
                      items: algerianCities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setState(() => _selectedCity = v ?? ''),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildSectionCard(
                title: 'Cabinet',
                icon: LucideIcons.building,
                child: Column(
                  children: [
                    AppTextField(
                      controller: _addressController,
                      label: 'Adresse du cabinet',
                      hint: '123 Main Street, City',
                      prefixIcon: LucideIcons.mapPin,
                      keyboardType: TextInputType.streetAddress,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _mapsLinkController,
                      label: 'Lien Google Maps',
                      hint: 'https://maps.google.com/...',
                      prefixIcon: LucideIcons.map,
                      keyboardType: TextInputType.url,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildSectionCard(
                title: 'Durées',
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
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                onPressed: _isLoading ? null : _save,
                label: 'Enregistrer',
                isLoading: _isLoading,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoUpload() {
    return Center(
      child: GestureDetector(
        onTap: _isUploadingPhoto ? null : _pickImage,
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
                  ? const Icon(LucideIcons.camera, size: 32, color: AppColors.textHint)
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
                  child: const Icon(LucideIcons.pencil, size: 12, color: Colors.white),
                ),
              ),
          ],
        ),
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
            child: Text(
              '$minutes min',
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? AppColors.white : AppColors.textPrimary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
