import '../../features/categories/domain/entities/category.dart';
import '../../features/places/domain/entities/place.dart';
import '../../features/categories/domain/usecases/get_categories_usecase.dart';
import '../../features/places/domain/usecases/get_popular_places_usecase.dart';
import '../../features/categories/data/repositories/category_repository_impl.dart';
import '../../features/places/data/repositories/place_repository_impl.dart';
import 'log_service.dart';

class HomeDataService {
  static HomeDataService? _instance;
  static HomeDataService get instance => _instance ??= HomeDataService._();

  HomeDataService._();

  final GetCategoriesUseCase _getCategoriesUseCase =
      GetCategoriesUseCase(CategoryRepositoryImpl());
  final GetPopularPlacesUseCase _getPopularPlacesUseCase =
      GetPopularPlacesUseCase(PlaceRepositoryImpl());

  List<Category>? _cachedCategories;
  List<Place>? _cachedPopularPlaces;
  bool _isLoading = false;
  String? _lastError;
  DateTime? _lastLoadTime;

  // Cache duration - data is considered fresh for 5 minutes
  static const Duration _cacheDuration = Duration(minutes: 5);

  /// Get cached data if available and fresh, otherwise load from repository
  Future<Map<String, dynamic>> getData({bool forceRefresh = false}) async {
    // Check if we have fresh cached data and don't need to force refresh
    if (!forceRefresh && _hasFreshData()) {
      LogService.info('HomeDataService', 'Returning cached data', data: {
        'categoriesCount': _cachedCategories?.length ?? 0,
        'popularPlacesCount': _cachedPopularPlaces?.length ?? 0,
        'cacheAge': _lastLoadTime != null
            ? DateTime.now().difference(_lastLoadTime!).inSeconds
            : null,
      });

      return {
        'categories': _cachedCategories!,
        'popularPlaces': _cachedPopularPlaces!,
        'isFromCache': true,
      };
    }

    // Load fresh data
    return await _loadFreshData();
  }

  /// Check if cached data is fresh
  bool _hasFreshData() {
    if (_cachedCategories == null || _cachedPopularPlaces == null) {
      return false;
    }

    if (_lastLoadTime == null) {
      return false;
    }

    final age = DateTime.now().difference(_lastLoadTime!);
    return age < _cacheDuration;
  }

  /// Load fresh data from repositories
  Future<Map<String, dynamic>> _loadFreshData() async {
    if (_isLoading) {
      // If already loading, wait for the current operation to complete
      while (_isLoading) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Return cached data if available
      if (_cachedCategories != null && _cachedPopularPlaces != null) {
        return {
          'categories': _cachedCategories!,
          'popularPlaces': _cachedPopularPlaces!,
          'isFromCache': true,
        };
      }
    }

    _isLoading = true;
    final sw = Stopwatch()..start();

    try {
      LogService.info('HomeDataService', 'Loading fresh data started');

      final results = await Future.wait([
        _getCategoriesUseCase.call(),
        _getPopularPlacesUseCase.call(),
      ]);

      final categories = results[0] as List<Category>;
      final popularPlaces = results[1] as List<Place>;

      // Update cache
      _cachedCategories = categories;
      _cachedPopularPlaces = popularPlaces;
      _lastLoadTime = DateTime.now();
      _lastError = null;

      sw.stop();
      LogService.info('HomeDataService', 'Fresh data loaded successfully',
          data: {
            'categoriesCount': categories.length,
            'popularPlacesCount': popularPlaces.length,
            'elapsedMs': sw.elapsedMilliseconds,
          });

      return {
        'categories': categories,
        'popularPlaces': popularPlaces,
        'isFromCache': false,
      };
    } catch (e) {
      sw.stop();
      _lastError = e.toString();

      LogService.error('HomeDataService', 'Failed to load fresh data',
          error: e,
          data: {
            'elapsedMs': sw.elapsedMilliseconds,
          });

      // Return cached data if available, even if stale
      if (_cachedCategories != null && _cachedPopularPlaces != null) {
        LogService.info(
            'HomeDataService', 'Returning stale cached data due to error');
        return {
          'categories': _cachedCategories!,
          'popularPlaces': _cachedPopularPlaces!,
          'isFromCache': true,
          'isStale': true,
        };
      }

      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  /// Force refresh data (used by pull-to-refresh)
  Future<Map<String, dynamic>> forceRefresh() async {
    LogService.info('HomeDataService', 'Force refresh requested');
    return await getData(forceRefresh: true);
  }

  /// Clear cache
  void clearCache() {
    _cachedCategories = null;
    _cachedPopularPlaces = null;
    _lastLoadTime = null;
    _lastError = null;
    LogService.info('HomeDataService', 'Cache cleared');
  }

  /// Get cache status
  Map<String, dynamic> getCacheStatus() {
    return {
      'hasCategories': _cachedCategories != null,
      'hasPopularPlaces': _cachedPopularPlaces != null,
      'categoriesCount': _cachedCategories?.length ?? 0,
      'popularPlacesCount': _cachedPopularPlaces?.length ?? 0,
      'lastLoadTime': _lastLoadTime?.toIso8601String(),
      'isStale': _lastLoadTime != null &&
          DateTime.now().difference(_lastLoadTime!) > _cacheDuration,
      'lastError': _lastError,
    };
  }

  /// Check if data is currently loading
  bool get isLoading => _isLoading;
}
