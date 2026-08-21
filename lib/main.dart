// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart' show DeviceOrientation, SystemChrome;
import 'package:http/http.dart' as http; // For HTTP requests
import 'package:udghosh/DashBoard/pages/dashboard.dart'; // Your dashboard page
import 'package:url_launcher/url_launcher.dart'; // To launch App Store URL

import 'utils.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Handling background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // --- FCM Setup starts here ---
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized ||
      settings.authorizationStatus == AuthorizationStatus.provisional) {
    await messaging.subscribeToTopic('all_users');
    debugPrint('Subscribed to all_users topic');
  }

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('Foreground notification: ${message.notification?.title}');
  });

  // --- FCM Setup ends here ---

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Simple version string - update this manually when releasing new versions

  bool _updateRequired = false;
  bool _isReady = false;
  String _latestVersion = '';

  Future<String> _fetchLatestVersion() async {
    try {
      final response = await http
          .get(
            Uri.parse(
              'https://udghosh-25.github.io/udghosh.org/app_version.txt',
            ),
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

      print('Current version: $appVersion');
      print('Latest version: $_latestVersion');

      // Simple string comparison
      bool updateRequired = appVersion != _latestVersion;

      setState(() {
        _updateRequired = updateRequired;
        _isReady = true;
      });

      if (updateRequired) {
        debugPrint('Update required');
      } else {
        debugPrint('App is up to date');
      }
    } catch (e) {
      debugPrint("Error checking for updates: $e");
      setState(() {
        _updateRequired = false; // Allow access if version check fails
        _isReady = true;
      });
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
                  onPressed: () {
                    setState(() {
                      _isReady = false;
                    });
                    checkForUpdates();
                  },
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
    // Show update screen if update is required, otherwise show main app
    if (_updateRequired) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: _buildUpdateRequiredScreen(),
      );
    }

    // Show main app only if ready and no update required
    if (_isReady) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Udghosh Sports',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 0, 0, 0),
          ),
          useMaterial3: true,
        ),
        home: const DashBoard(index: 0),
      );
    }

    // Show empty container while checking (no loading screen)
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Container(color: const Color.fromARGB(255, 0, 0, 0)),
    );
  }
}
