import 'package:flutter/material.dart';
import '../StartupTemplate.dart';
import 'ConfirmResetPassword.dart';

class ResetPassword extends StartupTemplate {
  const ResetPassword({super.key});

  @override
  _ResetPassword createState() => _ResetPassword();
}

class _ResetPassword extends StartupStateTemplate {
 _ResetPassword();

  final TextEditingController myUsrCtrl = TextEditingController();

  @override
  double get widgetsTop => 100;
  @override
  String get imageBackground => "assets/loginBackground.jpg";

  @override
  void dispose() {
    myUsrCtrl.dispose();
    super.dispose();
  }

  @override
  Widget topWidgets(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Introduceti adresa de email pentru a reseta parola.',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 14),

        // EMAIL
        buildTextField(
          controller: myUsrCtrl,
          hint: 'Email',
          icon: Icons.email_outlined,
        ),
        const SizedBox(height: 14),
        
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
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Trimite mail',
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
      ],
    );
  }

  @override
  Widget bottomWidgets(BuildContext context){
    return SizedBox();
  }
/// -----------------------PRIVATE METHODS -----------------------------///
  Future<void> _resetPassword(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    try {
      await myCtrl.resetPassword(myUsrCtrl.text.trim());

      if (!context.mounted) return;

      showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset password'),
        content: Text('A fost trimis un link de resetare a parolei pe adresa de email: ${myUsrCtrl.text}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
      // alinarobu@rocketmail.com

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