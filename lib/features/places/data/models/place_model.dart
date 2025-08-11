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

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? images = json['images'] as List<dynamic>?;
    final String? firstImage =
        (images != null && images.isNotEmpty) ? images.first as String : null;

    return PlaceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['details'] as String?,
      imageUrl: firstImage,
      address: json['address'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      rating: _parseDouble(json['rating']),
      categoryId: json['category_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'details': description,
      // Keep only the primary image in this mapping
      'images': imageUrl != null ? [imageUrl] : [],
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
