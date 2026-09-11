import 'package:flutter/material.dart';
import 'package:udghosh/theme/neo_theme.dart';
import 'package:udghosh/services/auth_provider.dart';
import 'neo_container.dart';

/// Persistent top app bar shown on every main tab: circular logo mark +
/// stacked wordmark on the left, notification bell + profile avatar on the
/// right.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.onNotificationTap,
    this.onProfileTap,
    this.hasUnread = false,
  });

  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final bool hasUnread;

  @override
  Size get preferredSize => const Size.fromHeight(76);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: NeoColors.surface,
                shape: BoxShape.circle,
                boxShadow: NeoShadows.raisedSmall(),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/logo/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.emoji_events_outlined,
                    color: NeoColors.logoTeal,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'UDGHOSH',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: NeoColors.logoTeal,
                      letterSpacing: 0.5,
                      height: 1.05,
                    ),
                  ),
                  Text(
                    "'26 // ASCENSION",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: NeoColors.flameGold.withValues(alpha: 0.95),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
            NeoCircleButton(
              onTap: onNotificationTap,
              badge: hasUnread,
              child: const Icon(
                Icons.notifications_rounded,
                size: 20,
                color: NeoColors.logoTeal,
              ),
            ),
            const SizedBox(width: 10),
            NeoCircleButton(
              onTap: onProfileTap,
              child: ListenableBuilder(
                listenable: AuthController.instance,
                builder: (context, _) {
                  final auth = AuthController.instance;
                  if (auth.isLoggedIn) {
                    return Text(
                      auth.initials,
                      style: const TextStyle(
                        color: NeoColors.waveTeal,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    );
                  }
                  return const Icon(
                    Icons.person_rounded,
                    size: 20,
                    color: NeoColors.logoTeal,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
