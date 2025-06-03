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
        emit(AuthSuccess(email: user.email!));
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
        emit(AuthSuccess(email: email));
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
        emit(AuthSuccess(email: email));
      } else {
        emit(const AuthFailure(message: 'Login failed'));
      }
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
}
