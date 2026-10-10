import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import '../../globals.dart';

class UserService {
    final FirebaseFirestore _auth = FirebaseFirestore.instance;
    final FirebaseStorage _storage = FirebaseStorage.instance;

    Future<void> addUser(User? user) async {
        if (user != null) {
            await _auth
            .collection('users')
            .doc(user.uid)
            .set({
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
            await _auth
            .collection('users')
            .doc(user.uid)
            .delete();
        }
    }

    Future<Map<String, dynamic>?> getUserData() async {

        if (currentUser == null) return null;

        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser?.uid)
            .get();

        if (!doc.exists) return null;

        return doc.data();
    }
    
    Future<bool> userExists(String? uid) async {
        if(uid == null || uid == ""){
            return false;
        }
        final doc = await _auth
            .collection('users')
            .doc(uid)
            .get();

        return doc.exists;
    }

    Future<void> saveProfileImage(File image, User user) async {
        final imageUrl = await uploadProfileImage(image, user.uid);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
            'profileImageUrl': imageUrl,
        }, SetOptions(merge: true));
    }

///--------------------------------PRIVATE METHODS------------------------///
    Future<String> uploadProfileImage(File image, String? uid) async {
        final ref = _storage.ref()
            .child('profile_images')
            .child('$uid.jpg');

        await ref.putFile(image);

        return await ref.getDownloadURL();
    }
}