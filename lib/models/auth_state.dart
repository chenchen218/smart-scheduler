import 'user_model.dart';

/// Authentication State
/// Represents the current authentication state of the user
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserModel? user;
  final String? error;
  final bool isInitialized;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
    this.isInitialized = false,
  });

  /// Initial state
  static const AuthState initial = AuthState();

  /// Loading state
  static const AuthState loading = AuthState(isLoading: true);

  /// Authenticated state
  AuthState authenticated(UserModel user) {
    return AuthState(isAuthenticated: true, user: user, isInitialized: true);
  }

  /// Unauthenticated state
  static const AuthState unauthenticated = AuthState(
    isAuthenticated: false,
    isInitialized: true,
  );

  /// Error state
  AuthState errorState(String error) {
    return AuthState(error: error, isInitialized: true);
  }

  /// Create a copy with updated fields
  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    UserModel? user,
    String? error,
    bool? isInitialized,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error ?? this.error,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  /// Clear error
  AuthState clearError() {
    return copyWith(error: null);
  }

  /// Set loading
  AuthState setLoading(bool loading) {
    return copyWith(isLoading: loading);
  }

  @override
  String toString() {
    return 'AuthState(isLoading: $isLoading, isAuthenticated: $isAuthenticated, user: $user, error: $error, isInitialized: $isInitialized)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.isLoading == isLoading &&
        other.isAuthenticated == isAuthenticated &&
        other.user == user &&
        other.error == error &&
        other.isInitialized == isInitialized;
  }

  @override
  int get hashCode {
    return isLoading.hashCode ^
        isAuthenticated.hashCode ^
        user.hashCode ^
        error.hashCode ^
        isInitialized.hashCode;
  }
}
