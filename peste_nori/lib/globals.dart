import 'package:firebase_auth/firebase_auth.dart';
import 'utils/ThemeNotifier.dart';
import 'utils/LocaleNotifier.dart';
import 'package:flutter/cupertino.dart';


User? currentUser;
var translations;
ThemeNotifier themeNotifier = ThemeNotifier();
final localeNotifier = LocaleNotifier();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
Map<String, dynamic> userData = {"peaks": [], "cabins": [], "collections": []};

