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

  String? _profileImageUrl;
  AssetImage? _profileImage;
  String _firstName = "";

  double get widgetsTop => 100;
  String get imageBackground => "assets/appBackground.png";
  int _selectedIndex = 0;

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
      bottomNavigationBar: _getBottomButtons(),
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

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ProfilePicture(
                                imageUrl: _profileImageUrl,
                                image: _profileImage,
                                radius: 35,
                                onTap: () {
                                  if (_profileImageUrl != null &&
                                      _profileImageUrl != "") {
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
                                    Text(
                                      'Bun venit,', // Second line
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: Colors.white.withValues(alpha: 0.8),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _firstName,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
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
                               const Image(
                                  height: 100,
                                  image: AssetImage(
                                    'assets/gardianul_potecilor.png'),
                                  fit: BoxFit.fill),

                              const SizedBox(width: 14),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Nivel actual', // Second line
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white.withValues(alpha: 0.8),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "GARDIAN AL POTECILOR",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFD4AF37),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          //progress
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: const LinearProgressIndicator(
                                    value: 0.75, // 75% progress
                                    minHeight: 8,
                                    backgroundColor: Color(0xFFE0E5EF),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFFD4AF37), // Gold
                                    ),
                                  ),
                                ),
                              ),                              
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '1.850',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                              Text(
                                ' / 3.000 XP',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              )
                            ],
                          ),
                        
                          const SizedBox(height: 50),

                          Row(
                            children: [
                              _getCollection(Icons.star_rounded, '38', 'Varfuri cucerite'),
                              _getCollection(Icons.home, '15', 'Cabane descoperite'),
                              _getCollection(Icons.emoji_events_rounded, '6', 'Colectii complete'),
                            ],
                          ),

                          const SizedBox(height: 50),

                          Row(
                            children: [
                              Text(
                                'Urmatorul Nivel',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ]
                          ),

                          //next progress
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                               const Image(
                                  height: 100,
                                  image: AssetImage(
                                    'assets/cuceritor_de_creste.png'),
                                  fit: BoxFit.fill),

                              const SizedBox(width: 14),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Cuceritor de Creste', // Second line
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white.withValues(alpha: 0.8),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "3.000 XP",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w300,
                                        color: Colors.white.withValues(alpha: 0.8),
                                      ),
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
                                  child: const LinearProgressIndicator(
                                    value: 0.75, // 75% progress
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
                                '62%',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),                            
                            ],
                          ),
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
  Widget _getBottomButtons(){
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      selectedItemColor: const Color(0xFFD4AF37),
      unselectedItemColor: Colors.blueGrey,
      backgroundColor: const Color.fromARGB(255, 18, 9, 9),
      showUnselectedLabels: true,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map_rounded),
          label: 'Map',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.route_rounded),
          label: 'Routes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.collections_bookmark_rounded),
          label: 'Collections',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    );
  }

  Widget _getCollection(IconData icon, String count, String text){
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Color(0xFFD4AF37),
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD4AF37),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w300,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadUserData() async {
    try {
      final data = await _userProfileCtrl.getUserData();

      if (!mounted) return;

      setState(() {
        userData = data;
        _firstName = userData!["firstName"];
        _profileImage = AssetImage(userData!["sex"] == "F" ? "assets/avatar_women.png" : "assets/avatar_man.png");
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
          imageUrl: _profileImageUrl,
          onEditTap: _showImageSourceDialog,
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

      File profileImage = File(pickedFile.path);

      _uploadProfileImage(profileImage);
    } catch (e) {
      debugPrint('Error selecting image: $e');
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
      print('Profile image saving failed: ${e.code}');
    }
  }
}