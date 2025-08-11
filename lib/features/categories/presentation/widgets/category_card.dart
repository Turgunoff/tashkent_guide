import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../domain/entities/category.dart';
import '../../../../core/services/log_service.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dumaloq icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: category.iconUrl != null
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: category.iconUrl!,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      placeholder: (context, url) {
                        LogService.info('CategoryCard', 'Loading category icon',
                            data: {
                              'categoryId': category.id,
                              'categoryName': category.name,
                              'iconUrl': category.iconUrl,
                            });
                        return Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary),
                          ),
                        );
                      },
                      errorWidget: (context, url, error) {
                        LogService.warn(
                            'CategoryCard', 'Failed to load category icon',
                            data: {
                              'categoryId': category.id,
                              'categoryName': category.name,
                              'iconUrl': category.iconUrl,
                              'error': error.toString(),
                            });
                        return _buildDefaultIcon(context);
                      },
                      memCacheWidth:
                          128, // Optimize memory usage for small icons
                      memCacheHeight: 128,
                    ),
                  )
                : _buildDefaultIcon(context),
          ),
          const SizedBox(height: 8),
          // Kategoriya nomi
          Text(
            category.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultIcon(BuildContext context) {
    IconData iconData;

    // Kategoriya nomiga qarab icon tanlash
    final name = category.name.toLowerCase();
    if (name.contains('tarix') || name.contains('history')) {
      iconData = Icons.account_balance;
    } else if (name.contains('muzey') || name.contains('museum')) {
      iconData = Icons.museum;
    } else if (name.contains('bog') || name.contains('park')) {
      iconData = Icons.park;
    } else if (name.contains('restoran') ||
        name.contains('kafe') ||
        name.contains('restaurant')) {
      iconData = Icons.restaurant;
    } else {
      iconData = Icons.location_on;
    }

    return Icon(
      iconData,
      size: 28,
      color: Theme.of(context).colorScheme.primary,
    );
  }
}
