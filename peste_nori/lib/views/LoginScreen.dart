import 'package:flutter/material.dart';

import '../controllers/AppLoginCtrl.dart';
import 'StartupTemplate.dart';


class LoginScreen extends StartupTemplate {
  const LoginScreen({super.key});

  @override
  _LoginScreen createState() => _LoginScreen();
}

class _LoginScreen extends StartupStateTemplate {
 _LoginScreen();
  final AppLoginCtrl myCtrl = AppLoginCtrl();

  final TextEditingController myUsrCtrl = TextEditingController();
  final TextEditingController myPswCtrl = TextEditingController();

  bool _isLoading = false;

  @override
  double get widgetsTop => 100;
  @override
  String get imageBackground => "assets/backgroundCollors.png";

  @override
  void dispose() {
    myUsrCtrl.dispose();
    myPswCtrl.dispose();
    super.dispose();
  }

  @override
  Widget getPageWidgets(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 50, right: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLoginArea(context),

            const SizedBox(height: 15),

            _buildGoogleButton(context)
          ],
        ),
      ),
    );
  }

  Widget _buildLoginArea(BuildContext context) {
    return Column(
      children: [
        // EMAIL
          _buildTextField(
            controller: myUsrCtrl,
            hintText: 'Email',
            keyboardType: TextInputType.emailAddress,
          ),

          // PASSWORD
          _buildTextField(
            controller: myPswCtrl,
            hintText: 'Parolă',
            obscureText: true,
          ),

        const SizedBox(height: 20),

        // Email login
        ElevatedButton(
          onPressed: () => _loginWithEmail(context),
          child: const Text('Conectează-te'),
        ),

        const SizedBox(height: 15),

        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text('SAU'),
            ),
            Expanded(child: Divider()),
          ],
        ),
      ],
    );
  }

  Widget _buildGoogleButton(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 220,
        height: 45,
        child: OutlinedButton(
          onPressed: _isLoading
              ? null
              : () => _loginWithGoogle(context),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'G',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 10),
              Text(
                'Continuă cu Google',
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white38,
      hintText: hint,
      contentPadding: const EdgeInsets.only(
        left: 14,
        bottom: 8,
        top: 8,
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      height: 55,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 20,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white38,
          hintText: hintText,
          contentPadding: const EdgeInsets.only(
            left: 14,
            bottom: 8,
            top: 8,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _emailLoginButton(BuildContext context) {
    final enabled =
        myUsrCtrl.text.trim().isNotEmpty &&
        myPswCtrl.text.isNotEmpty &&
        !_isLoading;

    return TextButton(
      onPressed: enabled ? () => _loginWithEmail(context) : null,
      child: Ink(
        decoration: BoxDecoration(
          color: enabled ? Colors.white38 : Colors.white10,
          borderRadius: const BorderRadius.all(
            Radius.circular(80),
          ),
        ),
        child: Container(
          width: 130,
          height: 40,
          alignment: Alignment.center,
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Login',
                  style: TextStyle(
                    color: enabled ? Colors.white : Colors.white24,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _googleLoginButton(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 220,
        height: 45,
        child: OutlinedButton(
          onPressed: _isLoading
              ? null
              : () => _loginWithGoogle(context),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // You can replace this with your Google logo asset.
              const Text(
                'G',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              const Text('Sign in with Google'),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loginWithEmail(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await myCtrl.signInWithEmail(
        myUsrCtrl.text.trim(),
        myPswCtrl.text
      );

      if (!context.mounted) return;

      // At this point Firebase authentication succeeded.
      openApplication(context);

    } catch (error) {
      if (!context.mounted) return;

      _showError(context, error);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loginWithGoogle(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await myCtrl.signInWithGoogle();

      if (!context.mounted) return;

      // Google authentication succeeded.
      // Navigate to your application here if needed.
      openApplication(context);
    } catch (error) {
      if (!context.mounted) return;

      _showError(context, error);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(BuildContext context, Object error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login failed'),
        content: Text(error.toString()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}