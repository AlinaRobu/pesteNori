import 'package:flutter/material.dart';
import 'StartupTemplate.dart';


class MainAppScreen extends StartupTemplate {
  const MainAppScreen({super.key});

  @override
  _MainAppScreen createState() => _MainAppScreen();
}

class _MainAppScreen extends StartupStateTemplate {
 _MainAppScreen();

  bool _isLoading = false;

  @override
  double get widgetsTop => 100;
  @override
  String get imageBackground => "assets/backgroundCollors.png";

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget getPageWidgets(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 50, right: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 15)
          ],
        ),
      ),
    );
  }

  void _showError(BuildContext context, Object error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
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
}