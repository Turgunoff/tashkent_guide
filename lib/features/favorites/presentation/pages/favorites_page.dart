import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../places/data/models/place_model.dart';
import '../../../places/presentation/widgets/place_card.dart';
import '../../../../core/services/favorites_service.dart';
import '../../../../core/services/log_service.dart';
import '../../../../app/routes/app_routes.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late FavoritesService _favoritesService;
  List<PlaceModel> _favoritePlaces = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeFavorites();
  }

  Future<void> _initializeFavorites() async {
    try {
      _favoritesService = await FavoritesService.getInstance();
      await _loadFavorites();
    } catch (e) {
      LogService.error(
          'FavoritesPage', 'Failed to initialize favorites service',
          error: e);
      setState(() {
        _error = 'Sevimlilar xizmati ishga tushirishda xatolik';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFavorites() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final favorites = await _favoritesService.getFavoritePlaces();

      setState(() {
        _favoritePlaces = favorites;
        _isLoading = false;
      });

      LogService.info('FavoritesPage', 'Favorites loaded successfully', data: {
        'count': favorites.length,
      });
    } catch (e) {
      LogService.error('FavoritesPage', 'Failed to load favorites', error: e);
      setState(() {
        _error = 'Sevimlilarni yuklashda xatolik';
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFromFavorites(PlaceModel place) async {
    try {
      final success = await _favoritesService.removeFromFavorites(place.id);
      if (success) {
        setState(() {
          _favoritePlaces.removeWhere((p) => p.id == place.id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${place.name} sevimlilardan olib tashlandi'),
            action: SnackBarAction(
              label: 'Bekor qilish',
              onPressed: () async {
                await _favoritesService.addToFavorites(place);
                setState(() {
                  _favoritePlaces.add(place);
                });
              },
            ),
          ),
        );

        LogService.info('FavoritesPage', 'Place removed from favorites', data: {
          'placeId': place.id,
          'placeName': place.name,
        });
      }
    } catch (e) {
      LogService.error('FavoritesPage', 'Failed to remove place from favorites',
          error: e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sevimlilardan olib tashlashda xatolik'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _clearAllFavorites() async {
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Barcha sevimlilarni tozalash'),
          content: const Text(
            'Barcha joylarni sevimlilardan olib tashlashni xohlaysizmi? Bu amalni bekor qilib bo\'lmaydi.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Bekor qilish'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Barchasini tozalash'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        final success = await _favoritesService.clearAllFavorites();
        if (success) {
          setState(() {
            _favoritePlaces.clear();
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Barcha sevimlilar tozalandi'),
            ),
          );

          LogService.info('FavoritesPage', 'All favorites cleared');
        }
      }
    } catch (e) {
      LogService.error('FavoritesPage', 'Failed to clear all favorites',
          error: e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sevimlilarni tozalashda xatolik'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sevimlilar',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_favoritePlaces.isNotEmpty)
            IconButton(
              icon: Icon(
                Iconsax.trash,
                color: Theme.of(context).colorScheme.error,
              ),
              onPressed: _clearAllFavorites,
              tooltip: 'Barcha sevimlilarni tozalash',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadFavorites,
        child: _isLoading
            ? _buildLoadingState()
            : _error != null
                ? _buildErrorState()
                : _favoritePlaces.isEmpty
                    ? _buildEmptyState()
                    : _buildFavoritesList(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Sevimlilar yuklanmoqda...',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Sevimlilar yuklanmadi',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadFavorites,
              icon: const Icon(Icons.refresh),
              label: const Text('Qayta urinish'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Iconsax.heart,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Sevimlilar yo\'q',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Joylarni kashf qiling va sevimlilaringizga qo\'shing!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed(AppRoutes.main);
              },
              icon: const Icon(Iconsax.discover),
              label: const Text('Joylarni kashf qilish'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesList() {
    return CustomScrollView(
      slivers: [
        // Header with count
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Iconsax.heart5,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sizning sevimlilaringiz',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_favoritePlaces.length} ta joy saqlangan',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Favorites grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final place = _favoritePlaces[index];
                return Stack(
                  children: [
                    PlaceCard(
                      place: place,
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          AppRoutes.placeDetails,
                          arguments: place,
                        );
                      },
                    ),
                    // Remove button
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surface
                              .withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context)
                                  .shadowColor
                                  .withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.close,
                            size: 18,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          onPressed: () => _removeFromFavorites(place),
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
              childCount: _favoritePlaces.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 40),
        ),
      ],
    );
  }
}
