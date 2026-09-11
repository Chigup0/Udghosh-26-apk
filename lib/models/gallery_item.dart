import 'package:udghosh/config/app_config.dart';

class GalleryItem {
  GalleryItem({required this.id, required this.imageUrl, this.category});

  final int id;
  final String imageUrl;
  final String? category;

  /// Returns null when the backend URL is one of the known-broken
  /// `/uploads/...` paths, so callers fall back to a placeholder asset.
  static GalleryItem? fromJson(Map<String, dynamic> json) {
    final resolved = AppConfig.resolveImageUrl(
      (json['image_url'] ?? json['url'] ?? json['imageUrl'])?.toString(),
    );
    if (resolved == null) return null;
    return GalleryItem(
      id: (json['id'] ?? 0) as int,
      imageUrl: resolved,
      category: json['category']?.toString(),
    );
  }
}
