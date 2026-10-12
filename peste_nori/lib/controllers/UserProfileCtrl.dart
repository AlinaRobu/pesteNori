import "package:firebase_auth/firebase_auth.dart";
import "../services/UserService.dart";
import 'dart:io';

final userService = UserService();

class UserProfileCtrl {
  FirebaseAuth get _auth => FirebaseAuth.instance;

  Future<String> saveProfileImage(File profileImage) async {
    String imageUrl = await userService.saveProfileImage(profileImage);
    print('Profile image saved!');
      
    return imageUrl;
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final userData = await userService.getUserData();

    return userData;
  }
}