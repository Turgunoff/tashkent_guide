import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../domain/entities/place.dart';
import '../../../../core/services/log_service.dart';
import '../../../../app/routes/app_routes.dart';

class PlaceCard extends StatelessWidget {
  final Place place;
  final VoidCallback? onTap;

  const PlaceCard({
    super.key,
    required this.place,
    this.onTap,
  });

  void _navigateToDetails(BuildContext context) {
    Navigator.of(context).pushNamed(
      AppRoutes.placeDetails,
      arguments: place,
    );
  }

  @override
  Widget build(BuildContext context) {
    const double radius = 24.0;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE6E8EB)),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          onTap: onTap ?? () => _navigateToDetails(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image / placeholder
              Expanded(
                flex: 2,
                child: place.imageUrl != null
                    ? Image.network(
                        place.imageUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            LogService.info('PlaceCard', 'Place image loaded successfully', data: {
                              'placeId': place.id,
                              'placeName': place.name,
                              'imageUrl': place.imageUrl,
                            });
                            return child;
                          }
                          return Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFFF0F1EF), Color(0xFFF7F7F6)],
                              ),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1565C0)),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          LogService.warn('PlaceCard', 'Failed to load place image', data: {
                            'placeId': place.id,
                            'placeName': place.name,
                            'imageUrl': place.imageUrl,
                            'error': error.toString(),
                          });
                          return _buildPlaceholder();
                        },
                      )
                    : _buildPlaceholder(),
              ),

              // Info
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF212121),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      if (place.address != null)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              Iconsax.location,
                              size: 14,
                              color: Color(0xFF748089),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                place.address!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF748089),
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      Row(
                        children: [
                          const Icon(
                            Iconsax.star1,
                            size: 14,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            place.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF212121),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
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
          size: 42,
          color: Color(0xFFB0B7BD),
        ),
      ),
    );
  }
}
