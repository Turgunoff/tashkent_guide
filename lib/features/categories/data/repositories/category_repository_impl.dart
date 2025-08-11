import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/log_service.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  static const String _table = 'categories';

  @override
  Future<List<Category>> getCategories() async {
    final sw = Stopwatch()..start();
    try {
      LogService.info('CategoriesRepo', 'getCategories started');
      
      final response = await SupabaseService.from(_table)
          .select()
          .order('created_at', ascending: true);
      
      final items = (response as List)
          .map(
              (e) => CategoryModel.fromJson(e as Map<String, dynamic>).toEntity())
          .toList();
      
      sw.stop();
      LogService.info('CategoriesRepo', 'getCategories success', data: {
        'count': items.length,
        'elapsedMs': sw.elapsedMilliseconds,
      });
      return items;
    } catch (e, st) {
      sw.stop();
      LogService.error('CategoriesRepo', 'getCategories failed',
          error: e, stackTrace: st, data: {
        'elapsedMs': sw.elapsedMilliseconds,
      });
      rethrow;
    }
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    final sw = Stopwatch()..start();
    try {
      LogService.info('CategoriesRepo', 'getCategoryById started', data: {
        'id': id,
      });
      
      final response =
          await SupabaseService.from(_table).select().eq('id', id).maybeSingle();
      
      sw.stop();
      if (response == null) {
        LogService.warn('CategoriesRepo', 'getCategoryById not found', data: {
          'id': id,
          'elapsedMs': sw.elapsedMilliseconds,
        });
        return null;
      }
      
      final item = CategoryModel.fromJson(response).toEntity();
      LogService.info('CategoriesRepo', 'getCategoryById success', data: {
        'id': id,
        'elapsedMs': sw.elapsedMilliseconds,
      });
      return item;
    } catch (e, st) {
      sw.stop();
      LogService.error('CategoriesRepo', 'getCategoryById failed',
          error: e, stackTrace: st, data: {
        'id': id,
        'elapsedMs': sw.elapsedMilliseconds,
      });
      rethrow;
    }
  }
}
