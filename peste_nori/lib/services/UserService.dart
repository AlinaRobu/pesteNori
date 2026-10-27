import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:peste_nori/services/LevelService.dart';

import 'dart:io';

import '../../globals.dart';

class UserService {
  final FirebaseFirestore _auth = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> addUser(User? user) async {
    if (user != null) {
      await _auth.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'username': user.displayName ?? '',
        'avatarUrl': user.photoURL ?? '',
        'joinedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> deleteUser(User? user) async {
    if (user != null) {
      await _auth.collection('users').doc(user.uid).delete();
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    if (currentUser == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser?.uid)
        .get();

    if (!doc.exists) return null;

    Map<String, dynamic>? userData = doc.data() ?? {};
    userData["level"] = await LevelService().getLevel(userData["level"]);

    return userData;
  }

  Future<bool> userExists(String? uid) async {
    if (uid == null || uid == "") {
      return false;
    }
    final doc = await _auth.collection('users').doc(uid).get();

    return doc.exists;
  }

  Future<String> saveProfileImage(File image) async {
    String imageUrl = "";
    if (currentUser != null) {
      imageUrl = await uploadProfileImage(image, currentUser?.uid);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser?.uid)
          .set({'profileImageUrl': imageUrl}, SetOptions(merge: true));
    }

    return imageUrl;
  }

  Future<void> setUserMainData(Map<String, Object> userData) async {
    if (currentUser != null) {
      await _auth.collection('users').doc(currentUser?.uid).set({
        'firstName': userData["firstName"] ?? '',
        'lastName': userData["lastName"] ?? '',
        'dateOfBirth': userData["dateOfBirth"] ?? 0,
        'sex': userData["sex"] ?? 'F',
        'showBirthdayBadge': userData["showBirthdayBadge"] ?? false,
        'level': 0,
      }, SetOptions(merge: true));
    }
  }

  ///--------------------------------PRIVATE METHODS------------------------///
  Future<String> uploadProfileImage(File image, String? uid) async {
    final ref = _storage.ref().child('profile_images').child('$uid.jpg');
    try {
      final snapshot = await ref.putFile(image);
      print('Upload complete: ${snapshot.state}');
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      print('Storage error code: ${e.code}');
      print('Storage error message: ${e.message}');
      return "";
    }
  }
}
