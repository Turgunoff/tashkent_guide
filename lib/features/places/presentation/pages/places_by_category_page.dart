import 'package:flutter/material.dart';

import '../../../categories/domain/entities/category.dart';
import '../../../../core/services/log_service.dart';
import '../../data/repositories/place_repository_impl.dart';
import '../../domain/entities/place.dart';
import '../../domain/usecases/get_places_by_category_usecase.dart';
import '../widgets/place_card.dart';
import '../widgets/place_card_shimmer.dart';

class PlacesByCategoryPage extends StatefulWidget {
  final Category category;

  const PlacesByCategoryPage({super.key, required this.category});

  @override
  State<PlacesByCategoryPage> createState() => _PlacesByCategoryPageState();
}

class _PlacesByCategoryPageState extends State<PlacesByCategoryPage> {
  late final GetPlacesByCategoryUseCase _getPlacesByCategoryUseCase;
  List<Place> _places = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    LogService.info('PlacesByCategoryPage', 'Page initialized', data: {
      'categoryId': widget.category.id,
      'categoryName': widget.category.name,
    });
    _getPlacesByCategoryUseCase =
        GetPlacesByCategoryUseCase(PlaceRepositoryImpl());
    _load();
  }

  Future<void> _load() async {
    final sw = Stopwatch()..start();
    try {
      LogService.info('PlacesByCategoryPage', 'Loading places started', data: {
        'categoryId': widget.category.id,
      });

      setState(() {
        _isLoading = true;
        _error = null;
      });

      final res = await _getPlacesByCategoryUseCase(widget.category.id);

      setState(() {
        _places = res;
        _isLoading = false;
      });

      sw.stop();
      LogService.info('PlacesByCategoryPage', 'Places loaded successfully',
          data: {
            'categoryId': widget.category.id,
            'count': _places.length,
            'elapsedMs': sw.elapsedMilliseconds,
          });
    } catch (e) {
      sw.stop();
      LogService.error('PlacesByCategoryPage', 'Failed to load places',
          error: e,
          data: {
            'categoryId': widget.category.id,
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
        title: Text(widget.category.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _isLoading
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
              )
            : _error != null
                ? ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            const Icon(Icons.error_outline, size: 48),
                            const SizedBox(height: 12),
                            Text(_error!, textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _load,
                              child: const Text("Qayta urinib ko'rish"),
                            )
                          ],
                        ),
                      ),
                    ],
                  )
                : (_places.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 120),
                          Center(child: Text('Ushbu toifada joylar topilmadi')),
                          SizedBox(height: 120),
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: _places.length,
                          itemBuilder: (context, index) {
                            final place = _places[index];
                            return PlaceCard(place: place);
                          },
                        ),
                      )),
      ),
    );
  }
}
