import 'package:flutter/material.dart';
import 'package:peste_nori/globals.dart';
import 'package:peste_nori/views/collections/CollectionsPage.dart';
import 'package:peste_nori/views/homePage/HomePage.dart';
import 'package:peste_nori/views/map/MapScreen.dart';
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

  static const _mapIndex = 1;
  int _selectedIndex = 0;
  bool _mapTabMounted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _mapTabMounted) return;
      setState(() => _mapTabMounted = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    translations = AppLocalizations.of(context);
    final showingMap = _selectedIndex == _mapIndex;
    final pages = [
      HomePage(),
      MapScreen(isVisible: showingMap),
      RoutesPage(),
      CollectionsPage(),
      ProfilePage(),
    ];
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (!showingMap)
            KeyedSubtree(
              key: ValueKey(_selectedIndex),
              child: pages[_selectedIndex],
            ),
          if (_mapTabMounted)
            Offstage(
              key: const ValueKey(_mapIndex),
              offstage: !showingMap,
              child: TickerMode(
                enabled: showingMap,
                child: pages[_mapIndex],
              ),
            ),
        ],
      ),
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
          if (index == _mapIndex) _mapTabMounted = true;
        });
      },
      selectedItemColor: const Color(0xFFD4AF37),
      unselectedItemColor: Colors.blueGrey,
      backgroundColor: const Color.fromARGB(255, 9, 10, 18),
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
