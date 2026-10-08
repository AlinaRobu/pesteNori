import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../../globals.dart';

class AuthService {
  static const String _serverClientId =
      '154994703214-hddq99gdadm0jonf7i0npuashdavsgbe.apps.googleusercontent.com';
  static Future<void>? _googleSignInInitialization;

  FirebaseAuth get _auth => FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? getIfLoggedIn(){
    currentUser = _auth.currentUser;

    return _auth.currentUser;
  }

  Future<UserCredential> registerWithEmail(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> resetPassword(String email){
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> confirmPasswordReset(String code, String newPassword){
    return _auth.confirmPasswordReset(code: code, newPassword: newPassword);
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signInWithFacebook() async {
    if (kIsWeb) {
      return await _auth.signInWithPopup(FacebookAuthProvider());
    } else {
      return await FirebaseAuth.instance.signInWithProvider(FacebookAuthProvider());
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      return await _auth.signInWithPopup(GoogleAuthProvider());
    } else {
      return await FirebaseAuth.instance.signInWithProvider(GoogleAuthProvider());
    }
  }

  Future<UserCredential> signInWithApple() async {
    if (kIsWeb) {
      return await _auth.signInWithPopup(AppleAuthProvider());
    } else {
      return await FirebaseAuth.instance.signInWithProvider(AppleAuthProvider());
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

  Future<void> loginWithFacebook() async {
  try {
    final LoginResult result = await FacebookAuth.instance.login();

    switch (result.status) {
      case LoginStatus.success:
        final AccessToken accessToken = result.accessToken!;

        print('Facebook token: ${accessToken.tokenString}');

        final userData = await FacebookAuth.instance.getUserData();

        print(userData);
        break;

      case LoginStatus.cancelled:
        print('Facebook login cancelled');
        break;

      case LoginStatus.failed:
        print('Facebook login failed: ${result.message}');
        break;

      case LoginStatus.operationInProgress:
        print('Facebook login already in progress');
        break;
    }
  } catch (e) {
    print('Facebook login exception: $e');
  }
}
}