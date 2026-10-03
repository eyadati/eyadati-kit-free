import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:functions_client/functions_client.dart';
import '../core/utils/input_validator.dart';
import '../core/utils/security_validator.dart';

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  Stream<User?> get authStateChanges => _client.auth.onAuthStateChange.map(
        (event) => event.session?.user,
      );

  User? get currentUser => _client.auth.currentUser;

  bool get isAuthenticated => currentUser != null;

  // ── Phone + Password login ──

  Future<AuthResult> signInWithPhone({
    required String phone,
    required String password,
  }) async {
    final phoneError = InputValidator.validateAlgerianPhone(phone);
    if (phoneError != null) {
      return AuthResult.failure(phoneError);
    }

    final passwordError = InputValidator.validatePassword(password);
    if (passwordError != null) {
      return AuthResult.failure(passwordError);
    }

    try {
      final formattedPhone = InputValidator.formatPhoneForE164(phone);
      final response = await _client.auth.signInWithPassword(
        phone: formattedPhone,
        password: password,
      );

      if (response.user == null) {
        return AuthResult.failure('Numéro ou mot de passe incorrect');
      }

      return AuthResult.success(response.user!);
    } on AuthException catch (e) {
      return AuthResult.failure(_mapAuthError(e.message));
    } catch (e) {
      return AuthResult.failure('Erreur de connexion. Réessayez.');
    }
  }

  // ── Legacy email login (kept during transition) ──

  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    final emailError = InputValidator.validateEmail(email);
    if (emailError != null) {
      return AuthResult.failure(emailError);
    }

    final passwordError = InputValidator.validatePassword(password);
    if (passwordError != null) {
      return AuthResult.failure(passwordError);
    }

    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      if (response.user == null) {
        return AuthResult.failure('Invalid email or password');
      }

      return AuthResult.success(response.user!);
    } on AuthException catch (e) {
      return AuthResult.failure(_mapAuthError(e.message));
    } catch (e) {
      return AuthResult.failure('Connection error. Please try again.');
    }
  }

  // ── Legacy email signup (kept during transition) ──

  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? phone,
  }) async {
    final emailError = InputValidator.validateEmail(email);
    if (emailError != null) {
      return AuthResult.failure(emailError);
    }

    final passwordError = InputValidator.validatePassword(password);
    if (passwordError != null) {
      return AuthResult.failure(passwordError);
    }

    final nameError = InputValidator.validateFullName(fullName);
    if (nameError != null) {
      return AuthResult.failure(nameError);
    }

    if (role != 'patient' && role != 'doctor') {
      return AuthResult.failure('Invalid role. Must be patient or doctor.');
    }

    try {
      final sanitizedName = SecurityValidator.sanitizeHtml(fullName.trim());

      final metadata = <String, dynamic>{
        'full_name': sanitizedName,
        'role': role,
      };
      if (phone != null && phone.trim().isNotEmpty) {
        metadata['phone'] = phone.trim();
      }

      final response = await _client.auth.signUp(
        email: email.trim().toLowerCase(),
        password: password,
        data: metadata,
      );

      if (response.user == null) {
        return AuthResult.failure('Registration failed. Please try again.');
      }

      return AuthResult.success(response.user!);
    } on AuthException catch (e) {
      return AuthResult.failure(_mapAuthError(e.message));
    } catch (e) {
      return AuthResult.failure('Connection error. Please try again.');
    }
  }

  // ── Direct phone + password signup (no OTP) ──

  Future<AuthResult> signUpWithPhoneDirect({
    required String phone,
    required String password,
    required String fullName,
    required String role,
  }) async {
    final phoneError = InputValidator.validateAlgerianPhone(phone);
    if (phoneError != null) {
      return AuthResult.failure(phoneError);
    }

    final passwordError = InputValidator.validatePassword(password);
    if (passwordError != null) {
      return AuthResult.failure(passwordError);
    }

    final nameError = InputValidator.validateFullName(fullName);
    if (nameError != null) {
      return AuthResult.failure(nameError);
    }

    try {
      final sanitizedName = SecurityValidator.sanitizeHtml(fullName.trim());
      final formattedPhone = InputValidator.formatPhoneForE164(phone);

      final response = await _client.auth.signUp(
        phone: formattedPhone,
        password: password,
        data: {
          'full_name': sanitizedName,
          'role': role,
          'phone': formattedPhone,
        },
      );

      if (response.user == null) {
        return AuthResult.failure("Erreur lors de l'inscription");
      }

      await _client.from('profiles').upsert({
        'id': response.user!.id,
        'full_name': sanitizedName,
        'role': role,
        'phone': formattedPhone,
      });

      return AuthResult.success(response.user!);
    } on AuthException catch (e) {
      return AuthResult.failure(_mapAuthError(e.message));
    } catch (e) {
      return AuthResult.failure('Erreur de connexion. Réessayez.');
    }
  }

  // ── Reset password by phone (via edge function) ──

  Future<AuthResult> resetPasswordByPhone({
    required String phone,
    required String newPassword,
  }) async {
    try {
      final formattedPhone = InputValidator.formatPhoneForE164(phone);
      final response = await _client.functions.invoke(
        'patient-reset-password',
        body: {'phone': formattedPhone, 'new_password': newPassword},
      );
      if (response.status >= 200 && response.status < 300) {
        return AuthResult.success(null);
      }
      final body = response.data as Map<String, dynamic>?;
      return AuthResult.failure(
        (body?['error'] as String?) ?? 'Erreur lors de la réinitialisation',
      );
    } on FunctionException catch (e) {
      return AuthResult.failure(
        e.details?.toString() ?? 'Erreur lors de la réinitialisation',
      );
    } catch (e) {
      return AuthResult.failure('Erreur de connexion. Réessayez.');
    }
  }

  // ── Phone OTP ──

  Future<AuthResult> sendOtp(String phone) async {
    final phoneError = InputValidator.validateAlgerianPhone(phone);
    if (phoneError != null) {
      return AuthResult.failure(phoneError);
    }

    try {
      final formattedPhone = InputValidator.formatPhoneForE164(phone);
      await _client.auth.signInWithOtp(phone: formattedPhone);
      return AuthResult.success(null);
    } on AuthException catch (e) {
      return AuthResult.failure(_mapAuthError(e.message));
    } catch (e) {
      return AuthResult.failure('Erreur d\'envoi du code. Réessayez.');
    }
  }

  Future<AuthResult> verifyOtp({
    required String phone,
    required String token,
  }) async {
    try {
      final formattedPhone = InputValidator.formatPhoneForE164(phone);
      final response = await _client.auth.verifyOTP(
        phone: formattedPhone,
        token: token,
        type: OtpType.sms,
      );

      if (response.user == null) {
        return AuthResult.failure('Code invalide ou expiré');
      }

      return AuthResult.success(response.user!);
    } on AuthException catch (e) {
      return AuthResult.failure(_mapAuthError(e.message));
    } catch (e) {
      return AuthResult.failure('Erreur de vérification. Réessayez.');
    }
  }

  // ── Post-verification setup ──

  Future<AuthResult> setPassword(String password) async {
    final passwordError = InputValidator.validatePassword(password);
    if (passwordError != null) {
      return AuthResult.failure(passwordError);
    }

    try {
      await _client.auth.updateUser(UserAttributes(password: password));
      return AuthResult.success(null);
    } on AuthException catch (e) {
      return AuthResult.failure(_mapAuthError(e.message));
    } catch (e) {
      return AuthResult.failure('Erreur. Réessayez.');
    }
  }

  Future<AuthResult> setProfileData({
    required String name,
    required String role,
    required String phone,
  }) async {
    try {
      final sanitizedName = SecurityValidator.sanitizeHtml(name.trim());
      final formattedPhone = InputValidator.formatPhoneForE164(phone);

      await _client.auth.updateUser(UserAttributes(
        data: {
          'full_name': sanitizedName,
          'role': role,
          'phone': formattedPhone,
        },
      ));

      final user = _client.auth.currentUser;
      if (user == null) {
        return AuthResult.failure('Utilisateur non trouvé');
      }

      await _client.from('profiles').upsert({
        'id': user.id,
        'full_name': sanitizedName,
        'role': role,
        'phone': formattedPhone,
      });

      return AuthResult.success(user);
    } on AuthException catch (e) {
      return AuthResult.failure(_mapAuthError(e.message));
    } catch (e) {
      return AuthResult.failure('Erreur. Réessayez.');
    }
  }

  Future<AuthResult> deleteAccount() async {
    try {
      final response = await _client.functions.invoke('delete-account');
      if (response.status >= 200 && response.status < 300) {
        return AuthResult.success(null);
      }
      return AuthResult.failure('Erreur lors de la suppression');
    } on FunctionException catch (e) {
      return AuthResult.failure(
        e.details?.toString() ?? 'Erreur lors de la suppression',
      );
    } catch (e) {
      return AuthResult.failure('Erreur de connexion. Réessayez.');
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<AuthResult> resetPassword(String email) async {
    final emailError = InputValidator.validateEmail(email);
    if (emailError != null) {
      return AuthResult.failure(emailError);
    }

    try {
      await _client.auth.resetPasswordForEmail(email.trim().toLowerCase());
      return AuthResult.success(null);
    } on AuthException catch (e) {
      return AuthResult.failure(_mapAuthError(e.message));
    } catch (e) {
      return AuthResult.failure('Connection error. Please try again.');
    }
  }

  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
    String? phone,
  }) async {
    final passwordError = InputValidator.validatePassword(newPassword);
    if (passwordError != null) {
      return AuthResult.failure(passwordError);
    }

    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return AuthResult.failure('Not authenticated');
      }

      if (phone != null) {
        final formattedPhone = InputValidator.formatPhoneForE164(phone);
        final reauth = await _client.auth.signInWithPassword(
          phone: formattedPhone,
          password: currentPassword,
        );
        if (reauth.user == null) {
          return AuthResult.failure('Current password is incorrect');
        }
      } else if (user.email != null) {
        final reauth = await _client.auth.signInWithPassword(
          email: user.email!,
          password: currentPassword,
        );
        if (reauth.user == null) {
          return AuthResult.failure('Current password is incorrect');
        }
      } else {
        return AuthResult.failure('Cannot re-authenticate');
      }

      await _client.auth.updateUser(UserAttributes(password: newPassword));
      return AuthResult.success(null);
    } on AuthException catch (e) {
      return AuthResult.failure(_mapAuthError(e.message));
    } catch (e) {
      return AuthResult.failure('Connection error. Please try again.');
    }
  }

  String _mapAuthError(String message) {
    final lowerMessage = message.toLowerCase();
    if (lowerMessage.contains('invalid login credentials')) {
      return 'Numéro ou mot de passe incorrect';
    } else if (lowerMessage.contains('already registered')) {
      return 'Ce numéro est déjà inscrit';
    } else if (lowerMessage.contains('password')) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    } else if (lowerMessage.contains('phone') || lowerMessage.contains('sms')) {
      return 'Numéro de téléphone invalide';
    } else if (lowerMessage.contains('email')) {
      return 'Veuillez entrer un email valide';
    } else if (lowerMessage.contains('rate limit') || lowerMessage.contains('too many')) {
      return 'Trop de tentatives. Réessayez dans quelques minutes.';
    }
    return message;
  }
}

class AuthResult {
  final bool isSuccess;
  final User? user;
  final String? error;

  AuthResult._({
    required this.isSuccess,
    this.user,
    this.error,
  });

  factory AuthResult.success(User? user) {
    return AuthResult._(isSuccess: true, user: user);
  }

  factory AuthResult.failure(String error) {
    return AuthResult._(isSuccess: false, error: error);
  }
}
