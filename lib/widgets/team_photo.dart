import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:udghosh/config/core_team.dart';
import 'package:udghosh/theme/neo_theme.dart';

/// A team headshot, cropped the way the roster asks for.
///
/// `fit: cover` + [TeamMember.alignment] reproduces CSS `object-position`, and
/// the surrounding `Transform.scale` reproduces `transform: scale(...)` — a few
/// headshots are framed too wide and need zooming in. Falls back to the
/// member's initial when there is no photo or the Flickr URL fails.
class TeamPhoto extends StatelessWidget {
  const TeamPhoto({
    super.key,
    required this.member,
    required this.size,
    this.radius = 16,
    this.circle = false,
  });

  final TeamMember member;
  final double size;
  final double radius;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(circle ? size : radius);

    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        width: size,
        height: size,
        child: member.hasPhoto
            ? Transform.scale(
                scale: member.scale,
                child: CachedNetworkImage(
                  imageUrl: member.photo!,
                  fit: BoxFit.cover,
                  alignment: member.alignment,
                  fadeInDuration: const Duration(milliseconds: 180),
                  placeholder: (_, __) => _fallback(dim: true),
                  errorWidget: (_, __, ___) => _fallback(),
                ),
              )
            : _fallback(),
      ),
    );
  }

  Widget _fallback({bool dim = false}) {
    return ColoredBox(
      color: NeoColors.waveTeal.withValues(alpha: 0.14),
      child: Center(
        child: dim
            ? const SizedBox.shrink()
            : Text(
                member.initial,
                style: TextStyle(
                  fontSize: size * 0.36,
                  fontWeight: FontWeight.w800,
                  color: NeoColors.waveInk,
                ),
              ),
      ),
    );
  }
}
