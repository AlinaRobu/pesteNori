import 'package:flutter/material.dart';
import 'package:peste_nori/globals.dart';
import 'package:peste_nori/views/collections/CollectionsPage.dart';
import 'package:peste_nori/views/homePage/HomePage.dart';
import 'package:peste_nori/views/map/MapPage.dart';
import 'package:peste_nori/views/profile/ProfilePage.dart';
import 'package:peste_nori/views/routes/RoutesPage.dart';

import 'package:peste_nori/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  HomeScreenState();

  double get widgetsTop => 100;

  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    MapPage(),
    RoutesPage(),
    CollectionsPage(),
    ProfilePage()
  ];


  @override
  Widget build(BuildContext context) {
    translations = AppLocalizations.of(context);
    return Scaffold(
      body: _pages[_selectedIndex],
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: _getBottomButtons(),
    );
  }

  ///--------------------------PRIVATE METHOD-----------------------///
  Widget _getBottomButtons() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      selectedItemColor: const Color(0xFFD4AF37),
      unselectedItemColor: Colors.blueGrey,
      backgroundColor: const Color.fromARGB(255, 18, 9, 9),
      showUnselectedLabels: true,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: translations.home),
        BottomNavigationBarItem(icon: Icon(Icons.map_rounded), label: translations.map),
        BottomNavigationBarItem(icon: Icon(Icons.route_rounded), label: translations.routes),
        BottomNavigationBarItem(icon: Icon(Icons.collections_bookmark_rounded), label: translations.collections),
        BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: translations.profile),
      ],
    );
  }
}
