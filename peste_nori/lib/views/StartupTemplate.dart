import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:io' show Platform;
import 'HomeScreen.dart';
import '../controllers/AppLoginCtrl.dart';

abstract class StartupTemplate extends StatefulWidget {
  const StartupTemplate({Key? key}) : super(key: key);
}

abstract class StartupStateTemplate extends State<StartupTemplate> {
  bool get showSocialButtons => true;
  double get widgetsTop => 320;
  String get imageBackground => "assets/startBackground.jpg";
  bool isLoading = false;
  final AppLoginCtrl myCtrl = AppLoginCtrl();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
          // This makes each child fill the full width of the screen
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
                child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Container(
                        alignment: Alignment.topCenter,
                        constraints: BoxConstraints(
                            minHeight: MediaQuery.of(context).size.height),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(imageBackground),
                            fit: BoxFit.cover,
                            opacity: 0.8
                          ),
                        ),
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: BackdropFilter(
                            filter:
                                ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
                            child: Center(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Image(
                                      height: 200,
                                      image: AssetImage(
                                          'assets/pesteNori_logo.png'),
                                      fit: BoxFit.fill),
                                      const Text(
                                        'Colecționează experiențe.\nDescoperă munții.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          height: 1.35,
                                          fontFamily: 'Calibri',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    SizedBox(height: widgetsTop),
                                    getPageWidgets(context)
                                  ]),
                            ),
                          ),
                        ))))
          ]),
    );
  }

  Widget getPageWidgets(BuildContext context){
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 50, right: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            topWidgets(context),

            const SizedBox(height: 15),

            if(showSocialButtons)...[
              // OR separator
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.white38,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'SAU',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // Google / Apple login
              _socialButton(
                icon: Platform.isIOS ?  const Icon(
                  Icons.apple,
                  color: Colors.white,
                  size: 27,
                ) : const Text(
                    'G',
                    style: TextStyle(
                      color: Color(0xFF4285F4),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                text: Platform.isIOS ? 'Continuă cu Apple' : 'Continuă cu Google',
                onPressed: Platform.isIOS ?  myCtrl.signInWithApple : myCtrl.signInWithGoogle
              ),
          
              const SizedBox(height: 15),

              buildFacebookButton(context),
            ],

            bottomWidgets(context)
          ],
        ),
      ),
    );
  }

  Widget bottomWidgets(BuildContext context);

  Widget topWidgets(BuildContext context);

  Widget buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 38, 53, 85).withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: TextField(
        textAlignVertical: TextAlignVertical.center,
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(
            color: Colors.white70,
            fontSize: 17,
          ),
          prefixIcon: icon != null ? Icon(
            icon,
            color: Colors.white70,
            size: 27,
          ): SizedBox(width: 0),
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 0,
          ),
        ),
      ),
    );
  }

  void openApplication(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(),
      ),
    );
  }

  Widget buildGoogleButton(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 220,
        height: 45,
        child: OutlinedButton(
          onPressed: isLoading
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

  Widget buildFacebookButton(BuildContext context){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OutlinedButton(
            onPressed: isLoading
                ? null
                : _signInWithFacebook,
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1877F2),
              side: const BorderSide(
                color: Color(0xFFD1D5DB),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1877F2),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'f',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Continua cu Facebook',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          )
        ]
    );
  }

  void showError(BuildContext context, Object error) {
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

  /// -----------------------PRIVATE METHODS -----------------------------///
  Widget _socialButton({required Widget icon, required String text, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 38, 53, 85).withOpacity(0.9),
          foregroundColor: Colors.white,
          side: const BorderSide(
            color: Colors.white54,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 35,
              child: Center(child: icon),
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loginWithGoogle(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    try {
      await myCtrl.signInWithGoogle();

      if (!context.mounted) return;

      // Google authentication succeeded.
      // Navigate to your application here if needed.
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

  Future<void> _signInWithFacebook() async {
    setState(() {
      isLoading = true;
    });

    try {
      await myCtrl.signInWithFacebook();

      if (!context.mounted) return;

      // Google authentication succeeded.
      // Navigate to your application here if needed.
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
