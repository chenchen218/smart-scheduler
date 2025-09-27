import '../models/user_model.dart';

/// Mock Authentication Service
/// For testing authentication flow without Firebase setup
class MockAuthService {
  static final MockAuthService _instance = MockAuthService._internal();
  factory MockAuthService() => _instance;
  MockAuthService._internal();

  UserModel? _currentUser;
  bool _isSignedIn = false;

  UserModel? get currentUser => _currentUser;
  bool get isSignedIn => _isSignedIn;

  /// Sign in with email and password (mock)
  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock validation
    if (email == 'test@example.com' && password == 'password123') {
      _currentUser = UserModel(
        uid: 'mock-user-123',
        email: email,
        displayName: 'Test User',
        isEmailVerified: true,
        createdAt: DateTime.now(),
        lastSignIn: DateTime.now(),
      );
      _isSignedIn = true;
      return _currentUser;
    } else {
      throw 'Invalid email or password';
    }
  }

  /// Sign up with email and password (mock)
  Future<UserModel?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock validation
    if (email.isNotEmpty && password.length >= 6) {
      _currentUser = UserModel(
        uid: 'mock-user-${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: displayName ?? 'New User',
        isEmailVerified: false,
        createdAt: DateTime.now(),
        lastSignIn: DateTime.now(),
      );
      _isSignedIn = true;
      return _currentUser;
    } else {
      throw 'Invalid email or password';
    }
  }

  /// Sign in with Google (mock)
  Future<UserModel?> signInWithGoogle() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    _currentUser = UserModel(
      uid: 'mock-google-user-123',
      email: 'user@gmail.com',
      displayName: 'Google User',
      photoURL: 'https://via.placeholder.com/150',
      isEmailVerified: true,
      createdAt: DateTime.now(),
      lastSignIn: DateTime.now(),
    );
    _isSignedIn = true;
    return _currentUser;
  }

  /// Sign out (mock)
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
    _isSignedIn = false;
  }

  /// Send password reset email (mock)
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    // Mock success
  }

  /// Send email verification (mock)
  Future<void> sendEmailVerification() async {
    await Future.delayed(const Duration(seconds: 1));
    // Mock success
  }

  /// Update user profile (mock)
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        displayName: displayName ?? _currentUser!.displayName,
        photoURL: photoURL ?? _currentUser!.photoURL,
      );
    }
  }

  /// Update password (mock)
  Future<void> updatePassword(String newPassword) async {
    await Future.delayed(const Duration(seconds: 1));
    // Mock success
  }

  /// Delete account (mock)
  Future<void> deleteAccount() async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = null;
    _isSignedIn = false;
  }

  /// Get current user model
  UserModel? getCurrentUserModel() {
    return _currentUser;
  }
}
