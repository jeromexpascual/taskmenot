// lib/features/auth/app_auth_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taskmenot/features/auth/data/auth_repository.dart';

class AppAuthProvider with ChangeNotifier {
  final AuthRepository _authRepo;
  User? _currentUser;

  AppAuthProvider({required AuthRepository authRepo}) : _authRepo = authRepo {
    _authRepo.authStateChanges.listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  User? get currentUser => _currentUser;
  bool get isEmailVerified => _currentUser?.emailVerified ?? false;

  Stream<User?> get authStateChanges => _authRepo.authStateChanges;

  Future<void> reloadUser() async {
    await _currentUser?.reload();
    _currentUser = _authRepo.currentUser;
    notifyListeners();
  }

  Future<void> sendEmailVerification() async {
    await _authRepo.sendEmailVerification();
  }

  // Add this to your AuthProvider class in lib/features/auth/app_auth_provider.dart
  Future<void> sendPasswordResetEmail(String email) async {
    await _authRepo.sendPasswordResetEmail(email);
  }

  Future<User?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userCredential = await _authRepo.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );
      _currentUser = userCredential.user;

      // Create Firestore profile
      await createUserProfile(
        uid: _currentUser!.uid,
        email: email,
        name: name,
      );
      // Make sure you notify listeners after the profile is created
      notifyListeners();
      return _currentUser;
    } catch (e) {
      rethrow;
    }
  }


  // Add to your AuthProvider class
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String name,
  }) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _authRepo.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _currentUser = userCredential.user;
      notifyListeners();
      return _currentUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final userCredential = await _authRepo.signInWithGoogle();
      _currentUser = userCredential.user;

      // Check if the user document already exists
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();

      // If it doesn't exist, create it
      if (!userDoc.exists) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .set({
          'name': _currentUser!.displayName ?? 'No Name',
          'email': _currentUser!.email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      notifyListeners();
      return _currentUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _authRepo.signOut();
    _currentUser = null;
    notifyListeners();
  }

}