// lib/core/utils/auth_exceptions.dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthException implements Exception {
  final String code;
  final String message;

  AuthException(this.code, this.message);

  factory AuthException.fromFirebase(FirebaseAuthException exception) {
    String message;
    switch (exception.code) {
      case 'invalid-email':
        message = 'Email is not valid';
        break;
      case 'user-disabled':
        message = 'This account has been disabled';
        break;
      case 'user-not-found':
        message = 'No account found with this email';
        break;
      case 'wrong-password':
        message = 'Incorrect password';
        break;
      case 'email-already-in-use':
        message = 'Email already in use';
        break;
      case 'operation-not-allowed':
        message = 'Email/password accounts are not enabled';
        break;
      case 'weak-password':
        message = 'Password is too weak';
        break;
      default:
        message = 'An unknown error occurred';
    }
    return AuthException(exception.code, message);
  }

  @override
  String toString() => message;
}