import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/auth_exception_handler.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final _auth = FirebaseAuth.instance;

  AuthCubit() : super(AuthInitial());

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

  Future<void> resetPassword(String email) async {
    emit(AuthLoading());
    try {
      await _auth.sendPasswordResetEmail(email: email);
      emit(AuthPasswordResetSent(email: email));
    } catch (e) {
      emit(AuthFailure(message: AuthExceptionHandler.handleException(e)));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await _auth.signOut();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthFailure(message: AuthExceptionHandler.handleException(e)));
    }
  }

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
