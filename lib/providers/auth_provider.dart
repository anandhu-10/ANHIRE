import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';

// Abstract contract provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

enum AuthStatus { unauthenticated, authenticated, authenticating, error }

class AuthState {
  final AuthStatus status;
  final String? uid;
  final String? email;
  final String role; // student | admin
  final String? errorMessage;

  AuthState({
    required this.status,
    this.uid,
    this.email,
    this.role = "student",
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? uid,
    String? email,
    String? role,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      uid: uid ?? this.uid,
      email: email ?? this.email,
      role: role ?? this.role,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository)
      : super(AuthState(status: AuthStatus.unauthenticated)) {
    _autoLogin();
  }

  void _autoLogin() async {
    final uid = _authRepository.getCurrentUserUid();
    final email = _authRepository.getCurrentUserEmail();
    if (uid != null && email != null) {
      final role = await _authRepository.getUserRole(uid);
      state = AuthState(
        status: AuthStatus.authenticated,
        uid: uid,
        email: email,
        role: role,
      );
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.authenticating);
    try {
      await _authRepository.signIn(email, password);
      final uid = _authRepository.getCurrentUserUid()!;
      final role = await _authRepository.getUserRole(uid);
      
      state = AuthState(
        status: AuthStatus.authenticated,
        uid: uid,
        email: email,
        role: role,
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceAll("Exception: ", ""),
      );
    }
  }

  Future<void> signUp(String email, String password) async {
    state = state.copyWith(status: AuthStatus.authenticating);
    try {
      await _authRepository.signUp(email, password);
      final uid = _authRepository.getCurrentUserUid()!;
      
      state = AuthState(
        status: AuthStatus.authenticated,
        uid: uid,
        email: email,
        role: "student",
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceAll("Exception: ", ""),
      );
    }
  }

  Future<void> loginWithGoogle() async {
    state = state.copyWith(status: AuthStatus.authenticating);
    try {
      await _authRepository.signInWithGoogle();
      final uid = _authRepository.getCurrentUserUid()!;
      final email = _authRepository.getCurrentUserEmail()!;
      final role = await _authRepository.getUserRole(uid);

      state = AuthState(
        status: AuthStatus.authenticated,
        uid: uid,
        email: email,
        role: role,
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceAll("Exception: ", ""),
      );
    }
  }

  Future<void> logout() async {
    await _authRepository.signOut();
    state = AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> resetPassword(String email) async {
    try {
      await _authRepository.sendPasswordReset(email);
    } catch (e) {
      throw Exception("Failed to send password reset: $e");
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});
