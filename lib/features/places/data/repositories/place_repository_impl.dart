import '../../../../core/services/supabase_service.dart';
import '../../domain/entities/place.dart';
import '../../domain/repositories/place_repository.dart';
import '../models/place_model.dart';
import '../../../../core/services/log_service.dart';

class PlaceRepositoryImpl implements PlaceRepository {
  static const String _table = 'places';
  static final RegExp _uuidRegex = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  @override
  Future<List<Place>> getPlaces() async {
    final sw = Stopwatch()..start();
    try {
      LogService.info('PlacesRepo', 'getPlaces started');

      final response = await SupabaseService.from(_table)
          .select()
          .order('created_at', ascending: false);

      final items = (response as List)
          .map((e) => PlaceModel.fromJson(e as Map<String, dynamic>).toEntity())
          .toList();

      sw.stop();
      LogService.info('PlacesRepo', 'getPlaces success', data: {
        'count': items.length,
        'elapsedMs': sw.elapsedMilliseconds,
      });
      return items;
    } catch (e, st) {
      sw.stop();
      LogService.error('PlacesRepo', 'getPlaces failed',
          error: e,
          stackTrace: st,
          data: {
            'elapsedMs': sw.elapsedMilliseconds,
          });
      rethrow;
    }
  }

  @override
  Future<List<Place>> getPlacesByCategory(String categoryId) async {
    final sw = Stopwatch()..start();
    try {
      LogService.info('PlacesRepo', 'getPlacesByCategory started', data: {
        'categoryId': categoryId,
      });

      if (!_uuidRegex.hasMatch(categoryId)) {
        LogService.warn('PlacesRepo', 'Invalid categoryId format', data: {
          'categoryId': categoryId,
        });
        return <Place>[];
      }

      final response = await SupabaseService.from(_table)
          .select()
          .eq('category_id', categoryId)
          .order('created_at', ascending: false);

      final items = (response as List)
          .map((e) => PlaceModel.fromJson(e as Map<String, dynamic>).toEntity())
          .toList();

      sw.stop();
      LogService.info('PlacesRepo', 'getPlacesByCategory success', data: {
        'categoryId': categoryId,
        'count': items.length,
        'elapsedMs': sw.elapsedMilliseconds,
      });
      return items;
    } catch (e, st) {
      sw.stop();
      LogService.error('PlacesRepo', 'getPlacesByCategory failed',
          error: e,
          stackTrace: st,
          data: {
            'categoryId': categoryId,
            'elapsedMs': sw.elapsedMilliseconds,
          });
      rethrow;
    }
  }

  @override
  Future<List<Place>> getPopularPlaces() async {
    final sw = Stopwatch()..start();
    try {
      LogService.info('PlacesRepo', 'getPopularPlaces started');

      final response = await SupabaseService.from(_table)
          .select()
          .gte('rating', 4.5)
          .order('rating', ascending: false)
          .limit(8);

      final items = (response as List)
          .map((e) => PlaceModel.fromJson(e as Map<String, dynamic>).toEntity())
          .toList();

      sw.stop();
      LogService.info('PlacesRepo', 'getPopularPlaces success', data: {
        'count': items.length,
        'elapsedMs': sw.elapsedMilliseconds,
        'minRating': 4.5,
      });
      return items;
    } catch (e, st) {
      sw.stop();
      LogService.error('PlacesRepo', 'getPopularPlaces failed',
          error: e,
          stackTrace: st,
          data: {
            'elapsedMs': sw.elapsedMilliseconds,
          });
      rethrow;
    }
  }

  @override
  Future<Place?> getPlaceById(String id) async {
    final sw = Stopwatch()..start();
    try {
      LogService.info('PlacesRepo', 'getPlaceById started', data: {
        'id': id,
      });

      final response = await SupabaseService.from(_table)
          .select()
          .eq('id', id)
          .maybeSingle();

      sw.stop();
      if (response == null) {
        LogService.warn('PlacesRepo', 'getPlaceById not found', data: {
          'id': id,
          'elapsedMs': sw.elapsedMilliseconds,
        });
        return null;
      }

      final item = PlaceModel.fromJson(response).toEntity();
      LogService.info('PlacesRepo', 'getPlaceById success', data: {
        'id': id,
        'elapsedMs': sw.elapsedMilliseconds,
      });
      return item;
    } catch (e, st) {
      sw.stop();
      LogService.error('PlacesRepo', 'getPlaceById failed',
          error: e,
          stackTrace: st,
          data: {
            'id': id,
            'elapsedMs': sw.elapsedMilliseconds,
          });
      rethrow;
    }
  }

  @override
  Future<List<Place>> searchPlaces(String query) async {
    final sw = Stopwatch()..start();
    try {
      LogService.info('PlacesRepo', 'searchPlaces started', data: {
        'query': query,
      });

      final response = await SupabaseService.from(_table)
          .select()
          .or('name.ilike.%$query%,details.ilike.%$query%,address.ilike.%$query%')
          .order('created_at', ascending: false);

      final items = (response as List)
          .map((e) => PlaceModel.fromJson(e as Map<String, dynamic>).toEntity())
          .toList();

      sw.stop();
      LogService.info('PlacesRepo', 'searchPlaces success', data: {
        'query': query,
        'count': items.length,
        'elapsedMs': sw.elapsedMilliseconds,
      });
      return items;
    } catch (e, st) {
      sw.stop();
      LogService.error('PlacesRepo', 'searchPlaces failed',
          error: e,
          stackTrace: st,
          data: {
            'query': query,
            'elapsedMs': sw.elapsedMilliseconds,
          });
      rethrow;
    }
  }
}
