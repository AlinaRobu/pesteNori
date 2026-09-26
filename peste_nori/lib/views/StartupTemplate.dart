import 'package:flutter/material.dart';
import 'dart:ui';
import 'MainAppScreen.dart';

abstract class StartupTemplate extends StatefulWidget {
  const StartupTemplate({Key? key}) : super(key: key);
}

abstract class StartupStateTemplate extends State<StartupTemplate> {
  double get widgetsTop => 320;
  String get imageBackground => "assets/appBackground.jpg";

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

  Widget getPageWidgets(BuildContext context);

  void openApplication(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MainAppScreen(),
      ),
    );
  }
}