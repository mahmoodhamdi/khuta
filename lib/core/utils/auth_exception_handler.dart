import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthExceptionHandler {
  static String handleException(dynamic error) {
    String errorMessage;

    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          errorMessage = 'auth.user_not_found'.tr();
          break;
        case 'wrong-password':
          errorMessage = 'auth.wrong_password'.tr();
          break;
        case 'email-already-in-use':
          errorMessage = 'auth.email_already_in_use'.tr();
          break;
        case 'weak-password':
          errorMessage = 'auth.weak_password'.tr();
          break;
        case 'invalid-email':
          errorMessage = 'auth.invalid_email'.tr();
          break;
        case 'operation-not-allowed':
          errorMessage = 'auth.operation_not_allowed'.tr();
          break;
        case 'too-many-requests':
          errorMessage = 'auth.too_many_requests'.tr();
          break;
        case 'network-request-failed':
          errorMessage = 'auth.network_error'.tr();
          break;
        default:
          errorMessage = 'auth.unknown_error'.tr();
      }
    } else {
      errorMessage = 'auth.unknown_error'.tr();
    }

    return errorMessage;
  }
}
