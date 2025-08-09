class Category {
  final String id;
  final String name;
  final String? iconUrl;
  final DateTime createdAt;

  const Category({
    required this.id,
    required this.name,
    this.iconUrl,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Category(id: $id, name: $name, iconUrl: $iconUrl, createdAt: $createdAt)';
  }
}
