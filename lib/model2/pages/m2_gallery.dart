import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:udghosh/model2/theme/m2_style.dart';
import 'package:udghosh/model2/widgets/m2_widgets.dart';
import 'package:udghosh/config/lottie_assets.dart';
import 'package:udghosh/models/gallery_item.dart';
import 'package:udghosh/services/api_service.dart';
import 'package:udghosh/theme/neo_theme.dart';
import 'package:udghosh/widgets/nav/nav_spacer.dart';
import 'package:udghosh/widgets/press_scale.dart';
import 'package:udghosh/widgets/app_lottie.dart';

/// Model 2 Gallery — photos set into wells like prints in a mount board.
///
/// Same data rules as Model 1: categories are derived from the payload and the
/// filter rail only appears when there is more than one bucket.
class M2Gallery extends StatefulWidget {
  const M2Gallery({super.key});

  @override
  State<M2Gallery> createState() => _M2GalleryState();
}

class _M2GalleryState extends State<M2Gallery> {
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

  void _openFullscreen(String url) {
    if (url.isEmpty) return;
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.88),
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(14),
        backgroundColor: Colors.transparent,
        child: Neumorphic(
          style: M2.plinth(radius: 22),
          padding: const EdgeInsets.all(8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: CachedNetworkImage(imageUrl: url, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = _filtered;
    final showEmpty = images.isEmpty && !_loading;

    return Column(
      children: [
        if (_categories.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: M2ChipRail(
              labels: _categories,
              index: _categoryIndex,
              onSelected: (i) => setState(() => _categoryIndex = i),
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _load,
            color: NeoColors.waveTeal,
            child: _loading
                ? const AppLoader()
                : showEmpty
                ? ListView(
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
                      14,
                      16,
                      14,
                      NavMetrics.gutter(context),
                    ),
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    itemCount: images.length,
                    itemBuilder: (context, i) {
                      final item = images[i];
                      final height = 150.0 + (i % 3) * 44;
                      return PressScale(
                        onTap: () => _openFullscreen(item.imageUrl),
                        child: Neumorphic(
                          style: M2.well(radius: 20, depth: -4),
                          padding: const EdgeInsets.all(7),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: SizedBox(
                              height: height,
                              width: double.infinity,
                              child: CachedNetworkImage(
                                imageUrl: item.imageUrl,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => Center(
                                  child: HugeIcon(
                                    icon: HugeIcons.strokeRoundedImage02,
                                    color: NeoColors.textMuted,
                                    size: 22,
                                  ),
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
