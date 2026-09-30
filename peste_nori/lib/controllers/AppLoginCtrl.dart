import "package:firebase_auth/firebase_auth.dart";
import "../services/AuthService.dart";

final authService = AuthService();

class AppLoginCtrl {
  
  bool getIfLoggedIn(){
    bool loggedIn = false;
    try {
      User? user = authService.getIfLoggedIn();

      if (user != null && user!.email!.isNotEmpty) {
        loggedIn = true;
        String displayName = user.displayName ?? "";
        print('Already signed in: ${displayName}');
      } else {
        print("Not signed in");
      }
    } on FirebaseAuthException catch (e) {
      print('Login failed: ${e.code}');
    }

    return loggedIn;
  }

  Future<void> registerWithEmail(myEmailCtrl, myPswCtrl) async {
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

  resetPassword(myEmailCtrl){
    try {
      authService.resetPassword(myEmailCtrl.trim());
    } on FirebaseAuthException catch (e) {
      print('Password reset failed: ${e.code}');
    }
  }

  confirmPasswordReset(String code, String newPassword){
    try {
      authService.confirmPasswordReset(code, newPassword);
    } on FirebaseAuthException catch (e) {
      print('Password reset failed: ${e.code}');
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

  Future<void> signInWithApple() async {
    try {
      final credential = await AuthService().signInWithApple();

      print('Logged in: ${credential.user?.email}');
    } on FirebaseAuthException catch (e) {
      print('Google login failed: ${e.code}');
    }
  }

  Future<void> signInWithFacebook() async {
    try {
      final credential = await AuthService().signInWithFacebook();

      print('Logged in: ${credential.user?.email}');
    } on FirebaseAuthException catch (e) {
      print('Facebook login failed: ${e.code}');
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