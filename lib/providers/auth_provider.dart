// lib/providers/auth_provider.dart
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hack_front/services/auth_service.dart';

enum AuthStatus {
  uninitialized,
  authenticated,
  authenticating,
  unauthenticated,
}

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  User? _user;
  String? token;
  AuthStatus _status = AuthStatus.uninitialized;
  String? _errorMessage;
  StreamSubscription<User?>? _authStateSubscription;

  AuthProvider(this._authService) {
    _authStateSubscription = _authService.authStateChanges.listen(
      _onAuthStateChanged,
    );
    _user = _authService.currentUser; // Check initial state
    _status = _user == null
        ? AuthStatus.unauthenticated
        : AuthStatus.authenticated;
  }

  User? get user => _user;
  AuthStatus get status => _status;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  String? get errorMessage => _errorMessage;

  void clearErrorMessage() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
      _status = AuthStatus.unauthenticated;
    } else {
      _user = firebaseUser;
      token = await firebaseUser.getIdToken();
      _status = AuthStatus.authenticated;
    }
    _errorMessage = null; // Clear error on auth state change
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // _onAuthStateChanged will handle setting _user and _status
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _handleFirebaseAuthError(e);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String email, String password) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );
      // _onAuthStateChanged will handle setting _user and _status
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _handleFirebaseAuthError(e);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    // _onAuthStateChanged will handle setting _user and _status to unauthenticated
  }

  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      default:
        return 'An unknown error occurred. Please try again.';
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
