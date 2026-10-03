// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart'
    show LiquidGlassWidgets;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart'
    show DeviceOrientation, SystemChrome, SystemUiMode, SystemUiOverlayStyle;
import 'package:http/http.dart' as http; // For HTTP requests
import 'package:udghosh/DashBoard/pages/dashboard.dart'; // Your dashboard page
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart'
    show NeumorphicTheme;
import 'package:udghosh/theme/neo_theme.dart';
import 'package:udghosh/config/lottie_assets.dart';
import 'package:udghosh/config/feature_controller.dart';
import 'package:udghosh/config/model_controller.dart';
import 'package:udghosh/config/nav_style_controller.dart';
import 'package:udghosh/model2/model2_shell.dart';
import 'package:udghosh/theme/theme_controller.dart';
import 'package:udghosh/widgets/notification_permission_dialog.dart';
import 'package:url_launcher/url_launcher.dart'; // To launch App Store URL

import 'utils.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Handling background message: ${message.messageId}');
}

/// Checks the current permission status and subscribes to the broadcast
/// topic if a previous launch already granted it. Never prompts — that only
/// happens from the themed in-app dialog (see `_ModelHost`). Fire-and-forget
/// from `main()` so a slow FCM round-trip never delays first paint.
Future<void> _syncFcmTopicSubscription() async {
  try {
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.getNotificationSettings();
    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      await messaging.subscribeToTopic('all_users');
      debugPrint('Subscribed to all_users topic');
    }
  } catch (e) {
    debugPrint('FCM topic sync skipped: $e');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('Foreground notification: ${message.notification?.title}');
  });

  // Independent restores — none of these depend on each other, so running
  // them together instead of one `await` per line is most of what makes
  // startup fast. The liquid-glass shader warm-up rides along too: it is
  // slow but must finish before `runApp` so the nav bar never flashes a
  // placeholder, and "never fatal" is preserved with its own try/catch.
  await Future.wait([
    ThemeController.instance.restore(),
    ModelController.instance.restore(),
    LottieAssets.warmUp(),
    NavStyleController.instance.restore(),
    FeatureController.instance.restore(),
    LiquidGlassWidgets.initialize().catchError(
      (e) => debugPrint('Liquid glass init skipped: $e'),
    ),
  ]);

  // Draw behind the system bars so the glass chrome reads edge to edge.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Not awaited: an FCM network round-trip has no business delaying the
  // first frame.
  unawaited(_syncFcmTopicSubscription());

  runApp(
    LiquidGlassWidgets.wrap(
      adaptiveQuality: true,
      // Bridges MaterialApp's ThemeMode into the glass brightness cascade,
      // so the bar tints correctly when the app theme and the OS disagree —
      // which is exactly the case for Themes 4/5/6.
      brightnessResolver: Theme.maybeBrightnessOf,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Simple version string - update this manually when releasing new versions

  bool _updateRequired = false;
  // The app renders immediately; the version check runs in the background
  // and only swaps in the update screen if it actually finds a mismatch —
  // a slow or flaky request to GitHub Pages must never hold up first paint.
  String _latestVersion = '';

  Future<String> _fetchLatestVersion() async {
    try {
      final response = await http
          .get(
            Uri.parse('https://chigup0.github.io/udghosh.org/app_version.txt'),
            headers: {'Cache-Control': 'no-cache'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return response.body.trim();
      } else {
        throw Exception('Failed to fetch version: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching latest version: $e');
      rethrow;
    }
  }

  Future<void> _launchUpdateUrl() async {
    const String updateUrl =
        'https://github.com/Udghosh-25/udghosh.org/releases/latest/download/udghosh.apk';
    try {
      if (await canLaunchUrl(Uri.parse(updateUrl))) {
        await launchUrl(
          Uri.parse(updateUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw Exception('Could not launch update URL');
      }
    } catch (e) {
      debugPrint('Error launching update URL: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening update link: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void checkForUpdates() async {
    try {
      _latestVersion = await _fetchLatestVersion();

      debugPrint('Current version: $appVersion');
      debugPrint('Latest version: $_latestVersion');

      // Simple string comparison
      final updateRequired = appVersion != _latestVersion;
      if (!mounted || !updateRequired) return;
      setState(() => _updateRequired = true);
      debugPrint('Update required');
    } catch (e) {
      // Allow access if the version check fails — never block the app on a
      // flaky network request.
      debugPrint('Error checking for updates: $e');
    }
  }

  Widget _buildUpdateRequiredScreen() {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset('assets/logo/logo.png', height: 120, width: 120),
                const SizedBox(height: 20),
                Image.asset('assets/logo/typeface.png', height: 40),
                const SizedBox(height: 40),

                // Update icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.system_update,
                    size: 60,
                    color: Colors.orange.shade600,
                  ),
                ),
                const SizedBox(height: 30),

                // Title
                Text(
                  'Update Required',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  'A new version of Udghosh Sports is available. Please update to continue using the app.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade400,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Version info
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Current: $appVersion → Latest: $_latestVersion',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade300,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Update button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _launchUpdateUrl,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.download, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'Download Update',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Retry button
                TextButton(
                  onPressed: checkForUpdates,
                  child: Text(
                    'Check Again',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    checkForUpdates();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    precacheImage(const AssetImage('assets/logo/logo.png'), context);
    precacheImage(const AssetImage('assets/logo/typeface.png'), context);
    precacheImage(
      const AssetImage('assets/headPhotos/placeholder.jpeg'),
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    // The background version check can swap this in later, but first paint
    // never waits on it.
    if (_updateRequired) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: _buildUpdateRequiredScreen(),
      );
    }

    return ListenableBuilder(
      listenable: ThemeController.instance,
      builder: (context, _) {
        final controller = ThemeController.instance;
        final platformBrightness = MediaQuery.platformBrightnessOf(context);
        final isDark = controller.isDarkFor(platformBrightness);

        // Swap the active palette before anything below reads NeoColors.
        NeoColors.palette = controller.paletteFor(platformBrightness);

        // NeumorphicTheme sits above MaterialApp so every pushed route — and
        // every dialog drawn by the Navigator — inherits the same
        // light-source vector and base colour.
        return NeumorphicTheme(
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          theme: NeoTheme.neumorphic,
          darkTheme: NeoTheme.neumorphic,
          child: MaterialApp(
            // Remounts the tree on a light/dark change so no `const`
            // subtree is left holding the previous palette.
            key: ValueKey(isDark),
            debugShowCheckedModeBanner: false,
            title: 'Udghosh Sports',
            theme: NeoTheme.themeData,
            home: const _ModelHost(),
          ),
        );
      },
    );
  }
}

/// Chooses the UI shell. Both shells read the same controllers and services;
/// only the presentation differs, so switching never changes behaviour.
class _ModelHost extends StatefulWidget {
  const _ModelHost();

  @override
  State<_ModelHost> createState() => _ModelHostState();
}

class _ModelHostState extends State<_ModelHost> {
  @override
  void initState() {
    super.initState();
    // Post-frame: needs a BuildContext attached to the tree, and must not
    // block first paint. Runs on every cold start until permission is
    // granted — see the dialog's own doc comment for why.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) maybeShowNotificationPermissionPrompt(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: NeoColors.isDark
            ? Brightness.light
            : Brightness.dark,
        statusBarBrightness: NeoColors.isDark
            ? Brightness.dark
            : Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: NeoColors.isDark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: ListenableBuilder(
        listenable: ModelController.instance,
        builder: (context, _) {
          return ModelController.instance.isModelTwo
              ? const Model2Shell()
              : DashBoard(index: DashBoard.lastIndex);
        },
      ),
    );
  }
}
