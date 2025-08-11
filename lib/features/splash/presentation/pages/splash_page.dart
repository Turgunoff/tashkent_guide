import 'package:flutter/material.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/services/log_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    LogService.info('SplashPage', 'Splash page initialized');
    Future<void>.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      LogService.info('SplashPage', 'Navigating to main page');
      Navigator.of(context).pushReplacementNamed(AppRoutes.main);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.location_city_rounded, size: 88, color: primary),
            const SizedBox(height: 16),
            Text(
              'Toshkent Guide',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
