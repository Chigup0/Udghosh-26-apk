import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lottie/lottie.dart';
import 'package:udghosh/config/app_config.dart';
import 'package:udghosh/config/lottie_assets.dart';
import 'package:udghosh/theme/neo_theme.dart';

/// Spinner. Uses the Lottie loader when one is bundled, otherwise a plain
/// progress indicator — so this is always safe to use.
class AppLoader extends StatelessWidget {
  const AppLoader({super.key, this.size = 72, this.padding = 40});

  final double size;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final path = LottieAssets.state(AppAnim.loader);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: padding),
      child: Center(
        child: path == null
            ? SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.6,
                  color: NeoColors.waveTeal,
                ),
              )
            : Lottie.asset(
                path,
                width: size,
                height: size,
                repeat: true,
                // A corrupt or unreadable file must never take a screen down.
                errorBuilder: (_, __, ___) => SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.6,
                    color: NeoColors.waveTeal,
                  ),
                ),
              ),
      ),
    );
  }
}

/// Full-panel state illustration: animation (or icon), headline, explanation,
/// and an optional retry button.
///
/// Every list screen routes its empty and failure cases through this, so the
/// wording and the artwork stay consistent across both app models.
class AppStateView extends StatelessWidget {
  const AppStateView({
    super.key,
    required this.anim,
    required this.title,
    this.message,
    this.onRetry,
    this.sport,
    this.compact = false,
  });

  /// Which state this is. Picks the artwork and the fallback icon.
  final AppAnim anim;
  final String title;
  final String? message;
  final VoidCallback? onRetry;

  /// When set, an empty/no-fixtures state prefers that sport's own animation
  /// over the generic state art.
  final String? sport;

  final bool compact;

  /// Fallback glyph, used until a matching Lottie file is dropped in.
  List<List<dynamic>> get _icon {
    switch (anim) {
      case AppAnim.offline:
        return HugeIcons.strokeRoundedWifiDisconnected01;
      case AppAnim.serverDown:
        return HugeIcons.strokeRoundedCloudServer;
      case AppAnim.noFixtures:
        return HugeIcons.strokeRoundedCalendar03;
      case AppAnim.noPhotos:
        return HugeIcons.strokeRoundedImage02;
      case AppAnim.noResults:
        return HugeIcons.strokeRoundedSearch01;
      case AppAnim.empty:
      case AppAnim.loader:
        return HugeIcons.strokeRoundedInboxCheck;
    }
  }

  Color get _tone {
    switch (anim) {
      case AppAnim.offline:
      case AppAnim.serverDown:
        return NeoColors.alert;
      default:
        return NeoColors.waveInk;
    }
  }

  /// Prefer sport art for "nothing here" states; never for failures, where the
  /// user needs to understand it is a connection problem, not an empty list.
  String? get _animPath {
    final isEmptyState =
        anim == AppAnim.empty ||
        anim == AppAnim.noFixtures ||
        anim == AppAnim.noResults;
    if (isEmptyState && sport != null) {
      final path = LottieAssets.sport(sport!);
      if (path != null) return path;
    }
    return LottieAssets.state(anim);
  }

  @override
  Widget build(BuildContext context) {
    final path = _animPath;
    final size = compact ? 110.0 : 150.0;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 28,
        vertical: compact ? 22 : 40,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (path != null)
            Lottie.asset(
              path,
              width: size,
              height: size,
              repeat: true,
              errorBuilder: (_, __, ___) => _iconArt(size),
            )
          else
            _iconArt(size),
          SizedBox(height: compact ? 12 : 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: compact ? 13.5 : 15,
              fontWeight: FontWeight.w800,
              color: NeoColors.logoTeal,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 6),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                height: 1.45,
                color: NeoColors.textMuted,
              ),
            ),
          ],
          if (onRetry != null) ...[
            SizedBox(height: compact ? 14 : 20),
            GestureDetector(
              onTap: onRetry,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: NeoColors.charcoal,
                  borderRadius: BorderRadius.circular(NeoRadii.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedRefresh,
                      color: NeoColors.onCharcoal,
                      size: 15,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'TRY AGAIN',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.7,
                        color: NeoColors.onCharcoal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _iconArt(double size) {
    return Container(
      width: size * 0.6,
      height: size * 0.6,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _tone.withValues(alpha: 0.13),
        shape: BoxShape.circle,
      ),
      child: HugeIcon(icon: _icon, color: _tone, size: size * 0.27),
    );
  }
}

/// Small inline sport mark — the sport's own animation when one is bundled,
/// otherwise its icon. Used beside sport headings.
class SportMark extends StatelessWidget {
  const SportMark({super.key, required this.sport, this.size = 34});

  final String sport;
  final double size;

  @override
  Widget build(BuildContext context) {
    final path = LottieAssets.sport(sport);
    if (path == null) {
      return HugeIcon(
        icon: AppConfig.sportGlyph(sport),
        color: NeoColors.waveInk,
        size: size * 0.62,
      );
    }
    return Lottie.asset(
      path,
      width: size,
      height: size,
      repeat: true,
      errorBuilder: (_, __, ___) => HugeIcon(
        icon: AppConfig.sportGlyph(sport),
        color: NeoColors.waveInk,
        size: size * 0.62,
      ),
    );
  }
}
