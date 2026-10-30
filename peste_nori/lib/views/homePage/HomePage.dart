import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:peste_nori/controllers/AppLoginCtrl.dart';
import 'package:peste_nori/controllers/UserProfileCtrl.dart';
import 'package:peste_nori/globals.dart';
import 'package:peste_nori/views/homePage/FullScreenImage.dart';
import 'package:peste_nori/views/startup/StartupScreen.dart';
import 'ProfilePicture.dart';

enum _HomeMenuAction { deleteAccount, signOut }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  HomePageState();

  String get imageBackground => "assets/appBackground.png";
  String? _profileImageUrl;
  AssetImage? _profileImage;
  String _firstName = "";
  Map<String, dynamic> _userData = {"peaks": [], "cabins": [], "collections": []};
  Map<String, dynamic> _level = {"xp": 0, "level": 1, "title": "", "image": "novice.png"};
  final ImagePicker _picker = ImagePicker();
  bool isLoading = true;

  final UserProfileCtrl _userProfileCtrl = UserProfileCtrl();
  final AppLoginCtrl _authCtrl = AppLoginCtrl();
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Container(
                  constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
                  decoration: BoxDecoration(
                    image: DecorationImage(image: AssetImage(imageBackground), fit: BoxFit.cover),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ProfilePicture(
                              imageUrl: _profileImageUrl,
                              image: _profileImage,
                              radius: 35,
                              onTap: () {
                                if (_profileImageUrl != null && _profileImageUrl != "") {
                                  _showFullScreenImage();
                                } else {
                                  _showImageSourceDialog();
                                }
                              },
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('${translations.welcome},', style: TextStyle(fontSize: 24, color: Colors.white.withValues(alpha: 0.8))),
                                  const SizedBox(height: 4),
                                  Text(
                                    _firstName,
                                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 100),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image(height: 100, image: AssetImage('assets/levelBadges/${this._level["image"]}'), fit: BoxFit.fill),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    this._level["title"],
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37)),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${this._level["xp"]} XP',
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300, color: Colors.white.withValues(alpha: 0.8)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 50),

                        Row(
                          children: [
                            _getCollection(Icons.star_rounded, this._userData["peaks"].length, translations.peaksConquered),
                            _getCollection(Icons.home, this._userData["cabins"].length, translations.cabinsConquered),
                            _getCollection(Icons.emoji_events_rounded, this._userData["collections"].length, translations.collectionsCompleted),
                          ],
                        ),

                        const SizedBox(height: 50),

                        Row(
                          children: [
                            Text(
                              translations.nextLevel,
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.8)),
                            ),
                          ],
                        ),

                        //next progress
                        if (this._level["nextLevel"] != null) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image(height: 100, image: AssetImage('assets/levelBadges/${this._level["nextLevel"]["image"]}'), fit: BoxFit.fill),

                              const SizedBox(width: 14),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      this._level["nextLevel"]["title"],
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white.withValues(alpha: 0.8)),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${this._level["nextLevel"]["xp"]} XP',
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300, color: Colors.white.withValues(alpha: 0.8)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: this._level["nextLevel"]["progress"],
                                    minHeight: 8,
                                    backgroundColor: Color(0xFFE0E5EF),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFFD4AF37), // Gold
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                '${this._level["nextLevel"]["remainingPercent"]}%',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white.withValues(alpha: 0.8)),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: 8,
          right: 12,
          child: SafeArea(
            child: PopupMenuButton<_HomeMenuAction>(
              tooltip: translations.settings,
              icon: const Icon(Icons.settings, color: Colors.white),
              color: Colors.white,
              onSelected: (action) {
                switch (action) {
                  case _HomeMenuAction.deleteAccount:
                    _confirmDeleteAccount();
                  case _HomeMenuAction.signOut:
                    _signOut();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _HomeMenuAction.signOut,
                  child: Row(children: [Icon(Icons.logout), SizedBox(width: 12), Text(translations.signOut)]),
                ),
                PopupMenuItem(
                  value: _HomeMenuAction.deleteAccount,
                  child: Row(
                    children: [
                      Icon(Icons.delete_forever, color: Colors.red),
                      SizedBox(width: 12),
                      Text(translations.deleteAccount, style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  ///-------------------------------PRIVATE METHODS---------------------------------///
  Widget _getCollection(IconData icon, int count, String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 26, 29, 69),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color.fromARGB(255, 58, 58, 57).withValues(alpha: 0.5), width: 1),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Color(0xFFD4AF37), size: 28),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37)),
            ),
            const SizedBox(height: 4),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300, color: Colors.white.withValues(alpha: 0.8)),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showFullScreenImage() {
    if (_profileImageUrl == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullScreenImage(imageUrl: _profileImageUrl, onEditTap: _showImageSourceDialog),
      ),
    );
  }

  Future<void> _showImageSourceDialog() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(translations.gallery),
                onTap: () {
                  Navigator.pop(context, ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    await _pickImage(source);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 85, maxWidth: 1200, maxHeight: 1200);

      if (pickedFile == null) return;

      File profileImage = File(pickedFile.path);

      _uploadProfileImage(profileImage);
    } catch (e) {
      debugPrint('${translations.selImageError}: $e');
    }
  }

  Future<void> _uploadProfileImage(profileImage) async {
    if (profileImage == null) return;

    try {
      String imageUrl = await _userProfileCtrl.saveProfileImage(profileImage!);

      setState(() {
        _profileImageUrl = imageUrl;
      });
    } on FirebaseAuthException catch (e) {
      print('${translations.saveProfileImageError}: ${e.code}');
    }
  }

  Future<void> _loadUserData() async {
    try {
      final data = await _userProfileCtrl.getUserData();

      if (!mounted) return;

      setState(() {
        _userData = data!;
        _firstName = _userData["firstName"];
        _level = _userData["level"];
        _profileImage = AssetImage(_userData["sex"] == "F" ? "assets/avatar_women.png" : "assets/avatar_man.png");
        _profileImageUrl = _userData['profileImageUrl'];
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      debugPrint('${translations.loadingUserDataError}: $e');
    }
  }

  Future<void> _signOut() async {
    try {
      await _authCtrl.signOut();

      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute<void>(builder: (_) => const StartupScreen()), (route) => false);
    } catch (e) {
      debugPrint('${translations.signOutError}: $e');
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${translations.deleteAccount}?'),
        content: Text(translations.deleteAccountConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(translations.cancel)),
          TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(translations.deleteAccount)),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _authCtrl.deleteAccount();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      if (e.code == 'requires-recent-login') {
        bool authenticated = await _reauthenticateUser();

        if (!authenticated) {
          return;
        }

        // Try deleting again after reauthentication.
        await _authCtrl.deleteAccount();
      } else {
        final message = translations.deleteAccountError;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        return;
      }
    }

    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute<void>(builder: (_) => const StartupScreen()), (route) => false);
  }

  Future<String?> _askForPassword() async {
    try {
      return await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(translations.confirmYourPassword),
            content: TextField(
              controller: controller,
              obscureText: true,
              decoration: InputDecoration(labelText: translations.password),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text(translations.cancel)),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, controller.text);
                },
                child: Text(translations.confirm),
              ),
            ],
          );
        },
      );
    } finally {
      controller.clear();
    }
  }

  Future<bool> _reauthenticateUser() async {
    if (currentUser == null) {
      return false;
    }

    String? password;
    final providers = currentUser?.providerData.map((provider) => provider.providerId).toSet();

    // Email / password
    if (providers!.contains('password')) {
      password = await _askForPassword();
    }

    bool authenticated = false;
    try {
      authenticated = await _authCtrl.reauthenticateWithCredential(providers, password);
    } on FirebaseAuthException catch (e) {
      String message = translations.deleteAccountError;
      if (e.code == "invalid-credential") {
        message = translations.wrongPassword;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }

    setState(() {
      password = "";
    });
    return authenticated;
  }
}