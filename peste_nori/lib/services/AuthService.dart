import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static const String _serverClientId =
      '154994703214-hddq99gdadm0jonf7i0npuashdavsgbe.apps.googleusercontent.com';
  static Future<void>? _googleSignInInitialization;

  FirebaseAuth get _auth => FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> registerWithEmail(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      return await _auth.signInWithPopup(GoogleAuthProvider());
    } else {
      return await FirebaseAuth.instance.signInWithProvider(GoogleAuthProvider());
    }
  }

  Future<void> signOut() async {
    if (!kIsWeb) {
      await _ensureGoogleSignInInitialized();
      await GoogleSignIn.instance.signOut();
    }
    await _auth.signOut();
  }

  Future<void> _ensureGoogleSignInInitialized() {
    return _googleSignInInitialization ??= GoogleSignIn.instance.initialize(
      serverClientId: _serverClientId,
    );
  }
}