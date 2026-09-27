import 'package:flutter/material.dart';
import 'dart:ui';
import 'LoginScreen.dart';
import 'RegisterScreen.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({Key? key}) : super(key: key);

   @override
  _StartupScreen createState() => _StartupScreen();
}

class _StartupScreen extends State<StartupScreen> {
 _StartupScreen();

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
                              image: AssetImage("assets/appBackground.jpg"),
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
                                      SizedBox(height: 320),
                                      getPageWidgets(context)
                                    ]),
                              ),
                            ),
                          ))))
            ]),
    );  
  }

  getPageWidgets(BuildContext context){
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 50, right: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _loginButton(context),

            const SizedBox(height: 15),

            _registerButton(context)
          ],
        ),
      ),
    );
  }

  Widget _loginButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LoginScreen(),
          ),
        );
      },
      child: Ink(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color.fromARGB(255, 210, 173, 26),
              Color.fromARGB(255, 91, 72, 11),
            ],
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(80),
          ),
        ),
        child: Container(
          width: 200,
          height: 45,
          alignment: Alignment.center,
          child: const Text(
            'Conectează-te',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _registerButton(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 45,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shape: const StadiumBorder(),
          side: const BorderSide(
            width: 2,
            color: Color.fromARGB(255, 210, 149, 26),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RegisterScreen(),
            ),
          );
        },
        child: const Text(
          'Creează cont',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}