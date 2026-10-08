import "package:firebase_auth/firebase_auth.dart";
import "../services/UserService.dart";
import "package:peste_nori/globals.dart";
import 'dart:io';

final userService = UserService();

class UserProfileCtrl {
  FirebaseAuth get _auth => FirebaseAuth.instance;

  Future<void> saveProfileImage(File profileImage) async {
    try {
      await userService.uploadProfileImage(profileImage, currentUser?.uid);

      print('Profile image failed');
      //save user
    } on FirebaseAuthException catch (e) {
      print('Profile image failed: ${e.code}');
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final userData = await userService.getUserData();

    return userData;
  }
}