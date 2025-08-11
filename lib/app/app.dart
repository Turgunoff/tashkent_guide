import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/services/log_service.dart';
import '../core/services/theme_service.dart';
import 'routes/app_routes.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    LogService.info('App', 'Building MaterialApp');
    return AnimatedBuilder(
      animation: ThemeService.instance,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Toshkent Guide',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeService.instance.themeMode,
          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRouter.onGenerateRoute,
        );
      },
    );
  }
}
