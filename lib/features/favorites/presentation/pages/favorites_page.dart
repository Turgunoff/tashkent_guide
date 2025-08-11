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
        _error = 'Favorites service initialization failed';
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
        _error = 'Failed to load favorites';
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
            content: Text('${place.name} removed from favorites'),
            action: SnackBarAction(
              label: 'Undo',
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
          content: Text('Failed to remove from favorites'),
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
          title: const Text('Clear All Favorites'),
          content: const Text(
            'Are you sure you want to remove all places from favorites? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Clear All'),
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
              content: Text('All favorites cleared'),
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
          content: Text('Failed to clear favorites'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Favorites',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_favoritePlaces.isNotEmpty)
            IconButton(
              icon: const Icon(
                Iconsax.trash,
                color: Color(0xFFE74C3C),
              ),
              onPressed: _clearAllFavorites,
              tooltip: 'Clear all favorites',
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
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1565C0)),
          ),
          SizedBox(height: 16),
          Text(
            'Loading favorites...',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF748089),
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
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading favorites',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF212121),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF748089),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadFavorites,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
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
                color: const Color(0xFF1565C0).withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Iconsax.heart,
                size: 48,
                color: Color(0xFF1565C0),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No favorites yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF212121),
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start exploring places and add them to your favorites to see them here!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF748089),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed(AppRoutes.main);
              },
              icon: const Icon(Iconsax.discover),
              label: const Text('Explore Places'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
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
                    color: const Color(0xFF1565C0).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Iconsax.heart5,
                    color: Color(0xFF1565C0),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Favorites',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF212121),
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_favoritePlaces.length} place${_favoritePlaces.length == 1 ? '' : 's'} saved',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF748089),
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
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            size: 18,
                            color: Color(0xFFE74C3C),
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
