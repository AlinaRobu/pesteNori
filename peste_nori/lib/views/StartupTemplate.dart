import 'package:flutter/material.dart';
import 'dart:ui';
import 'HomeScreen.dart';
import '../controllers/AppLoginCtrl.dart';

abstract class StartupTemplate extends StatefulWidget {
  const StartupTemplate({Key? key}) : super(key: key);
}

abstract class StartupStateTemplate extends State<StartupTemplate> {
  double get widgetsTop => 320;
  String get imageBackground => "assets/appBackground.jpg";
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
                                        height: 250,
                                        image: AssetImage(
                                            'assets/pesteNori_logo.png'),
                                        fit: BoxFit.fill),
                                    SizedBox(height: widgetsTop),
                                    getPageWidgets(context)
                                  ]),
                            ),
                          ),
                        ))))
          ]),
    );
  }

  Widget buildEmailForm(BuildContext context);

  Widget getPageWidgets(BuildContext context){
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 50, right: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildEmailForm(context),

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

            const SizedBox(height: 15),

            buildGoogleButton(context),

            const SizedBox(height: 15),

            buildFacebookButton(context)
          ],
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
