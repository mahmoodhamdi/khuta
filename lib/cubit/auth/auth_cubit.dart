import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/auth_exception_handler.dart';
import 'auth_state.dart';

/// Cubit for managing Firebase authentication state.
///
/// Handles all authentication operations including:
/// - User registration with email verification
/// - Login with verification check
/// - Password reset
/// - Logout
/// - Email verification flow
///
/// ## State Flow
///
/// ```
/// AuthInitial → AuthLoading → AuthSuccess/AuthFailure
///                          ↘ AuthEmailVerificationRequired
/// ```
///
/// ## Email Verification
///
/// The app requires email verification before granting access:
/// 1. User registers → verification email sent
/// 2. User clicks verification link
/// 3. User returns to app and logs in
/// 4. If verified → AuthSuccess, else → AuthEmailVerificationRequired
///
/// ## Dependency Injection
///
/// The cubit accepts an optional [FirebaseAuth] instance for testing:
///
/// ```dart
/// // Production
/// final cubit = AuthCubit();
///
/// // Testing with mock
/// final cubit = AuthCubit(auth: mockFirebaseAuth);
/// ```
class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth;

  /// Creates an [AuthCubit] with an optional [FirebaseAuth] instance.
  ///
  /// If [auth] is not provided, uses [FirebaseAuth.instance].
  AuthCubit({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance,
      super(AuthInitial());

  /// Checks if the user is currently logged in and email verified.
  ///
  /// Emits:
  /// - [AuthSuccess] if user is logged in and email is verified
  /// - [AuthEmailVerificationRequired] if user is logged in but email not verified
  /// - [AuthInitial] if no user is logged in
  /// - [AuthFailure] if an error occurs
  Future<void> checkLoginStatus() async {
    emit(AuthLoading());
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.reload(); // Refresh user data
        final refreshedUser = _auth.currentUser;

        if (refreshedUser != null && refreshedUser.emailVerified) {
          emit(AuthSuccess(email: refreshedUser.email!));
        } else if (refreshedUser != null) {
          emit(AuthEmailVerificationRequired(email: refreshedUser.email!));
        } else {
          emit(AuthInitial());
        }
      } else {
        emit(AuthInitial());
      }
    } catch (e) {
      emit(AuthFailure(message: AuthExceptionHandler.handleException(e)));
    }
  }

  /// Registers a new user with email and password.
  ///
  /// After successful registration:
  /// 1. Creates user account in Firebase
  /// 2. Sends verification email automatically
  /// 3. Emits [AuthEmailVerificationRequired]
  ///
  /// Emits [AuthFailure] if registration fails (e.g., email already in use).
  Future<void> register(String email, String password) async {
    emit(AuthLoading());
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Send verification email immediately after registration
        await userCredential.user!.sendEmailVerification();
        emit(AuthEmailVerificationRequired(email: email));
      } else {
        emit(const AuthFailure(message: 'Registration failed'));
      }
    } catch (e) {
      emit(AuthFailure(message: AuthExceptionHandler.handleException(e)));
    }
  }

  /// Logs in a user with email and password.
  ///
  /// The login flow checks email verification status:
  /// - If verified → emits [AuthSuccess]
  /// - If not verified → emits [AuthEmailVerificationRequired]
  ///
  /// Emits [AuthFailure] if credentials are invalid.
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Check if email is verified
        await userCredential.user!.reload();
        final user = _auth.currentUser;

        if (user != null && user.emailVerified) {
          emit(AuthSuccess(email: email));
        } else if (user != null) {
          // Email not verified, require verification
          emit(AuthEmailVerificationRequired(email: email));
        } else {
          emit(const AuthFailure(message: 'Login failed'));
        }
      } else {
        emit(const AuthFailure(message: 'Login failed'));
      }
    } catch (e) {
      emit(AuthFailure(message: AuthExceptionHandler.handleException(e)));
    }
  }

  /// Sends a password reset email to the specified address.
  ///
  /// Emits:
  /// - [AuthPasswordResetSent] on success
  /// - [AuthFailure] if email is not registered or other error occurs
  Future<void> resetPassword(String email) async {
    emit(AuthLoading());
    try {
      // Attempt to send reset email
      await _auth.sendPasswordResetEmail(email: email);
      emit(AuthPasswordResetSent(email: email));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        emit(
          const AuthFailure(
            message: 'No account found with this email address',
          ),
        );
      } else {
        emit(AuthFailure(message: AuthExceptionHandler.handleException(e)));
      }
    } catch (e) {
      emit(AuthFailure(message: AuthExceptionHandler.handleException(e)));
    }
  }

  /// Signs out the current user.
  ///
  /// Clears the authentication session and emits [AuthInitial].
  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await _auth.signOut();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthFailure(message: AuthExceptionHandler.handleException(e)));
    }
  }

  /// Resends the email verification link.
  ///
  /// Use this when the user requests a new verification email.
  /// Emits [AuthEmailVerificationSent] on success.
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        emit(AuthEmailVerificationSent(email: user.email!));
      }
    } catch (e) {
      emit(AuthFailure(message: AuthExceptionHandler.handleException(e)));
    }
  }

  /// Checks if the user's email has been verified.
  ///
  /// Call this periodically or when the user returns to the app
  /// to detect when they've clicked the verification link.
  ///
  /// Emits [AuthEmailVerified] if verification is complete.
  /// Does not emit anything if still unverified (to avoid UI disruption).
  Future<void> checkEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        final refreshedUser = _auth.currentUser;

        if (refreshedUser != null && refreshedUser.emailVerified) {
          emit(AuthEmailVerified(email: refreshedUser.email!));
        }
        // If not verified, we don't emit anything to avoid disrupting the UI
      }
    } catch (e) {
      emit(AuthFailure(message: AuthExceptionHandler.handleException(e)));
    }
  }
}
