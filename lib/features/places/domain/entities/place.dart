class Place {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
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
}
