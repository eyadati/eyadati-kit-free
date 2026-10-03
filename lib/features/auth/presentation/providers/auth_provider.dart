import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_state.dart';
import '../../../../core/utils/supabase_client.dart';
import '../../../../repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(SupabaseInitializer.client);
});

final authProvider = StateNotifierProvider<AuthNotifier, AppAuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

class AuthNotifier extends StateNotifier<AppAuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AppAuthState());

  // ── Phone + Password login ──

  Future<bool> loginWithPhone(String phone, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await _repository.signInWithPhone(
        phone: phone,
        password: password,
      );
      if (result.isSuccess) {
        final user = result.user!;
        final role = await _fetchRoleFromProfile(user.id);
        final userName = await _fetchUserName(user.id);
        final setupCompleted = role == 'patient'
            ? true
            : await _checkDoctorSetup(user.id);
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          isInitialized: true,
          setupCompleted: setupCompleted,
          userId: user.id,
          phone: phone,
          role: role,
          isDoctor: role == 'doctor',
          userName: userName,
        );
        return true;
      }
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        errorMessage: result.error ?? 'Numéro ou mot de passe incorrect',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  // ── Legacy email login ──

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await _repository.signIn(
          email: email, password: password);
      if (result.isSuccess) {
        final user = result.user!;
        final role = await _fetchRoleFromProfile(user.id);
        final userName = await _fetchUserName(user.id);
        final setupCompleted = role == 'patient'
            ? true
            : await _checkDoctorSetup(user.id);
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          isInitialized: true,
          setupCompleted: setupCompleted,
          userId: user.id,
          email: email,
          role: role,
          isDoctor: role == 'doctor',
          userName: userName,
        );
        return true;
      }
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        errorMessage: result.error ?? 'Identifiants incorrects',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  // ── Direct phone registration (no OTP) ──

  Future<bool> directPhoneRegister({
    required String name,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final phone = state.phone;
      if (phone == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Numéro de téléphone manquant',
        );
        return false;
      }

      final result = await _repository.signUpWithPhoneDirect(
        phone: phone,
        password: password,
        fullName: name,
        role: 'patient',
      );

      if (!result.isSuccess) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result.error ?? "Erreur lors de l'inscription",
        );
        return false;
      }

      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        isInitialized: true,
        setupCompleted: true,
        userId: result.user?.id,
        phone: phone,
        role: 'patient',
        isDoctor: false,
        userName: name,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  // ── Legacy email registration ──

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await _repository.signUp(
        email: email,
        password: password,
        fullName: name,
        role: role,
        phone: phone,
      );
      if (result.isSuccess) {
        final setupCompleted = role == 'patient' ? true : false;
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          isInitialized: true,
          setupCompleted: setupCompleted,
          userId: result.user?.id,
          email: email,
          role: role,
          isDoctor: role == 'doctor',
          userName: name,
        );
        return true;
      }
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        errorMessage: result.error ?? "Erreur lors de l'inscription",
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  // ── Forgot password: patient (phone via edge fn) ──

  Future<bool> patientPasswordReset({
    required String phone,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await _repository.resetPasswordByPhone(
        phone: phone,
        newPassword: newPassword,
      );
      state = state.copyWith(isLoading: false);
      if (!result.isSuccess) {
        state = state.copyWith(errorMessage: result.error);
      }
      return result.isSuccess;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<String?> deleteAccount() async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await _repository.deleteAccount();
      if (result.isSuccess) {
        await _repository.signOut();
        state = const AppAuthState(isInitialized: true);
        return null;
      }
      state = state.copyWith(isLoading: false);
      return result.error;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return e.toString();
    }
  }

  Future<void> logout() async {
    await _repository.signOut();
    state = const AppAuthState(isInitialized: true);
  }

  void resetState() {
    state = const AppAuthState(isInitialized: true);
  }

  void setPhone(String phone) {
    state = state.copyWith(phone: phone);
  }

  Future<bool> _checkDoctorSetup(String userId) async {
    try {
      final doctor = await SupabaseInitializer.client
          .from('doctors')
          .select('id')
          .eq('id', userId)
          .maybeSingle();
      return doctor != null;
    } catch (e) {
      return false;
    }
  }

  Future<String> _fetchRoleFromProfile(String userId) async {
    try {
      final profile = await SupabaseInitializer.client
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .maybeSingle();
      if (profile != null && profile['role'] != null) {
        return profile['role'] as String;
      }
      return 'patient';
    } catch (e) {
      return 'patient';
    }
  }

  Future<String?> _fetchUserName(String userId) async {
    try {
      final profile = await SupabaseInitializer.client
          .from('profiles')
          .select('full_name')
          .eq('id', userId)
          .maybeSingle();
      return profile?['full_name'] as String?;
    } catch (e) {
      return null;
    }
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = _repository.currentUser;
      if (user != null) {
        final role = await _fetchRoleFromProfile(user.id);
        final userName = await _fetchUserName(user.id);
        final setupCompleted = role == 'patient'
            ? true
            : await _checkDoctorSetup(user.id);
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          isInitialized: true,
          setupCompleted: setupCompleted,
          userId: user.id,
          email: user.email,
          role: role,
          isDoctor: role == 'doctor',
          userName: userName,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isInitialized: true,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
      );
    }
  }

  Future<void> refreshSetupStatus() async {
    final userId = state.userId;
    if (userId == null || !state.isDoctor) return;

    final setupCompleted = await _checkDoctorSetup(userId);
    state = state.copyWith(setupCompleted: setupCompleted);
  }

  void clearError() {
    state = AppAuthState(
      isAuthenticated: state.isAuthenticated,
      isDoctor: state.isDoctor,
      isLoading: state.isLoading,
      userId: state.userId,
      email: state.email,
      phone: state.phone,
      role: state.role,
      setupCompleted: state.setupCompleted,
      userName: state.userName,
    );
  }

  Future<bool> resetPassword(String email) async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await _repository.resetPassword(email);
      state = state.copyWith(isLoading: false);
      if (!result.isSuccess) {
        state = AppAuthState(
          isAuthenticated: state.isAuthenticated,
          isDoctor: state.isDoctor,
          isLoading: state.isLoading,
          errorMessage: result.error,
          userId: state.userId,
          email: state.email,
          role: state.role,
          setupCompleted: state.setupCompleted,
          userName: state.userName,
        );
      }
      return result.isSuccess;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}
