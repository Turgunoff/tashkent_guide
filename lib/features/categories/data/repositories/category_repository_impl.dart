import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  // Statik test ma'lumotlari
  static final List<Category> _categories = [
    Category(
      id: '1',
      name: 'Tarixiy Joylar',
      iconUrl: null,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    Category(
      id: '2',
      name: 'Muzeylar',
      iconUrl: null,
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
    ),
    Category(
      id: '3',
      name: 'Bog\'lar',
      iconUrl: null,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    Category(
      id: '4',
      name: 'Restoran va Kafeler',
      iconUrl: null,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];

  @override
  Future<List<Category>> getCategories() async {
    // API chaqiruvini simulyatsiya qilish uchun kichik kechikish
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_categories);
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }
}
