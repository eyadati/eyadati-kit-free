import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/buttons/secondary_button.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../core/widgets/inputs/password_field.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/utils/input_validator.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _patientFormKey = GlobalKey<FormState>();
  final _emailFormKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isDoctor = false;
  bool _emailSent = false;
  bool _resetSuccess = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handlePatientReset() async {
    if (!_patientFormKey.currentState!.validate()) return;

    final phone = InputValidator.formatPhoneForE164(
      _phoneController.text.trim(),
    );

    final success = await ref
        .read(authProvider.notifier)
        .patientPasswordReset(
          phone: phone,
          newPassword: _newPasswordController.text,
        );
    if (!mounted) return;

    if (success) {
      setState(() => _resetSuccess = true);
    } else {
      final error = ref.read(authProvider).errorMessage;
      AppSnackbar.showError(
        context,
        message: error ?? 'Erreur lors de la réinitialisation',
      );
    }
  }

  Future<void> _handleEmailReset() async {
    if (!_emailFormKey.currentState!.validate()) return;

    final success = await ref
        .read(authProvider.notifier)
        .resetPassword(_emailController.text.trim());
    if (!mounted) return;

    if (success) {
      setState(() => _emailSent = true);
    } else {
      final error = ref.read(authProvider).errorMessage;
      AppSnackbar.showError(context, message: error ?? 'Erreur');
    }
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
              const SizedBox(height: AppSpacing.xl),
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
                    ? _buildDoctorContent(authState)
                    : _buildPatientContent(authState),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorContent(AppAuthState authState) {
    if (_emailSent) {
      return _buildEmailSentView();
    }
    return _buildEmailForm(authState);
  }

  Widget _buildPatientContent(AppAuthState authState) {
    if (_resetSuccess) {
      return _buildSuccessView();
    }
    return _buildPatientForm(authState);
  }

  Widget _buildPatientForm(AppAuthState authState) {
    return Form(
      key: _patientFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mot de passe oublié',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Entrez votre numéro de téléphone et votre nouveau mot de passe.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
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
            label: 'Nouveau mot de passe',
            hint: '••••••••',
            controller: _newPasswordController,
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
            onSubmitted: (_) => _handlePatientReset(),
            validator: (value) {
              if (value != _newPasswordController.text) {
                return 'Les mots de passe ne correspondent pas';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Réinitialiser',
            isLoading: authState.isLoading,
            onPressed: _handlePatientReset,
          ),
        ],
      ),
    );
  }

  Widget _buildEmailForm(AppAuthState authState) {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mot de passe oublié',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Entrez votre email pour recevoir un lien de réinitialisation.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Email',
            hint: 'votre@email.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Email requis';
              if (!value.contains('@')) return 'Email invalide';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Réinitialiser',
            isLoading: authState.isLoading,
            onPressed: _handleEmailReset,
          ),
        ],
      ),
    );
  }

  Widget _buildEmailSentView() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, size: 48, color: AppColors.success),
        ),
        const SizedBox(height: AppSpacing.lg),
        const Text(
          'Email envoyé',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          'Vérifiez votre boîte de réception et cliquez sur le lien pour réinitialiser votre mot de passe.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),
        SecondaryButton(
          label: 'Retour à la connexion',
          onPressed: () => context.go(RouteNames.login),
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, size: 48, color: AppColors.success),
        ),
        const SizedBox(height: AppSpacing.lg),
        const Text(
          'Mot de passe réinitialisé',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          'Votre mot de passe a été modifié avec succès.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),
        SecondaryButton(
          label: 'Retour à la connexion',
          onPressed: () => context.go(RouteNames.login),
        ),
      ],
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
