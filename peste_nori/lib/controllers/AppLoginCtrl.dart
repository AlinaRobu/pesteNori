import "package:firebase_auth/firebase_auth.dart";
import "../services/AuthService.dart";
import '../../globals.dart';
import '../services/UserService.dart';

final authService = AuthService();
final userService = UserService();

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

      print('Register in: ${credential.user?.uid}');
      //save user
      await userService.addUser(credential.user);
    } on FirebaseAuthException catch (e) {
      print('Registering failed: ${e.code}');
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
      final credential = await authService.signInWithGoogle();

      print('Logged in: ${credential.user?.email}');

      final exists = await userService.userExists(credential.user?.uid);

      if (!exists) {
        await userService.addUser(credential.user);
      }
    } on FirebaseAuthException catch (e) {
      print('Google login failed: ${e.code}');
    }
  }

  Future<void> signInWithApple() async {
    try {
      final credential = await authService.signInWithApple();

      print('Logged in: ${credential.user?.email}');

      final exists = await userService.userExists(credential.user?.uid);

      if (!exists) {
        await userService.addUser(credential.user);
      }
    } on FirebaseAuthException catch (e) {
      print('Google login failed: ${e.code}');
    }
  }

  Future<void> signInWithFacebook() async {
    try {
      final credential = await authService.signInWithFacebook();

      print('Logged in: ${credential.user?.email}');

      final exists = await userService.userExists(credential.user?.uid);

      if (!exists) {
        await userService.addUser(credential.user);
      }
    } on FirebaseAuthException catch (e) {
      print('Facebook login failed: ${e.code}');
    }
  }

  Future<void> signOut() async {
    try {
      await authService.signOut();

      print('Logged out: ${currentUser}');
    } on FirebaseAuthException catch (e) {
      print('Google login failed: ${e.code}');
    }
  }

  Future<void> deleteAccount() async{
    await authService.deleteAccount();

    print('Deleted account ${currentUser}');
  }

  Future<bool> reauthenticateWithCredential (Set<String>? providers, String? password) async {
    return await authService.reauthenticateWithCredential(providers, password);
  }
}