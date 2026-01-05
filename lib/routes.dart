import 'package:flutter/material.dart';

import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/preference_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/report_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/splash_screen.dart';

class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String signup = '/signup';
  static const String dashboard = '/dashboard';
  static const String preference = '/preference';
  static const String report = '/report';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> get all => {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    dashboard: (context) => const DashboardScreen(),
    report: (context) => const ReportScreen(),
    profile: (context) => const ProfileScreen(),
    otp: (context) {
      final mobile = ModalRoute.of(context)!.settings.arguments as String;
      return OtpScreen(mobileNumber: mobile);
    },
    signup: (context) {
      final mobile = ModalRoute.of(context)!.settings.arguments as String;
      return SignupScreen(mobileNumber: mobile);
    },
    preference: (context) {
      final mobile = ModalRoute.of(context)!.settings.arguments as String;
      return PreferenceScreen(mobileNumber: mobile);
    },
  };
}
