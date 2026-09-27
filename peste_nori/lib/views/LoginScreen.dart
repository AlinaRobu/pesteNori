import 'package:flutter/material.dart';
import 'StartupTemplate.dart';


class LoginScreen extends StartupTemplate {
  const LoginScreen({super.key});

  @override
  _LoginScreen createState() => _LoginScreen();
}

class _LoginScreen extends StartupStateTemplate {
 _LoginScreen();

  final TextEditingController myUsrCtrl = TextEditingController();
  final TextEditingController myPswCtrl = TextEditingController();

  @override
  double get widgetsTop => 100;
  @override
  String get imageBackground => "assets/loginBackground.jpg";

  @override
  void dispose() {
    myUsrCtrl.dispose();
    myPswCtrl.dispose();
    super.dispose();
  }

  @override
  Widget buildEmailForm(BuildContext context) {
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
      ],
    );
  }

/// -----------------------PRIVATE METHODS -----------------------------///
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
        !isLoading;

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
          child: isLoading
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

  Future<void> _loginWithEmail(BuildContext context) async {
    setState(() {
      isLoading = true;
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

      showError(context, error);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  } 
}