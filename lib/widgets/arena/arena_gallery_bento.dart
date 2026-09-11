import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:udghosh/theme/arena_theme.dart';

/// The Festival Shutter Feed — an asymmetric bento preview (one tall 4:5
/// lead frame, two stacked 1:1 frames) with hard borders and a tight 4px
/// gap, each tile leading straight into the Gallery tab.
class ArenaGalleryBento extends StatelessWidget {
  final List<String> imageUrls;
  final String dayTag;
  final VoidCallback onOpenGallery;

  const ArenaGalleryBento({
    super.key,
    required this.imageUrls,
    required this.onOpenGallery,
    this.dayTag = 'DAY 02 // CAPTURED',
  });

  @override
  Widget build(BuildContext context) {
    final lead = imageUrls.isNotEmpty ? imageUrls[0] : null;
    final second = imageUrls.length > 1 ? imageUrls[1] : null;
    final third = imageUrls.length > 2 ? imageUrls[2] : null;

    return SizedBox(
      height: 224,
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: _BentoFrame(url: lead, tag: dayTag, onTap: onOpenGallery),
          ),
          const SizedBox(width: 4),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Expanded(child: _BentoFrame(url: second, onTap: onOpenGallery)),
                const SizedBox(height: 4),
                Expanded(child: _BentoFrame(url: third, onTap: onOpenGallery)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BentoFrame extends StatelessWidget {
  final String? url;
  final String? tag;
  final VoidCallback onTap;

  const _BentoFrame({required this.url, required this.onTap, this.tag});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: ArenaColors.surfaceRecessed,
          border: Border.all(color: ArenaColors.border, width: 1),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (url != null)
              CachedNetworkImage(
                imageUrl: url!,
                fit: BoxFit.cover,
                placeholder: (context, _) => Shimmer.fromColors(
                  baseColor: ArenaColors.surface,
                  highlightColor: ArenaColors.border,
                  child: Container(color: ArenaColors.surface),
                ),
                errorWidget: (context, _, __) => const Icon(
                  Icons.broken_image_outlined,
                  color: ArenaColors.textDim,
                ),
              ),
            if (tag != null)
              Positioned(
                left: 6,
                bottom: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  color: ArenaColors.canvas.withValues(alpha: 0.85),
                  child: Text(tag!, style: ArenaText.label(size: 8.5, color: ArenaColors.textPrimary, tracking: 0.6)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
