import 'package:firebase_auth/firebase_auth.dart';
import 'utils/ThemeNotifier.dart';
import 'package:flutter/cupertino.dart';


User? currentUser;
var translations;
ThemeNotifier themeNotifier = ThemeNotifier();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


