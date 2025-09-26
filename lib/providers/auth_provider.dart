import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/auth_state.dart';
import '../services/auth_service.dart';

/// Authentication Provider
/// Manages authentication state using Provider pattern
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthState _state = AuthState.initial;
  UserModel? _user;

  // Getters
  AuthState get state => _state;
  UserModel? get user => _user;
  bool get isAuthenticated => _state.isAuthenticated;
  bool get isLoading => _state.isLoading;
  String? get error => _state.error;

  AuthProvider() {
    _initializeAuth();
  }

  /// Initialize authentication state
  Future<void> _initializeAuth() async {
    _setState(_state.copyWith(isLoading: true));

    try {
      // Listen to auth state changes
      _authService.authStateChanges.listen((User? firebaseUser) {
        if (firebaseUser != null) {
          _user = UserModel.fromFirebaseUser(firebaseUser);
          _setState(AuthState().authenticated(_user!));
        } else {
          _user = null;
          _setState(AuthState.unauthenticated);
        }
      });
    } catch (e) {
      _setState(
        AuthState().errorState('Failed to initialize authentication: $e'),
      );
    }
  }

  /// Sign in with email and password
  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _setState(_state.copyWith(isLoading: true, error: null));

    try {
      final user = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (user != null) {
        _user = user;
        _setState(AuthState().authenticated(user));
        return true;
      } else {
        _setState(AuthState().errorState('Sign in failed'));
        return false;
      }
    } catch (e) {
      _setState(AuthState().errorState(e.toString()));
      return false;
    }
  }

  /// Sign up with email and password
  Future<bool> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _setState(_state.copyWith(isLoading: true, error: null));

    try {
      final user = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );

      if (user != null) {
        _user = user;
        _setState(AuthState().authenticated(user));
        return true;
      } else {
        _setState(AuthState().errorState('Sign up failed'));
        return false;
      }
    } catch (e) {
      _setState(AuthState().errorState(e.toString()));
      return false;
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    _setState(_state.copyWith(isLoading: true, error: null));

    try {
      final user = await _authService.signInWithGoogle();

      if (user != null) {
        _user = user;
        _setState(AuthState().authenticated(user));
        return true;
      } else {
        _setState(AuthState().errorState('Google sign in cancelled'));
        return false;
      }
    } catch (e) {
      _setState(AuthState().errorState(e.toString()));
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _setState(_state.copyWith(isLoading: true, error: null));

    try {
      await _authService.signOut();
      _user = null;
      _setState(AuthState.unauthenticated);
    } catch (e) {
      _setState(AuthState().errorState(e.toString()));
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    _setState(_state.copyWith(isLoading: true, error: null));

    try {
      await _authService.sendPasswordResetEmail(email);
      _setState(_state.copyWith(isLoading: false));
      return true;
    } catch (e) {
      _setState(AuthState().errorState(e.toString()));
      return false;
    }
  }

  /// Send email verification
  Future<bool> sendEmailVerification() async {
    _setState(_state.copyWith(isLoading: true, error: null));

    try {
      await _authService.sendEmailVerification();
      _setState(_state.copyWith(isLoading: false));
      return true;
    } catch (e) {
      _setState(AuthState().errorState(e.toString()));
      return false;
    }
  }

  /// Update user profile
  Future<bool> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    _setState(_state.copyWith(isLoading: true, error: null));

    try {
      await _authService.updateUserProfile(
        displayName: displayName,
        photoURL: photoURL,
      );

      // Refresh user data
      _user = _authService.getCurrentUserModel();
      if (_user != null) {
        _setState(AuthState().authenticated(_user!));
      }
      return true;
    } catch (e) {
      _setState(AuthState().errorState(e.toString()));
      return false;
    }
  }

  /// Update password
  Future<bool> updatePassword(String newPassword) async {
    _setState(_state.copyWith(isLoading: true, error: null));

    try {
      await _authService.updatePassword(newPassword);
      _setState(_state.copyWith(isLoading: false));
      return true;
    } catch (e) {
      _setState(AuthState().errorState(e.toString()));
      return false;
    }
  }

  /// Delete account
  Future<bool> deleteAccount() async {
    _setState(_state.copyWith(isLoading: true, error: null));

    try {
      await _authService.deleteAccount();
      _user = null;
      _setState(AuthState.unauthenticated);
      return true;
    } catch (e) {
      _setState(AuthState().errorState(e.toString()));
      return false;
    }
  }

  /// Clear error
  void clearError() {
    _setState(_state.clearError());
  }

  /// Set loading state
  void setLoading(bool loading) {
    _setState(_state.setLoading(loading));
  }

  /// Update state and notify listeners
  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }
}
