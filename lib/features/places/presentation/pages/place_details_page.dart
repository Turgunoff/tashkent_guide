import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/entities/place.dart';
import '../../data/models/place_model.dart';
import '../../../../core/services/log_service.dart';
import '../../../../core/services/favorites_service.dart';

class PlaceDetailsPage extends StatefulWidget {
  final Place place;

  const PlaceDetailsPage({
    super.key,
    required this.place,
  });

  @override
  State<PlaceDetailsPage> createState() => _PlaceDetailsPageState();
}

class _PlaceDetailsPageState extends State<PlaceDetailsPage> {
  bool isFavorite = false;
  late FavoritesService _favoritesService;

  @override
  void initState() {
    super.initState();
    _initializeFavorites();
  }

  Future<void> _initializeFavorites() async {
    _favoritesService = await FavoritesService.getInstance();
    final isFav = await _favoritesService.isFavorite(widget.place.id);
    setState(() {
      isFavorite = isFav;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
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
                  Iconsax.arrow_left,
                  color: Color(0xFF212121),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            actions: [
              // Favorite Button
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    isFavorite ? Iconsax.heart5 : Iconsax.heart,
                    color: isFavorite ? Colors.red : const Color(0xFF212121),
                  ),
                  onPressed: () async {
                    // Convert Place to PlaceModel for favorites service
                    final placeModel = PlaceModel(
                      id: widget.place.id,
                      name: widget.place.name,
                      description: widget.place.description,
                      imageUrl: widget.place.imageUrl,
                      address: widget.place.address,
                      latitude: widget.place.latitude,
                      longitude: widget.place.longitude,
                      rating: widget.place.rating,
                      categoryId: widget.place.categoryId,
                      createdAt: widget.place.createdAt,
                    );
                    
                    final success = await _favoritesService.toggleFavorite(placeModel);
                    if (success) {
                      setState(() {
                        isFavorite = !isFavorite;
                      });
                      LogService.info('PlaceDetailsPage', 'Favorite toggled',
                          data: {
                            'placeId': widget.place.id,
                            'placeName': widget.place.name,
                            'isFavorite': isFavorite,
                          });
                    }
                  },
                ),
              ),
              // Share Button
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
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
                    Iconsax.share,
                    color: Color(0xFF212121),
                  ),
                  onPressed: () {
                    Share.share(
                      'Check out ${widget.place.name} in Tashkent! ${widget.place.description ?? ''}',
                      subject: widget.place.name,
                    );
                    LogService.info('PlaceDetailsPage', 'Share button pressed',
                        data: {
                          'placeId': widget.place.id,
                          'placeName': widget.place.name,
                        });
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Place Image
                  widget.place.imageUrl != null
                      ? Image.network(
                          widget.place.imageUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFF0F1EF),
                                    Color(0xFFF7F7F6)
                                  ],
                                ),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF1565C0)),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return _buildImagePlaceholder();
                          },
                        )
                      : _buildImagePlaceholder(),
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Place Name and Rating
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.place.name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF212121),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: Colors.amber.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Iconsax.star1,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.place.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF212121),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Address Section
                  if (widget.place.address != null) ...[
                    _buildInfoSection(
                      icon: Iconsax.location,
                      title: 'Address',
                      content: widget.place.address!,
                      iconColor: const Color(0xFF1565C0),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Description Section
                  if (widget.place.description != null) ...[
                    _buildInfoSection(
                      icon: Iconsax.document_text,
                      title: 'Description',
                      content: widget.place.description!,
                      iconColor: const Color(0xFF4CAF50),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Location Coordinates
                  if (widget.place.latitude != null &&
                      widget.place.longitude != null) ...[
                    _buildInfoSection(
                      icon: Iconsax.map,
                      title: 'Location',
                      content:
                          '${widget.place.latitude!.toStringAsFixed(6)}, ${widget.place.longitude!.toStringAsFixed(6)}',
                      iconColor: const Color(0xFFFF9800),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Created Date
                  _buildInfoSection(
                    icon: Iconsax.calendar,
                    title: 'Added',
                    content: _formatDate(widget.place.createdAt),
                    iconColor: const Color(0xFF9C27B0),
                  ),
                  const SizedBox(height: 30),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Implement directions functionality
                            LogService.info(
                                'PlaceDetailsPage', 'Directions button pressed',
                                data: {
                                  'placeId': widget.place.id,
                                  'placeName': widget.place.name,
                                });
                          },
                          icon: const Icon(Iconsax.route_square),
                          label: const Text(
                            'Get Directions',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Implement call functionality
                            LogService.info(
                                'PlaceDetailsPage', 'Call button pressed',
                                data: {
                                  'placeId': widget.place.id,
                                  'placeName': widget.place.name,
                                });
                          },
                          icon: const Icon(Iconsax.call),
                          label: const Text(
                            'Call',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF1565C0),
                            side: const BorderSide(color: Color(0xFF1565C0)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String content,
    required Color iconColor,
  }) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF748089),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF212121),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF0F1EF), Color(0xFFF7F7F6)],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 80,
          color: Color(0xFFB0B7BD),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
