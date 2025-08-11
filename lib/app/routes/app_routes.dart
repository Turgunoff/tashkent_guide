import 'package:flutter/material.dart';

import '../../features/main/presentation/pages/main_scaffold.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/places/presentation/pages/places_by_category_page.dart';
import '../../features/places/presentation/pages/place_details_page.dart';
import '../../features/categories/domain/entities/category.dart';
import '../../features/places/domain/entities/place.dart';

class AppRoutes {
  static const String splash = '/';
  static const String main = '/main';
  static const String placesByCategory = '/placesByCategory';
  static const String placeDetails = '/placeDetails';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute<void>(
          builder: (_) => const SplashPage(),
          settings: settings,
        );
      case AppRoutes.main:
        return MaterialPageRoute<void>(
          builder: (_) => const MainScaffold(),
          settings: settings,
        );
      case AppRoutes.placesByCategory:
        final category = settings.arguments as Category;
        return MaterialPageRoute<void>(
          builder: (_) => PlacesByCategoryPage(category: category),
          settings: settings,
        );
      case AppRoutes.placeDetails:
        final place = settings.arguments as Place;
        return MaterialPageRoute<void>(
          builder: (_) => PlaceDetailsPage(place: place),
          settings: settings,
        );
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const SplashPage(),
          settings: settings,
        );
    }
  }
}
