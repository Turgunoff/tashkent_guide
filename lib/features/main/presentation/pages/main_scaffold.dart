import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/services/log_service.dart';

import '../../../home/presentation/pages/home_page.dart';
import '../../../places/presentation/pages/places_page.dart';
import '../../../favorites/presentation/pages/favorites_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _pages = const <Widget>[
    HomePage(),
    PlacesPage(),
    FavoritesPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    LogService.info('MainScaffold', 'Building main scaffold');
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFE5E5E5), width: 0.5),
          ),
        ),
        child: NavigationBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          selectedIndex: _currentIndex,
          onDestinationSelected: (int newIndex) {
            LogService.info('MainScaffold', 'Navigation tab changed', data: {
              'fromIndex': _currentIndex,
              'toIndex': newIndex,
            });
            setState(() => _currentIndex = newIndex);
          },
          destinations: const <NavigationDestination>[
            NavigationDestination(
              icon: Icon(Iconsax.home),
              selectedIcon: Icon(Iconsax.home),
              label: 'Bosh sahifa',
            ),
            NavigationDestination(
              icon: Icon(Iconsax.location),
              selectedIcon: Icon(Iconsax.location),
              label: 'Joylar',
            ),
            NavigationDestination(
              icon: Icon(Iconsax.heart),
              selectedIcon: Icon(Iconsax.heart),
              label: 'Sevimlilar',
            ),
            NavigationDestination(
              icon: Icon(Iconsax.setting_2),
              selectedIcon: Icon(Iconsax.setting_2),
              label: 'Sozlamalar',
            ),
          ],
        ),
      ),
    );
  }
}
