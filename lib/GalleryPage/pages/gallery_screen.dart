import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:udghosh/config/lottie_assets.dart';
import 'package:udghosh/models/gallery_item.dart';
import 'package:udghosh/services/api_service.dart';
import 'package:udghosh/theme/neo_theme.dart';
import 'package:udghosh/widgets/app_lottie.dart';
import 'package:udghosh/widgets/nav/nav_spacer.dart';
import 'package:udghosh/widgets/press_scale.dart';
import 'package:udghosh/widgets/neo/neo_selectors.dart';

/// Asymmetric 2-column masonry gallery.
///
/// `/gallery` returns `{id, image_url, created_at}` with no pagination and no
/// category, so the filter bar is derived from whatever categories the data
/// actually carries and stays hidden when there are none — rather than
/// offering hardcoded filters that can only ever return nothing.
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  static const _allLabel = 'All';

  List<GalleryItem> _items = [];
  List<String> _categories = const [];
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
    if (!mounted) return;

    final found =
        _items
            .map((i) => i.category)
            .whereType<String>()
            .where((c) => c.trim().isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    setState(() {
      // Only worth a filter bar when there is more than one bucket to pick.
      _categories = found.length > 1 ? [_allLabel, ...found] : const [];
      _categoryIndex = 0;
      _loading = false;
    });
  }

  List<GalleryItem> get _filtered {
    if (_categories.isEmpty || _categoryIndex == 0) return _items;
    final category = _categories[_categoryIndex];
    return _items.where((i) => i.category == category).toList();
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
        if (_categories.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: NeoPillBar(
              labels: _categories,
              selectedIndex: _categoryIndex,
              onSelected: (i) => setState(() => _categoryIndex = i),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Expanded(
          child: RefreshIndicator(
            onRefresh: _load,
            color: NeoColors.waveTeal,
            child: _loading
                ? const AppLoader()
                : showDemo
                ? ListView(
                    // Scrollable so pull-to-refresh still works on an empty
                    // gallery; a bare Center swallows the gesture.
                    padding: const EdgeInsets.only(top: 40),
                    children: const [
                      AppStateView(
                        anim: AppAnim.noPhotos,
                        title: 'No photos yet',
                        message:
                            'Shots from the fest will show up here as '
                            'they are uploaded.',
                      ),
                    ],
                  )
                : MasonryGridView.count(
                    padding: EdgeInsets.fromLTRB(
                      12,
                      0,
                      12,
                      NavMetrics.gutter(context),
                    ),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    itemCount: images.length,
                    itemBuilder: (context, i) {
                      final item = images[i];
                      final height = 140.0 + (i % 3) * 40;
                      return PressScale(
                        onTap: () => _openFullscreen(context, item.imageUrl),
                        child: Neumorphic(
                          style: NeoTheme.raisedStyle(
                            radius: 20,
                            depth: NeoDepth.chip,
                          ),
                          child: SizedBox(
                            height: height,
                            child: CachedNetworkImage(
                              imageUrl: item.imageUrl,
                              fit: BoxFit.cover,
                              // Gallery links are external and can rot.
                              errorWidget: (context, url, error) => Container(
                                color: NeoColors.surfaceRecessed,
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  color: NeoColors.textMuted,
                                ),
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
}
