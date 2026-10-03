import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../core/widgets/inputs/password_field.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/utils/input_validator.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_footer.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _patientFormKey = GlobalKey<FormState>();
  final _doctorFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isDoctor = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handlePatientRegister() async {
    if (!_patientFormKey.currentState!.validate()) return;

    final phone = InputValidator.formatPhoneForE164(
      _phoneController.text.trim(),
    );

    final notifier = ref.read(authProvider.notifier);
    notifier.setPhone(phone);

    final success = await notifier.directPhoneRegister(
      name: _nameController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      context.go(RouteNames.patientHome);
    } else {
      final error = ref.read(authProvider).errorMessage;
      AppSnackbar.showError(
        context,
        message: error ?? "Erreur lors de l'inscription",
      );
    }
  }

  Future<void> _handleDoctorRegister() async {
    if (!_doctorFormKey.currentState!.validate()) return;

    final success = await ref
        .read(authProvider.notifier)
        .register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
          phone: '',
          role: 'doctor',
        );

    if (!mounted) return;

    if (success) {
      context.go(RouteNames.doctorDashboard);
    } else {
      final error = ref.read(authProvider).errorMessage;
      AppSnackbar.showError(
        context,
        message: error ?? "Erreur lors de l'inscription",
      );
    }
  }

  Widget _buildPatientForm(AppAuthState authState) {
    return Form(
      key: _patientFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            label: 'Nom complet',
            hint: 'Votre nom',
            controller: _nameController,
            prefixIcon: Icons.person_outline,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Nom requis';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Téléphone',
            hint: '05 55 12 34 56',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_outlined,
            textInputAction: TextInputAction.next,
            validator: (value) => InputValidator.validateAlgerianPhone(value),
          ),
          const SizedBox(height: AppSpacing.md),
          PasswordField(
            label: 'Mot de passe',
            hint: '••••••••',
            controller: _passwordController,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Mot de passe requis';
              if (value.length < 6) return 'Minimum 6 caractères';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          PasswordField(
            label: 'Confirmer le mot de passe',
            hint: '••••••••',
            controller: _confirmPasswordController,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handlePatientRegister(),
            validator: (value) {
              if (value != _passwordController.text) {
                return 'Les mots de passe ne correspondent pas';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: "S'inscrire",
            isLoading: authState.isLoading,
            onPressed: _handlePatientRegister,
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorForm(AppAuthState authState) {
    return Form(
      key: _doctorFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            label: 'Nom complet',
            hint: 'Dr. Votre nom',
            controller: _nameController,
            prefixIcon: Icons.person_outline,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Nom requis';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Email',
            hint: 'votre@email.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            prefixIcon: Icons.email_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Email requis';
              if (!value.contains('@')) return 'Email invalide';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          PasswordField(
            label: 'Mot de passe',
            hint: '••••••••',
            controller: _passwordController,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Mot de passe requis';
              if (value.length < 6) return 'Minimum 6 caractères';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          PasswordField(
            label: 'Confirmer le mot de passe',
            hint: '••••••••',
            controller: _confirmPasswordController,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleDoctorRegister(),
            validator: (value) {
              if (value != _passwordController.text) {
                return 'Les mots de passe ne correspondent pas';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: "S'inscrire",
            isLoading: authState.isLoading,
            onPressed: _handleDoctorRegister,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AuthHeader(
                title: 'Créer un compte',
                subtitle: 'Rejoignez Eyadati',
              ),
              const SizedBox(height: AppSpacing.lg),
              _RoleToggle(
                isDoctor: _isDoctor,
                onChanged: (value) => setState(() => _isDoctor = value),
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _isDoctor
                    ? _buildDoctorForm(authState)
                    : _buildPatientForm(authState),
              ),
              const SizedBox(height: AppSpacing.lg),
              AuthFooter(
                text: 'Vous avez déjà un compte ? ',
                actionText: 'Se connecter',
                onAction: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleToggle extends StatelessWidget {
  final bool isDoctor;
  final ValueChanged<bool> onChanged;

  const _RoleToggle({required this.isDoctor, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !isDoctor ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Patient',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: !isDoctor
                        ? AppColors.white
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isDoctor ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Docteur',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDoctor ? AppColors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
