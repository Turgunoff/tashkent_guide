import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import 'log_service.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    final sw = Stopwatch()..start();
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
      );
      sw.stop();
      LogService.info('Supabase', 'Initialized', data: {
        'elapsedMs': sw.elapsedMilliseconds,
        'url': SupabaseConfig.url,
      });
    } catch (e, st) {
      sw.stop();
      LogService.error('Supabase', 'Initialization failed',
          error: e,
          stackTrace: st,
          data: {
            'elapsedMs': sw.elapsedMilliseconds,
          });
      rethrow;
    }
  }

  // Auth methods
  static User? get currentUser => client.auth.currentUser;
  static bool get isAuthenticated => currentUser != null;

  // Database methods
  static SupabaseQueryBuilder from(String table) => client.from(table);

  // Storage methods
  static SupabaseStorageClient get storage => client.storage;
}
