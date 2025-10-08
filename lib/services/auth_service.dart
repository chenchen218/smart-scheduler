import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../config/auth_config.dart';
import 'mock_auth_service.dart';

/// Authentication Service
/// Handles all authentication operations with Firebase
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn? _googleSignIn;
  final MockAuthService _mockAuth = MockAuthService();

  /// Get GoogleSignIn instance (lazy initialization)
  GoogleSignIn get _googleSignInInstance {
    if (_googleSignIn == null) {
      _googleSignIn = GoogleSignIn(
        clientId:
            '796545909849-d14htdi0bdehcljan5usm5lf4f7o4ah9.apps.googleusercontent.com',
      );
    }
    return _googleSignIn!;
  }

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (AuthConfig.useMockAuth) {
      return await _mockAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    }

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        return UserModel.fromFirebaseUser(credential.user!);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }

  /// Sign up with email and password
  Future<UserModel?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    if (AuthConfig.useMockAuth) {
      return await _mockAuth.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
    }

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Update display name if provided
        if (displayName != null && displayName.isNotEmpty) {
          await credential.user!.updateDisplayName(displayName);
        }

        // Send email verification
        await credential.user!.sendEmailVerification();

        return UserModel.fromFirebaseUser(credential.user!);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }

  /// Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    if (AuthConfig.useMockAuth) {
      return await _mockAuth.signInWithGoogle();
    }

    try {
      // Use signInSilently first to check if user is already signed in
      GoogleSignInAccount? googleUser = await _googleSignInInstance
          .signInSilently();

      // If not signed in, trigger the authentication flow
      if (googleUser == null) {
        googleUser = await _googleSignInInstance.signIn();
      }

      if (googleUser == null) {
        return null; // User cancelled the sign-in
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        return UserModel.fromFirebaseUser(userCredential.user!);
      }
      return null;
    } catch (e) {
      throw 'Google sign-in failed: $e';
    }
  }

  /// Sign out
  Future<void> signOut() async {
    if (AuthConfig.useMockAuth) {
      return await _mockAuth.signOut();
    }

    try {
      if (_googleSignIn != null) {
        await Future.wait([_auth.signOut(), _googleSignIn!.signOut()]);
      } else {
        await _auth.signOut();
      }
    } catch (e) {
      throw 'Sign out failed: $e';
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    if (AuthConfig.useMockAuth) {
      return await _mockAuth.sendPasswordResetEmail(email);
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Password reset failed: $e';
    }
  }

  /// Send email verification
  Future<void> sendEmailVerification() async {
    if (AuthConfig.useMockAuth) {
      return await _mockAuth.sendEmailVerification();
    }

    try {
      if (currentUser != null && !currentUser!.emailVerified) {
        await currentUser!.sendEmailVerification();
      }
    } catch (e) {
      throw 'Email verification failed: $e';
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    if (AuthConfig.useMockAuth) {
      return await _mockAuth.updateUserProfile(
        displayName: displayName,
        photoURL: photoURL,
      );
    }

    try {
      if (currentUser != null) {
        await currentUser!.updateDisplayName(displayName);
        if (photoURL != null) {
          await currentUser!.updatePhotoURL(photoURL);
        }
      }
    } catch (e) {
      throw 'Profile update failed: $e';
    }
  }

  /// Update password
  Future<void> updatePassword(String newPassword) async {
    if (AuthConfig.useMockAuth) {
      return await _mockAuth.updatePassword(newPassword);
    }

    try {
      if (currentUser != null) {
        await currentUser!.updatePassword(newPassword);
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Password update failed: $e';
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    if (AuthConfig.useMockAuth) {
      return await _mockAuth.deleteAccount();
    }

    try {
      if (currentUser != null) {
        await currentUser!.delete();
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Account deletion failed: $e';
    }
  }

  /// Get current user model
  UserModel? getCurrentUserModel() {
    if (AuthConfig.useMockAuth) {
      return _mockAuth.getCurrentUserModel();
    }

    if (currentUser != null) {
      return UserModel.fromFirebaseUser(currentUser!);
    }
    return null;
  }

  /// Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      case 'credential-already-in-use':
        return 'This credential is already associated with a different account.';
      case 'invalid-verification-code':
        return 'Invalid verification code.';
      case 'invalid-verification-id':
        return 'Invalid verification ID.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }
}
