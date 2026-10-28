import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../controllers/AppLoginCtrl.dart';
import 'LoginScreen.dart';
import '../StartupTemplate.dart';
import 'package:peste_nori/globals.dart';

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

  @override
  double get widgetsTop => 50;
  @override
  String get imageBackground => "assets/loginBackground.jpg";
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  void dispose() {
    myUsrCtrl.dispose();
    myPswCtrl.dispose();
    myConfirmPswCtrl.dispose();
    super.dispose();
  }

  @override
  Widget topWidgets(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Text(
              translations.createTheAccount,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontFamily: 'Calibri',
              ),
            ),
          // EMAIL
          buildTextField(
            controller: myUsrCtrl,
            hint: 'Email',
            icon: Icons.email_outlined,
          ),
          const SizedBox(height: 14),
          // PASSWORD
          buildTextField(
            controller: myPswCtrl,
            hint: translations.password,
            icon: Icons.lock_outline,
            obscureText: obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Colors.white70,
              ),
              onPressed: () {
                setState(() {
                  obscurePassword = !obscurePassword;
                });
              },
            ),
          ),
          const SizedBox(height: 14),
          // CONFIRM PASSWORD
          buildTextField(
            controller: myConfirmPswCtrl,
            hint: translations.confirmPassword,
            icon: Icons.lock_outline,
            obscureText: obscureConfirmPassword,
            suffixIcon: IconButton(
              icon: Icon(
                obscureConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Colors.white70,
              ),
              onPressed: () {
                setState(() {
                  obscureConfirmPassword =
                      !obscureConfirmPassword;
                });
              },
            ),
          ),

          const SizedBox(height: 10),

          // Create account button
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: () => _registerWithEmail(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 8, 128, 249),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    translations.createAccount,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 12),
                  Icon(Icons.arrow_forward, size: 23),
                ],
              ),
            ),
          ),
      ]
    );
  }

  @override
  Widget bottomWidgets(BuildContext context){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 55),
        Text(
          '${translations.accountExists}? ',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        GestureDetector(
          onTap: () {
             Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LoginScreen(),
              ),
            );
          },
          child: Text(
            translations.authentication,
            style: TextStyle(
              color: Color(0xFF168BFF),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
/// -----------------------PRIVATE METHODS -----------------------------///
 Future<void> _registerWithEmail(BuildContext context) async {
    final email = myUsrCtrl.text.trim();
    final password = myPswCtrl.text;
    final confirmPassword = myConfirmPswCtrl.text;

    if (email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      showError(
        context,
        new FirebaseAuthException(code: "", message: translations.fillAll + "."),
      );
      return;
    }

    if (password != confirmPassword) {
      showError(
        context,
        new FirebaseAuthException(code: "", message: translations.diffPasswords + "."),
      );
      return;
    }

    if (password.length < 6) {
      showError(context,
        new FirebaseAuthException(code: "", message: translations.passLengthReq + "."),
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

      openApplication(context, true);
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;

      _showFirebaseError(context, e);
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
        message = translations.emailAlreadyInUse + '.';
        break;

      case 'invalid-email':
        message = translations.invalidEmail + '.';
        break;

      case 'weak-password':
        message = translations.weakPass + '.';
        break;

      case 'operation-not-allowed':
        message = translations.emailRegNotAllowed + '.';
        break;

      default:
        message = error.message ?? translations.unknownError + '.';
    }

    showError(context, new FirebaseAuthException(code: message));
  }
}