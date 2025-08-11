class Place {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final List<String> images;
  final String? address;
  final double? latitude;
  final double? longitude;
  final double rating;
  final String categoryId;
  final DateTime createdAt;

  const Place({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.images = const [],
    this.address,
    this.latitude,
    this.longitude,
    required this.rating,
    required this.categoryId,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Place && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Place(id: $id, name: $name, rating: $rating)';
  }

  /// Convert Place to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'images': images,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
      'categoryId': categoryId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create Place from JSON
  factory Place.fromJson(Map<String, dynamic> json) {
    final List<String> imagesList = [];
    if (json['images'] != null) {
      imagesList.addAll((json['images'] as List).cast<String>());
    }

    return Place(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      images: imagesList,
      address: json['address'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      rating: (json['rating'] as num).toDouble(),
      categoryId: json['categoryId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
