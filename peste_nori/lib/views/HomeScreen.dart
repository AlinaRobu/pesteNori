import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:peste_nori/globals.dart';
import 'package:peste_nori/views/StartupScreen.dart';
import 'ProfilePicture.dart';
import 'FullScreenImage.dart';
import '../controllers/UserProfileCtrl.dart';
import '../controllers/AppLoginCtrl.dart';

enum _HomeMenuAction { deleteAccount, signOut }

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
 _HomeScreenState();
  Map<String, dynamic>? userData;
  bool isLoading = true;
  final ImagePicker _picker = ImagePicker();
  final UserProfileCtrl _userProfileCtrl = UserProfileCtrl();
  final AppLoginCtrl _authCtrl = AppLoginCtrl();
  final controller = TextEditingController();

  File? _profileImage;
  String? _profileImageUrl;

  double get widgetsTop => 100;
  String get imageBackground => "assets/appBackground.png";

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
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height,
                    ),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(imageBackground),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          ProfilePicture(
                            imageUrl: _profileImageUrl,
                            radius: 35,
                            onTap: () {
                              if (_profileImageUrl != null && _profileImageUrl != "") {
                                _showFullScreenImage();
                              } else {
                                _showImageSourceDialog();
                              }
                            },
                          ),

                          const SizedBox(height: 30),

                          // Other widgets...
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
                tooltip: 'Settings',
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
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: _HomeMenuAction.signOut,
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 12),
                        Text('Sign out'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: _HomeMenuAction.deleteAccount,
                    child: Row(
                      children: [
                        Icon(Icons.delete_forever, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Delete account', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

///--------------------------PRIVATE METHOD-----------------------///
  Future<void> _loadUserData() async {
    try {
      final data = await _userProfileCtrl.getUserData();

      if (!mounted) return;

      setState(() {
        userData = data;
        _profileImageUrl = userData?['profileImageUrl'];
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> _signOut() async {
    try {
      await _authCtrl.signOut();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => const StartupScreen(),
        ), (route) => false,
      );
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'This permanently deletes your account. You may need to sign in again first.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete account'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _authCtrl.deleteAccount();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      if(e.code == 'requires-recent-login'){
        bool authenticated = await _reauthenticateUser();

        if (!authenticated) {
          return;
        }

        // Try deleting again after reauthentication.
        await _authCtrl.deleteAccount();        
      } else {
        final message = 'Could not delete your account. Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        return;
      }
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => const StartupScreen(),
      ), (route) => false,
    );
  }

  Future<String?> _askForPassword() async {
    try {
      return await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Confirm your password'),
            content: TextField(
              controller: controller,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, controller.text);
                },
                child: const Text('Confirm'),
              ),
            ],
          );
        },
      );
    } finally {
      controller.clear();
    }
  }

  Future<bool> _reauthenticateUser() async{
    if (currentUser == null) {
      return false;
    }

    String? password;
    final providers = currentUser?.providerData
        .map((provider) => provider.providerId)
        .toSet();

    // Email / password
    if (providers!.contains('password')) {
      password = await _askForPassword();
    }

    bool authenticated = false;
    try{  
      authenticated = await _authCtrl.reauthenticateWithCredential(providers, password);
    } on FirebaseAuthException catch (e) {
      String message = "Cannot delete account";
      if(e.code == "invalid-credential"){
        message = "Wrong password!";
      }
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
      );
    }

    setState((){
      password = "";
    });
    return authenticated;
  }

  void _showFullScreenImage() {
    if (_profileImageUrl == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullScreenImage(
          imageUrl: _profileImageUrl
        ),
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
                title: const Text('Galerie'),
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
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (pickedFile == null) return;

      setState(() {
        _profileImage = File(pickedFile.path);
      });

      _uploadProfileImage();
    } catch (e) {
      debugPrint('Error selecting image: $e');
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_profileImage == null) return;

    _userProfileCtrl.saveProfileImage(_profileImage!);
  }
}