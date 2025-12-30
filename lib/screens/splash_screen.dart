import 'package:flutter/material.dart';
import '../core/storage/app_preferences.dart';
import '../routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    // Optional splash delay
    await Future.delayed(const Duration(seconds: 2));

    // Check login state
    final isLoggedIn = await AppPreferences.isLoggedIn();

    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, Routes.dashboard);
    } else {
      Navigator.pushReplacementNamed(context, Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 180,
              height: 180,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            const Text(
              'Traveller AI',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
