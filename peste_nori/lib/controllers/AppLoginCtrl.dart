import "package:firebase_auth/firebase_auth.dart";
import "../services/AuthService.dart";
import '../../globals.dart';
import '../services/UserService.dart';

final authService = AuthService();
final userService = UserService();

class AppLoginCtrl {
  
  Future<void> registerWithEmail(myEmailCtrl, myPswCtrl) async {
    final credential = await authService.registerWithEmail(
      myEmailCtrl.trim(),
      myPswCtrl,
    );

    print('Register in: ${credential.user?.uid}');
    //save user
    await userService.addUser(credential.user);

    print('Logged in: ' + authService.getIfLoggedIn().toString());
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
    final credential = await authService.signInWithEmail(
      myEmailCtrl.trim(),
      myPswCtrl,
    );

    print('Logged in: ' + authService.getIfLoggedIn().toString());
  }

  Future<bool> signInWithGoogle() async {
    final credential = await authService.signInWithGoogle();

    print('Logged in: ${credential.user?.email}');

    final exists = await userService.userExists(credential.user?.uid);

    if (!exists) {
      await userService.addUser(credential.user);
    }

    print('Logged in: ' + authService.getIfLoggedIn().toString());

    return !exists;
  }

  Future<bool> signInWithApple() async {
    final credential = await authService.signInWithApple();

    print('Logged in: ${credential.user?.email}');

    final exists = await userService.userExists(credential.user?.uid);

    if (!exists) {
      await userService.addUser(credential.user);
    }

    print('Logged in: ' + authService.getIfLoggedIn().toString());

    return !exists;
  }

  Future<bool> signInWithFacebook() async {
    final credential = await authService.signInWithFacebook();

    print('Logged in: ${credential?.user?.email}');

    if(credential == null){
      throw new FirebaseAuthException(message: "Facebook login failed", code:"login_failed");
    }
    final exists = await userService.userExists(credential?.user?.uid);

    if (!exists) {
      await userService.addUser(credential?.user);
    }

    print('Logged in: ' + authService.getIfLoggedIn().toString());

    return !exists;
  }

  Future<void> signOut() async {
    await authService.signOut();

    print('Logged out: ${currentUser}');

    print('Logged in: ' + authService.getIfLoggedIn().toString());
  }

  Future<void> deleteAccount() async{
    await authService.deleteAccount();

    print('Deleted account ${currentUser}');
    await userService.deleteUser(currentUser);

    print('Logged in: ' + authService.getIfLoggedIn().toString());
  }

  Future<bool> reauthenticateWithCredential (Set<String>? providers, String? password) async {
    return await authService.reauthenticateWithCredential(providers, password);
  }
}