import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/services/log_service.dart';

import '../../../categories/data/repositories/category_repository_impl.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/domain/usecases/get_categories_usecase.dart';
import '../../../categories/presentation/widgets/category_card.dart';
import '../../../categories/presentation/widgets/category_card_shimmer.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../places/data/repositories/place_repository_impl.dart';
import '../../../places/domain/entities/place.dart';
import '../../../places/domain/usecases/get_popular_places_usecase.dart';
import '../../../places/presentation/widgets/place_card.dart';
import '../../../places/presentation/widgets/place_card_shimmer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GetCategoriesUseCase _getCategoriesUseCase =
      GetCategoriesUseCase(CategoryRepositoryImpl());
  final GetPopularPlacesUseCase _getPopularPlacesUseCase =
      GetPopularPlacesUseCase(PlaceRepositoryImpl());

  List<Category> _categories = [];
  List<Place> _popularPlaces = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    LogService.info('HomePage', 'Home page initialized');
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final sw = Stopwatch()..start();
    try {
      LogService.info(
          'HomePage', 'Loading categories and popular places started');

      setState(() {
        _isLoading = true;
        _error = null;
      });

      final results = await Future.wait([
        _getCategoriesUseCase.call(),
        _getPopularPlacesUseCase.call(),
      ]);

      setState(() {
        _categories = results[0] as List<Category>;
        _popularPlaces = results[1] as List<Place>;
        _isLoading = false;
      });

      sw.stop();
      LogService.info('HomePage', 'Data loading completed successfully', data: {
        'categoriesCount': _categories.length,
        'popularPlacesCount': _popularPlaces.length,
        'elapsedMs': sw.elapsedMilliseconds,
      });
    } catch (e) {
      sw.stop();
      LogService.error('HomePage', 'Data loading failed', error: e, data: {
        'elapsedMs': sw.elapsedMilliseconds,
      });
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Toshkent Guide'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadCategories,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search field
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).dividerColor.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Diqqatga sazovor joylarni qidiring...',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_isLoading) ...[
                // Categories shimmer
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Toifalar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Categories shimmer row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(4, (index) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: const CategoryCardShimmer(),
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 24),

                // Popular places shimmer
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Mashhur joylar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Popular places shimmer grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: 8,
                    itemBuilder: (context, index) {
                      return const PlaceCardShimmer();
                    },
                  ),
                ),
              ] else if (_error != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Ma\'lumotlarni yuklashda xatolik',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadCategories,
                          child: const Text('Qayta urinib ko\'ring'),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                // Categories section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Toifalar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Categories horizontal row
                if (_categories.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _categories.map((category) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: CategoryCard(
                              category: category,
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  AppRoutes.placesByCategory,
                                  arguments: category,
                                );
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                const SizedBox(height: 24),

                // Popular places section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Mashhur joylar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Popular places grid
                if (_popularPlaces.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: math.min(_popularPlaces.length, 8),
                      itemBuilder: (context, index) {
                        final place = _popularPlaces[index];
                        return PlaceCard(
                          place: place,
                        );
                      },
                    ),
                  )
                else
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'Mashhur joylar topilmadi',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
