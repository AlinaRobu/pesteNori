import 'package:flutter/material.dart';
import 'StartupTemplate.dart';
import 'dart:ui';
import 'LoginScreen.dart';
import 'RegisterScreen.dart';

class StartupScreen extends StartupTemplate {
  const StartupScreen({super.key});

  @override
  _StartupScreen createState() => _StartupScreen();
}

class _StartupScreen extends StartupStateTemplate {
 _StartupScreen();

  Widget getPageWidgets(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _loginButton(context),

            const SizedBox(height: 15),

            _registerButton(context),

            const SizedBox(height: 60),
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