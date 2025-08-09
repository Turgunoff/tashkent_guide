import '../entities/place.dart';

abstract class PlaceRepository {
  Future<List<Place>> getPlaces();
  Future<List<Place>> getPlacesByCategory(String categoryId);
  Future<List<Place>> getPopularPlaces();
  Future<Place?> getPlaceById(String id);
  Future<List<Place>> searchPlaces(String query);
}
