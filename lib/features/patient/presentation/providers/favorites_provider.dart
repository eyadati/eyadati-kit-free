import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eyadati_kit/core/utils/supabase_client.dart';
import 'package:eyadati_kit/features/auth/presentation/providers/auth_provider.dart';

class FavoritesState {
  final List<String> favoriteDoctorIds;
  final bool isLoading;
  final String? errorMessage;

  const FavoritesState({
    this.favoriteDoctorIds = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  FavoritesState copyWith({
    List<String>? favoriteDoctorIds,
    bool? isLoading,
    String? errorMessage,
  }) {
    return FavoritesState(
      favoriteDoctorIds: favoriteDoctorIds ?? this.favoriteDoctorIds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
  return FavoritesNotifier(ref);
});

class FavoritesNotifier extends StateNotifier<FavoritesState> {
  final Ref _ref;

  FavoritesNotifier(this._ref) : super(const FavoritesState());

  Future<void> loadFavorites() async {
    state = state.copyWith(isLoading: true);
    try {
      final authState = _ref.read(authProvider);
      final userId = authState.userId;
      if (userId == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final result = await SupabaseInitializer.client
          .from('favorites')
          .select('doctor_id')
          .eq('patient_id', userId);

      final ids = (result as List).map((row) => row['doctor_id'] as String).toList();
      state = state.copyWith(
        isLoading: false,
        favoriteDoctorIds: ids,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  bool isFavorite(String doctorId) {
    return state.favoriteDoctorIds.contains(doctorId);
  }

  Future<void> toggleFavorite(String doctorId, {BuildContext? context}) async {
    final userId = _ref.read(authProvider).userId;
    if (userId == null) return;

    final wasFavorite = isFavorite(doctorId);

    // Optimistic update
    if (wasFavorite) {
      state = state.copyWith(
        favoriteDoctorIds: state.favoriteDoctorIds.where((id) => id != doctorId).toList(),
      );
    } else {
      state = state.copyWith(
        favoriteDoctorIds: [...state.favoriteDoctorIds, doctorId],
      );
    }

    try {
      if (wasFavorite) {
        await SupabaseInitializer.client
            .from('favorites')
            .delete()
            .eq('patient_id', userId)
            .eq('doctor_id', doctorId);
      } else {
        await SupabaseInitializer.client
            .from('favorites')
            .insert({'patient_id': userId, 'doctor_id': doctorId});
      }
    } catch (e) {
      // Rollback on failure
      if (wasFavorite) {
        state = state.copyWith(
          favoriteDoctorIds: [...state.favoriteDoctorIds, doctorId],
          errorMessage: e.toString(),
        );
      } else {
        state = state.copyWith(
          favoriteDoctorIds: state.favoriteDoctorIds.where((id) => id != doctorId).toList(),
          errorMessage: e.toString(),
        );
      }
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la mise à jour des favoris')),
        );
      }
    }
  }

  Future<void> refresh() async {
    await loadFavorites();
  }
}
