import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:udghosh/utils.dart';

class GalleryHighLight extends StatelessWidget {
  final Function() onTap;
  GalleryHighLight({super.key, required this.onTap});

  final double height = 90;
  final double width = 90;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 40.0, bottom: 12.0),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A), // Dark blue accent
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Gallery",
                style: TextStyle(
                  fontFamily: globalFontFamily,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: lightTextColor,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),

        // Gallery Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: imageLinks.asMap().entries.map((entry) {
              int index = entry.key;
              String imageUrl = entry.value;

              // "See more" card at last position
              if (index == 5) {
                return InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: width,
                    height: height,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF1E3A8A), // Dark blue
                          Color(0xFF1E40AF), // Slightly lighter blue
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E3A8A).withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(2, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_circle_outline,
                            size: 28, color: Colors.white),
                        const SizedBox(height: 8),
                        Text(
                          "See more",
                          style: TextStyle(
                            fontFamily: globalFontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Normal image card
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF1E3A8A).withValues(alpha: 0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(2, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: width,
                          height: height,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: const Color(0xFF1E293B),
                            highlightColor: const Color(0xFF334155),
                            child: Container(
                              width: width,
                              height: height,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: width,
                            height: height,
                            color: Colors.grey.shade800,
                            child: const Icon(Icons.broken_image,
                                color: Colors.white),
                          ),
                        ),
                        // Overlay
                        Positioned.fill(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              // 👇 hook this to FullscreenImageViewer
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    const Color(0xFF0F172A).withValues(alpha: 0.3),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
