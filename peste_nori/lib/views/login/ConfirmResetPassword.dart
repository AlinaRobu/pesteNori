import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:peste_nori/views/Login/LoginScreen.dart';
import '../StartupTemplate.dart';
import 'package:peste_nori/globals.dart';

class ConfirmResetPassword extends StartupTemplate {
  final String email;
  const ConfirmResetPassword({super.key, required this.email});

  @override
  _ConfirmResetPassword createState() => _ConfirmResetPassword(email);
}

class _ConfirmResetPassword extends StartupStateTemplate {
 _ConfirmResetPassword(this.email);

  final String email;
  final TextEditingController myCodeCtrl = TextEditingController();
  final TextEditingController myPswCtrl = TextEditingController();
  bool obscurePassword = true;

  @override
  bool get showSocialButtons => false;

  @override
  double get widgetsTop => 100;
  @override
  String get imageBackground => "assets/loginBackground.jpg";

  @override
  void dispose() {
    myCodeCtrl.dispose();
    myPswCtrl.dispose();
    super.dispose();
  }

  @override
  Widget topWidgets(BuildContext context) {
    return Column(
      children: [
        Text(
          translations.addEmailCode + '.',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 14),

        buildTextField(
          controller: myCodeCtrl,
          hint: translations.code,
          icon: null,
        ),
        const SizedBox(height: 14),

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

        SizedBox(
          width: double.infinity,
          height: 35,
          child: ElevatedButton(
            onPressed: () => confirmPasswordReset(context),
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
                  translations.passReset,
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
      
        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          height: 35,
          child: ElevatedButton(
            onPressed: () => _resetPassword(context),
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
                  translations.sendAgain,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget bottomWidgets(BuildContext context){
    return SizedBox();
  }
/// -----------------------PRIVATE METHODS -----------------------------///
  Future<void> confirmPasswordReset(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    try {
      await myCtrl.confirmPasswordReset(myCodeCtrl.text, myPswCtrl.text);

      if (!context.mounted) return;

      showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(translations.forgotPass),
        content: Text(translations.passReset),
        actions: [
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LoginScreen(),
              ),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;

      showError(context, e);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  } 

  Future<void> _resetPassword(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    try {
      await myCtrl.resetPassword(email);

      if (!context.mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(translations.passReset),
          content: Text('${translations.emailSent}: ${email}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;

      showError(context, e);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}