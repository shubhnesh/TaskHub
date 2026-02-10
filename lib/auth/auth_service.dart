import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

// Auth state class
class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final User? user;

  AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.user,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    User? user,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      user: user ?? this.user,
    );
  }
}

// Auth StateNotifier
class AuthNotifier extends StateNotifier<AuthState> {
  final SupabaseService _service;

  AuthNotifier(this._service) : super(AuthState(user: _service.currentUser));

  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _service.signIn(email, password);
      state = state.copyWith(
        isLoading: false,
        user: _service.currentUser,
      );
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An unexpected error occurred',
      );
    }
    return false;
  }

  Future<bool> signUp(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _service.signUp(email, password);
      state = state.copyWith(isLoading: false);
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An unexpected error occurred',
      );
    }
    return false;
  }

  Future<void> signOut() async {
    await _service.signOut();
    state = AuthState();
  }
}

// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final service = ref.watch(supabaseServiceProvider);
  return AuthNotifier(service);
});

// Provider for SupabaseService (shared with tasks)
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});
