import '../../domain/entities/place.dart';
import '../../domain/repositories/place_repository.dart';

class PlaceRepositoryImpl implements PlaceRepository {
  // Statik test ma'lumotlari
  static final List<Place> _places = [
    Place(
      id: '1',
      name: 'Hazrati Imam',
      description: 'Toshkentning eng qadimgi va muhim diniy markazlaridan biri',
      imageUrl:
          'https://images.unsplash.com/photo-1564769625905-50fa2ad26c92?w=400&h=300&fit=crop',
      address: 'Ko\'kcha dahasi',
      latitude: 41.3275,
      longitude: 69.2401,
      rating: 4.8,
      categoryId: '1', // Tarixiy joylar
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    Place(
      id: '2',
      name: 'Chorsu Bozori',
      description: 'Toshkentning eng mashhur va qadimgi bozori',
      imageUrl:
          'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
      address: 'Eski shahar',
      latitude: 41.3293,
      longitude: 69.2348,
      rating: 4.6,
      categoryId: '4', // Restoran va kafeler
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
    Place(
      id: '3',
      name: 'Toshkent Minorasi',
      description: 'Zamonaviy Toshkentning ramzi',
      imageUrl:
          'https://images.unsplash.com/photo-1554072675-66db59dba46f?w=400&h=300&fit=crop',
      address: 'Yunusobod',
      latitude: 41.3775,
      longitude: 69.2897,
      rating: 4.7,
      categoryId: '1', // Tarixiy joylar
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
    Place(
      id: '4',
      name: 'Amir Temur Xiyoboni',
      description: 'Shahar markazidagi go\'zal bog\' va monument',
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=300&fit=crop',
      address: 'Shahar markazi',
      latitude: 41.3111,
      longitude: 69.2797,
      rating: 4.9,
      categoryId: '3', // Bog'lar
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    Place(
      id: '5',
      name: 'Alisher Navoiy Opera Teatri',
      description: 'Markaziy Osiyodagi eng katta opera teatri',
      imageUrl:
          'https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=400&h=300&fit=crop',
      address: 'Navoiy ko\'chasi',
      latitude: 41.3119,
      longitude: 69.2728,
      rating: 4.7,
      categoryId: '2', // Muzeylar
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Place(
      id: '6',
      name: 'Kukeldash Madrasasi',
      description: 'XVI asrda qurilgan tarixiy madrasalar',
      imageUrl:
          'https://images.unsplash.com/photo-1609137144002-f4819c8f6b93?w=400&h=300&fit=crop',
      address: 'Registon maydoni',
      latitude: 41.3275,
      longitude: 69.2401,
      rating: 4.5,
      categoryId: '1', // Tarixiy joylar
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  @override
  Future<List<Place>> getPlaces() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return List.from(_places);
  }

  @override
  Future<List<Place>> getPlacesByCategory(String categoryId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _places.where((place) => place.categoryId == categoryId).toList();
  }

  @override
  Future<List<Place>> getPopularPlaces() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final popularPlaces =
        _places.where((place) => place.rating >= 4.5).toList();
    popularPlaces.sort((a, b) => b.rating.compareTo(a.rating));
    return popularPlaces.take(4).toList(); // Faqat 4 ta mashhur joy
  }

  @override
  Future<Place?> getPlaceById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _places.firstWhere((place) => place.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Place>> searchPlaces(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final lowerQuery = query.toLowerCase();
    return _places.where((place) {
      return place.name.toLowerCase().contains(lowerQuery) ||
          (place.description?.toLowerCase().contains(lowerQuery) ?? false) ||
          (place.address?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }
}
