import '../entities/place.dart';
import '../repositories/place_repository.dart';

class GetPopularPlacesUseCase {
  final PlaceRepository repository;

  const GetPopularPlacesUseCase(this.repository);

  Future<List<Place>> call() async {
    return await repository.getPopularPlaces();
  }
}
