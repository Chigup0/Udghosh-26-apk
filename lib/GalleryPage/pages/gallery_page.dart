import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:udghosh/widgets/widgets.dart';
import '../../utils.dart';

class GalleryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: AppBar(
          backgroundColor: Colors.black,
          flexibleSpace: Container(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Row(
                children: [const SizedBox(width: 16), pageTitleText("Gallery")],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: containerDecoration,
        child: MasonryGridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          padding: const EdgeInsets.all(8),
          itemCount: imageLinks.length + 1,
          itemBuilder: (context, index) {
            if (index == imageLinks.length) {
              return const SizedBox(height: 150);
            }
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FullscreenImageViewer(
                      images: imageLinks,
                      initialIndex: index,
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: imageLinks[index],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: const Color(0xFF1E293B),
                    highlightColor: const Color(0xFF334155),
                    child: Container(color: const Color(0xFF1E293B)),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade800,
                    child: const Icon(Icons.broken_image, color: Colors.white),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class FullscreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullscreenImageViewer({
    Key? key,
    required this.images,
    required this.initialIndex,
  }) : super(key: key);

  @override
  State<FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<FullscreenImageViewer> {
  late PageController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  void _goTo(int index) {
    if (index >= 0 && index < widget.images.length) {
      _controller.jumpToPage(index);
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (context, index) {
              return InteractiveViewer(
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: widget.images[index],
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: const Color(0xFF1E293B),
                      highlightColor: const Color(0xFF334155),
                      child: Container(color: const Color(0xFF1E293B)),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade800,
                      child: const Icon(
                        Icons.broken_image,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Close button
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Left arrow
          if (_currentIndex > 0)
            Positioned(
              left: 20,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: () => _goTo(_currentIndex - 1),
              ),
            ),

          // Right arrow
          if (_currentIndex < widget.images.length - 1)
            Positioned(
              right: 20,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: () => _goTo(_currentIndex + 1),
              ),
            ),
        ],
      ),
    );
  }
}
