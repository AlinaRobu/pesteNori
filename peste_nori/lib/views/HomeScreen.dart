import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
 _HomeScreenState();

  bool isLoading = false;

  double get widgetsTop => 100;
  String get imageBackground => "assets/appBackground.png";

  void dispose() {
    super.dispose();
  }

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
                           
                          ))))
            ]),
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