import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:udghosh/theme/neo_theme.dart';
import 'package:udghosh/widgets/neo/neo_container.dart';

/// Asks for notification permission with a themed dialog instead of relying
/// on the bare OS prompt.
///
/// Called on every cold start (see `_ModelHost` in `main.dart`) — it is a
/// no-op once permission is granted, and keeps asking on every launch until
/// then, since a silent one-time request is easy to dismiss without
/// noticing. Once the OS has permanently denied the prompt (no system dialog
/// left to show), the button instead deep-links to the app's settings page.
Future<void> maybeShowNotificationPermissionPrompt(BuildContext context) async {
  final messaging = FirebaseMessaging.instance;
  final settings = await messaging.getNotificationSettings();
  if (settings.authorizationStatus == AuthorizationStatus.authorized ||
      settings.authorizationStatus == AuthorizationStatus.provisional) {
    return;
  }
  if (!context.mounted) return;

  final permanentlyDenied = await Permission.notification.isPermanentlyDenied;

  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (context) =>
        _NotificationPermissionDialog(permanentlyDenied: permanentlyDenied),
  );
}

class _NotificationPermissionDialog extends StatelessWidget {
  const _NotificationPermissionDialog({required this.permanentlyDenied});

  final bool permanentlyDenied;

  Future<void> _enable(BuildContext context) async {
    if (permanentlyDenied) {
      await openAppSettings();
      if (context.mounted) Navigator.of(context).pop();
      return;
    }
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      await messaging.subscribeToTopic('all_users');
    }
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: NeoCard(
        radius: NeoRadii.cardLarge,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: NeoColors.flameGold.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedNotification01,
                color: NeoColors.goldInk,
                size: 26,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Stay in the loop',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: NeoColors.logoTeal,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              permanentlyDenied
                  ? 'Notifications are off in system settings. Turn them '
                        'on to get live score alerts and important '
                        'announcements.'
                  : 'Allow notifications to get live score alerts and '
                        'important announcements the moment they happen.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: NeoColors.textMuted,
              ),
            ),
            const SizedBox(height: 20),
            NeoPillButton(
              label: permanentlyDenied
                  ? 'OPEN SETTINGS'
                  : 'ENABLE NOTIFICATIONS',
              icon: Icons.notifications_active_rounded,
              onTap: () => _enable(context),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Not now',
                style: TextStyle(
                  color: NeoColors.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
