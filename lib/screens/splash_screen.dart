import 'package:flutter/material.dart';

import '../core/storage/app_preferences.dart';
import '../main.dart'; // To access travellerBox
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
    final mobileNumber = await AppPreferences.getMobileNumber();

    if (!mounted) return;

    if (isLoggedIn && mobileNumber != null) {
      // Logic to check if preferences are set
      final traveller = travellerBox.values
          .where((t) => t.mobile == mobileNumber)
          .firstOrNull;

      if (traveller != null) {
        if (traveller.isPreferenceSet) {
          Navigator.pushReplacementNamed(context, Routes.dashboard);
        } else {
          // If logged in but preferences not set, go to preference screen
          Navigator.pushReplacementNamed(
            context,
            Routes.preference,
            arguments: mobileNumber,
          );
        }
      } else {
        // Fallback if data inconsistent
        Navigator.pushReplacementNamed(context, Routes.login);
      }
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
              'assets/images/app_logo.png',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            const Text(
              'Traveller AI',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const Text('Your intelligent travel companion'),
          ],
        ),
      ),
    );
  }
}
