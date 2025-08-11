import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/services/supabase_service.dart';
import 'core/services/theme_service.dart';
import 'core/services/preferences_service.dart';
import 'core/services/log_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LogService.info('Main', 'Application starting');

  try {
    await SupabaseService.initialize();
    LogService.info('Main', 'Supabase initialized successfully');

    await ThemeService.instance.initialize();
    LogService.info('Main', 'Theme service initialized successfully');

    await PreferencesService.instance.initialize();
    LogService.info('Main', 'Preferences service initialized successfully');
  } catch (e, st) {
    LogService.error('Main', 'Failed to initialize services',
        error: e, stackTrace: st);
    rethrow;
  }

  LogService.info('Main', 'Running app');
  runApp(const App());
}
