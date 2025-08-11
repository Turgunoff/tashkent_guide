import 'package:flutter/material.dart';

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
              color: const Color(0xFFE3F2FD),
              shape: BoxShape.circle,
            ),
            child: category.iconUrl != null
                ? ClipOval(
                    child: Image.network(
                      category.iconUrl!,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          LogService.info('CategoryCard', 'Category icon loaded successfully', data: {
                            'categoryId': category.id,
                            'categoryName': category.name,
                            'iconUrl': category.iconUrl,
                          });
                          return child;
                        }
                                                                          return const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1565C0)),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        LogService.warn('CategoryCard', 'Failed to load category icon', data: {
                          'categoryId': category.id,
                          'categoryName': category.name,
                          'iconUrl': category.iconUrl,
                          'error': error.toString(),
                        });
                        return _buildDefaultIcon(context);
                      },
                    ),
                  )
                : _buildDefaultIcon(context),
          ),
          const SizedBox(height: 8),
          // Kategoriya nomi
          Text(
            category.name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1565C0),
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
      color: const Color(0xFF1565C0),
    );
  }
}
