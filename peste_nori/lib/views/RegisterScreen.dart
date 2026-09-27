import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../controllers/AppLoginCtrl.dart';
import 'StartupTemplate.dart';

class RegisterScreen extends StartupTemplate {
  const RegisterScreen({super.key});

  @override
  _RegisterScreen createState() => _RegisterScreen();
}

class _RegisterScreen extends StartupStateTemplate {
 _RegisterScreen();
  final AppLoginCtrl myCtrl = AppLoginCtrl();

  final TextEditingController myUsrCtrl = TextEditingController();
  final TextEditingController myPswCtrl = TextEditingController();
  final TextEditingController myConfirmPswCtrl = TextEditingController();

  bool isLoading = false;

  @override
  double get widgetsTop => 50;
  @override
  String get imageBackground => "assets/loginBackground.jpg";

  @override
  void dispose() {
    myUsrCtrl.dispose();
    myPswCtrl.dispose();
    myConfirmPswCtrl.dispose();
    super.dispose();
  }

  @override
  Widget buildEmailForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Text(
              'Creează cont',
              style: TextStyle(
                color: Colors.white,
                fontSize: 23,
                fontFamily: 'Calibri',
              ),
            ),
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

          // CONFIRM PASSWORD
          _buildTextField(
            controller: myConfirmPswCtrl,
            hintText: 'Confirmă parola',
            obscureText: true,
          ),

          const SizedBox(height: 15),

          _buildEmailButton(context),
          
      ]
    );
  }

/// -----------------------PRIVATE METHODS -----------------------------///
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

  Widget _buildEmailButton(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 200,
        height: 45,
        child: OutlinedButton(
          onPressed: () => _registerWithEmail(context),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            side: const BorderSide(
              width: 2,
              color: Colors.white,
            ),
          ),
          child: 
          const Text(
            'Creează cont',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
          ),
        ),
    );
  }

  Future<void> _registerWithEmail(BuildContext context) async {
    final email = myUsrCtrl.text.trim();
    final password = myPswCtrl.text;
    final confirmPassword = myConfirmPswCtrl.text;

    if (email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      showError(
        context,
        'Te rugăm să completezi toate câmpurile.',
      );
      return;
    }

    if (password != confirmPassword) {
      showError(
        context,
        'Parolele nu coincid.',
      );
      return;
    }

    if (password.length < 6) {
      showError(
        context,
        'Parola trebuie să conțină cel puțin 6 caractere.',
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await myCtrl.registerWithEmail(
        email,
        password,
      );

      if (!context.mounted) return;

      openApplication(context);
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;

      _showFirebaseError(context, e);
    } catch (e) {
      if (!context.mounted) return;

      showError(
        context,
        e.toString(),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showFirebaseError(BuildContext context, FirebaseAuthException error,) {
    String message;

    switch (error.code) {
      case 'email-already-in-use':
        message = 'Există deja un cont cu această adresă de email.';
        break;

      case 'invalid-email':
        message = 'Adresa de email nu este validă.';
        break;

      case 'weak-password':
        message = 'Parola este prea slabă.';
        break;

      case 'operation-not-allowed':
        message = 'Înregistrarea cu email nu este activată.';
        break;

      default:
        message = error.message ?? 'A apărut o eroare.';
    }

    showError(context, message);
  }
}