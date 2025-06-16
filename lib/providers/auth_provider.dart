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
  AuthStatus _status = AuthStatus.uninitialized;
  String? _errorMessage;
  StreamSubscription<User?>? _authStateSubscription;
  String? _idToken; // To store the Firebase ID token

  AuthProvider(this._authService) {
    _authStateSubscription = _authService.authStateChanges.listen(
      _onAuthStateChanged,
    );
    // Initial check
    final currentUser = _authService.currentUser;
    _user = currentUser;
    if (currentUser != null) {
      _status = AuthStatus.authenticated;
      _fetchIdToken(currentUser); // Fetch token for initially logged-in user
    } else {
      _status = AuthStatus.unauthenticated;
    }
  }

  User? get user => _user;
  AuthStatus get status => _status;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  String? get errorMessage => _errorMessage;
  String? get idToken => _idToken; // Getter for the token

  // Method to get a fresh token, handling potential refresh
  Future<String?> getIdToken([bool forceRefresh = false]) async {
    if (_user == null) {
      _idToken = null;
      return null;
    }
    try {
      final token = await _user!.getIdToken(forceRefresh);
      _idToken = token;
      return token;
    } catch (e) {
      if (kDebugMode) {
        print("AuthProvider: Error fetching ID token: $e");
      }
      // Handle token fetch error, e.g., sign out user or prompt re-login
      await signOut(); // Example: sign out if token refresh fails critically
      return null;
    }
  }

  void clearErrorMessage() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<void> _fetchIdToken(User firebaseUser) async {
    try {
      _idToken = await firebaseUser.getIdToken();
      if (kDebugMode) {
        // print("AuthProvider: Fetched ID Token: $_idToken"); // Be careful logging tokens
        print("AuthProvider: ID Token fetched successfully.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("AuthProvider: Error fetching initial ID token: $e");
      }
      _idToken = null; // Ensure token is null on error
      // Potentially sign out or mark as unauthenticated if token fetch fails critically
    }
    notifyListeners(); // Notify even if token fetch fails, so UI can react
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
      _idToken = null; // Clear token on sign out
      _status = AuthStatus.unauthenticated;
    } else {
      _user = firebaseUser;
      await _fetchIdToken(firebaseUser); // Fetch new token on auth state change
      _status = AuthStatus.authenticated;
    }
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();
    try {
      final userCredential = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // _onAuthStateChanged will handle setting _user, _idToken, and _status
      return userCredential != null;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _handleFirebaseAuthError(e);
      _status = AuthStatus.unauthenticated;
      _idToken = null; // Clear token on failed sign-in
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String email, String password) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();
    try {
      final userCredential = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );
      // _onAuthStateChanged will handle setting _user, _idToken, and _status
      return userCredential != null;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _handleFirebaseAuthError(e);
      _status = AuthStatus.unauthenticated;
      _idToken = null; // Clear token on failed sign-up
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    // _onAuthStateChanged will clear _user and _idToken and set status
  }

  String _handleFirebaseAuthError(FirebaseAuthException e) {
    // ... (error handling code remains the same) ...
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
