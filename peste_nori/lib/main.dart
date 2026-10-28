import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '/l10n/app_localizations.dart';
import 'package:device_preview/device_preview.dart';
import 'package:overlay_support/overlay_support.dart';

import 'package:peste_nori/views/StartupScreen.dart';
import 'package:peste_nori/services/AuthService.dart';
import '/views/HomeScreen.dart';
import 'utils/ThemeNotifier.dart';
import 'package:peste_nori/globals.dart';

Future<void> main() async {
  //WidgetsFlutterBinding.ensureInitialized();
  DevicePreview.enable(enabled: !kReleaseMode);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    providerAndroid: kDebugMode
        ? const AndroidDebugProvider()
        : const AndroidPlayIntegrityProvider(),
    providerApple: kDebugMode
        ? const AppleDebugProvider()
        : const AppleAppAttestProvider(),
  );
  
  await themeNotifier.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, _) {
        return OverlaySupport(
          child: MaterialApp(
            title: "PESTE NORI",
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeMode,
            navigatorKey: navigatorKey,
            home: StreamBuilder<User?>(
              stream: AuthService().authStateChanges,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                AuthService().getIfLoggedIn();
                return snapshot.data == null ? const StartupScreen() : const HomeScreen();
              },
            ),
          ),
        );
      },
    );
  }
}