import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/auth_screen.dart';
import 'screens/dashboard_screen.dart';
import 'theme_design_system.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RewardBrickApp());
}

class RewardBrickApp extends StatefulWidget {
  const RewardBrickApp({super.key});

  @override
  State<RewardBrickApp> createState() => _RewardBrickAppState();
}

class _RewardBrickAppState extends State<RewardBrickApp> {
  late Future<bool> _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = _initializeApp();
  }

  Future<bool> _initializeApp() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    return userId != null && userId.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RewardBrick',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: FutureBuilder<bool>(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _StartupErrorScreen(
              onRetry: () {
                setState(() => _initialization = _initializeApp());
              },
            );
          }
          if (!snapshot.hasData) return const _StartupScreen();
          return snapshot.data! ? const DashboardScreen() : const AuthScreen();
        },
      ),
    );
  }
}

class _StartupScreen extends StatelessWidget {
  const _StartupScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/illustrations/rewardbrick_logo.png',
                  width: 150,
                  height: 112,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 16),
                Text(
                  'RewardBrick',
                  style: TextStyle(
                    color: textDark,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Preparing your rewards...',
                  style: TextStyle(color: textMedium, fontSize: 14),
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: 180,
                  child: LinearProgressIndicator(
                    color: primaryDarkBlue,
                    backgroundColor: primaryLightBlue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StartupErrorScreen extends StatelessWidget {
  final VoidCallback onRetry;

  const _StartupErrorScreen({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_rounded,
                    size: 52, color: textMedium),
                const SizedBox(height: 16),
                const Text(
                  'RewardBrick could not finish starting.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: onRetry,
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
