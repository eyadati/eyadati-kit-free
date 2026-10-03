import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/utils/supabase_client.dart';
import '../../repositories/repositories.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return SupabaseInitializer.client;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthRepository(client);
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ProfileRepository(client);
});

final doctorRepositoryProvider = Provider<DoctorRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return DoctorRepository(client);
});

final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AppointmentRepository(client);
});

final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return FavoriteRepository(client);
});

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ScheduleRepository(client);
});

final currentProfileDataProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final userId = client.auth.currentUser?.id;
  if (userId == null) return null;
  
  final response = await client
      .from('profiles')
      .select()
      .eq('id', userId)
      .maybeSingle();
  return response;
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange.map((event) => AuthState(
    userId: event.session?.user.id,
    email: event.session?.user.email,
    isAuthenticated: event.session != null,
  ));
});

class AuthState {
  final String? userId;
  final String? email;
  final bool isAuthenticated;

  AuthState({this.userId, this.email, this.isAuthenticated = false});
}