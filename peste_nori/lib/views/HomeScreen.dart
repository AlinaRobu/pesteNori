import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'ProfilePicture.dart';
import 'FullScreenImage.dart';
import '../controllers/UserProfileCtrl.dart';

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

  File? _profileImage;

  double get widgetsTop => 100;
  String get imageBackground => "assets/appBackground.png";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
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
                        imageFile: _profileImage,
                        radius: 35,
                        onTap: () {
                          if (_profileImage != null) {
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
    );
  }

///--------------------------PRIVATE METHOD-----------------------///
  Future<void> _loadUserData() async {
    try {
      final data = await _userProfileCtrl.getUserData();

      if (!mounted) return;

      setState(() {
        userData = data;
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

  void _showFullScreenImage() {
    if (_profileImage == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullScreenImage(
          image: _profileImage!,
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

      // Upload _profileImage to your backend here.
      
    } catch (e) {
      debugPrint('Error selecting image: $e');
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_profileImage == null) return;

    _userProfileCtrl.saveProfileImage(_profileImage!);
  }
}