import '../entities/place.dart';
import '../repositories/place_repository.dart';

class GetPlacesByCategoryUseCase {
  final PlaceRepository repository;

  const GetPlacesByCategoryUseCase(this.repository);

  Future<List<Place>> call(String categoryId) async {
    return await repository.getPlacesByCategory(categoryId);
  }
}
