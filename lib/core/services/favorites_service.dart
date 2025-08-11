import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/places/data/models/place_model.dart';
import 'log_service.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorite_places';
  static FavoritesService? _instance;

  FavoritesService._();

  static Future<FavoritesService> getInstance() async {
    if (_instance == null) {
      _instance = FavoritesService._();
    }
    return _instance!;
  }

  /// Get all favorite places
  Future<List<PlaceModel>> getFavoritePlaces() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];
      
      final favorites = favoritesJson
          .map((json) => PlaceModel.fromJson(jsonDecode(json)))
          .toList();
      
      LogService.info('FavoritesService', 'Retrieved favorite places', data: {
        'count': favorites.length,
      });
      
      return favorites;
    } catch (e) {
      LogService.error('FavoritesService', 'Failed to get favorite places', error: e);
      return [];
    }
  }

  /// Add a place to favorites
  Future<bool> addToFavorites(PlaceModel place) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];
      
      // Check if already in favorites
      if (favoritesJson.any((json) {
        final placeData = jsonDecode(json);
        return placeData['id'] == place.id;
      })) {
        LogService.info('FavoritesService', 'Place already in favorites', data: {
          'placeId': place.id,
          'placeName': place.name,
        });
        return true;
      }
      
      // Add to favorites
      final placeJson = jsonEncode(place.toJson());
      favoritesJson.add(placeJson);
      
      final success = await prefs.setStringList(_favoritesKey, favoritesJson);
      
      if (success) {
        LogService.info('FavoritesService', 'Place added to favorites', data: {
          'placeId': place.id,
          'placeName': place.name,
        });
      }
      
      return success;
    } catch (e) {
      LogService.error('FavoritesService', 'Failed to add place to favorites', error: e);
      return false;
    }
  }

  /// Remove a place from favorites
  Future<bool> removeFromFavorites(String placeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];
      
      // Remove from favorites
      favoritesJson.removeWhere((json) {
        final placeData = jsonDecode(json);
        return placeData['id'] == placeId;
      });
      
      final success = await prefs.setStringList(_favoritesKey, favoritesJson);
      
      if (success) {
        LogService.info('FavoritesService', 'Place removed from favorites', data: {
          'placeId': placeId,
        });
      }
      
      return success;
    } catch (e) {
      LogService.error('FavoritesService', 'Failed to remove place from favorites', error: e);
      return false;
    }
  }

  /// Check if a place is in favorites
  Future<bool> isFavorite(String placeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];
      
      return favoritesJson.any((json) {
        final placeData = jsonDecode(json);
        return placeData['id'] == placeId;
      });
    } catch (e) {
      LogService.error('FavoritesService', 'Failed to check if place is favorite', error: e);
      return false;
    }
  }

  /// Toggle favorite status
  Future<bool> toggleFavorite(PlaceModel place) async {
    try {
      final isFav = await isFavorite(place.id);
      
      if (isFav) {
        return await removeFromFavorites(place.id);
      } else {
        return await addToFavorites(place);
      }
    } catch (e) {
      LogService.error('FavoritesService', 'Failed to toggle favorite', error: e);
      return false;
    }
  }

  /// Get favorite count
  Future<int> getFavoriteCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];
      return favoritesJson.length;
    } catch (e) {
      LogService.error('FavoritesService', 'Failed to get favorite count', error: e);
      return 0;
    }
  }

  /// Clear all favorites
  Future<bool> clearAllFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.remove(_favoritesKey);
      
      if (success) {
        LogService.info('FavoritesService', 'All favorites cleared');
      }
      
      return success;
    } catch (e) {
      LogService.error('FavoritesService', 'Failed to clear all favorites', error: e);
      return false;
    }
  }
}
