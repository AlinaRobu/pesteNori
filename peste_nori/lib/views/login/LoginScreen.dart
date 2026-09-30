import 'package:flutter/material.dart';
import '../StartupTemplate.dart';
import 'ResetPassword.dart';
import 'RegisterScreen.dart';

class LoginScreen extends StartupTemplate {
  const LoginScreen({super.key});

  @override
  _LoginScreen createState() => _LoginScreen();
}

class _LoginScreen extends StartupStateTemplate {
 _LoginScreen();

  final TextEditingController myUsrCtrl = TextEditingController();
  final TextEditingController myPswCtrl = TextEditingController();
  bool obscurePassword = true;

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
  Widget topWidgets(BuildContext context) {
    return Column(
      children: [
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
          hint: 'Parolă',
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

        const SizedBox(height: 20),

        // Email login
        SizedBox(
          width: double.infinity,
          height: 35,
          child: ElevatedButton(
            onPressed: () => _loginWithEmail(context),
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
                  'Login',
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

        GestureDetector(
          onTap: () {
             Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ResetPassword(),
              ),
            );
          },
          child: const Text(
            'Am uitat parola',
            style: TextStyle(
              color: Color(0xFF168BFF),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        
        const Text(
          'Nu ai cont? Nu-ti face griji!',
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
                builder: (_) => RegisterScreen(),
              ),
            );
          },
          child: const Text(
            'Poti crea rapid unul aici!',
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

  @override
  Widget bottomWidgets(BuildContext context){
    return SizedBox();
  }
/// -----------------------PRIVATE METHODS -----------------------------///
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