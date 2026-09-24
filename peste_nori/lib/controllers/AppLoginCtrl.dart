import "package:firebase_auth/firebase_auth.dart";
import "../services/AuthService.dart";

final authService = AuthService();

class AppLoginCtrl {
  registerWithEmail(myEmailCtrl, myPswCtrl) async {
    try {
      final credential = await authService.registerWithEmail(
        myEmailCtrl.trim(),
        myPswCtrl,
      );

      print('Logged in: ${credential.user?.uid}');
    } on FirebaseAuthException catch (e) {
      print('Login failed: ${e.code}');
    }
  }

  signInWithEmail(myEmailCtrl, myPswCtrl) async {
    try {
      final credential = await authService.signInWithEmail(
        myEmailCtrl.trim(),
        myPswCtrl,
      );

      print('Logged in: ${credential.user?.uid}');
    } on FirebaseAuthException catch (e) {
      print('Login failed: ${e.code}');
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final credential = await AuthService().signInWithGoogle();

      print('Logged in: ${credential.user?.email}');
    } on FirebaseAuthException catch (e) {
      print('Google login failed: ${e.code}');
    }
  }

  Future<void> signOut() async {
    try {
      await AuthService().signOut();

      print('Logged out: ${AuthService().currentUser}');
    } on FirebaseAuthException catch (e) {
      print('Google login failed: ${e.code}');
    }
  }
}