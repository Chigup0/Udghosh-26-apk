import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:udghosh/models/gallery_item.dart';
import 'package:udghosh/services/api_service.dart';
import 'package:udghosh/theme/neo_theme.dart';
import 'package:udghosh/widgets/neo/neo_selectors.dart';

/// Asymmetric 2-column masonry gallery with category filter chips.
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  static const _categories = ['All', 'Opening Night', 'Athletics', 'Finals', 'Pronite'];

  List<GalleryItem> _items = [];
  bool _loading = true;
  int _categoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _items = await ApiService.getGallery();
    } catch (_) {
      _items = [];
    }
    if (mounted) setState(() => _loading = false);
  }

  List<GalleryItem> get _filtered {
    if (_categoryIndex == 0) return _items;
    final cat = _categories[_categoryIndex];
    return _items.where((i) => i.category == cat).toList();
  }

  void _openFullscreen(BuildContext context, String url) {
    if (url.isEmpty) return;
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(12),
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: CachedNetworkImage(imageUrl: url, fit: BoxFit.contain),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = _filtered;
    final showDemo = images.isEmpty && !_loading;

    return Column(
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: NeoPillBar(
            labels: _categories,
            selectedIndex: _categoryIndex,
            onSelected: (i) => setState(() => _categoryIndex = i),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _load,
            color: NeoColors.waveTeal,
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: NeoColors.waveTeal))
                : showDemo
                    ? _demoPlaceholder(context)
                    : MasonryGridView.count(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        itemCount: images.length,
                        itemBuilder: (context, i) {
                          final item = images[i];
                          final height = 140.0 + (i % 3) * 40;
                          return GestureDetector(
                            onTap: () => _openFullscreen(context, item.imageUrl),
                            child: Container(
                              height: height,
                              decoration: BoxDecoration(
                                color: NeoColors.surface,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: NeoShadows.raisedSmall(),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: CachedNetworkImage(
                                  imageUrl: item.imageUrl,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) => Container(
                                    color: NeoColors.surfaceRecessed,
                                    child: const Icon(Icons.broken_image_outlined, color: NeoColors.textMuted),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ),
      ],
    );
  }

  Widget _demoPlaceholder(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => _openFullscreen(context, ''),
        child: Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            color: NeoColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: NeoShadows.raised(),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_rounded, size: 48, color: NeoColors.waveTeal),
              SizedBox(height: 10),
              Text('DEMO PHOTO', style: TextStyle(fontWeight: FontWeight.w800, color: NeoColors.logoTeal)),
              SizedBox(height: 4),
              Text('Tap for fullscreen', style: TextStyle(fontSize: 11, color: NeoColors.textMuted)),
            ],
          ),
        ),
      ),
    );
  }
}
