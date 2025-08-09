import '../../domain/entities/place.dart';

class PlaceModel extends Place {
  const PlaceModel({
    required super.id,
    required super.name,
    super.description,
    super.imageUrl,
    super.address,
    super.latitude,
    super.longitude,
    required super.rating,
    required super.categoryId,
    required super.createdAt,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    return PlaceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      address: json['address'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      categoryId: json['category_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
      'category_id': categoryId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Place toEntity() {
    return Place(
      id: id,
      name: name,
      description: description,
      imageUrl: imageUrl,
      address: address,
      latitude: latitude,
      longitude: longitude,
      rating: rating,
      categoryId: categoryId,
      createdAt: createdAt,
    );
  }
}
