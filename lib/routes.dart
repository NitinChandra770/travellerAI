import 'package:flutter/material.dart';
import 'package:my_app/screens/dashboard_screen.dart';
import 'package:my_app/screens/login_screen.dart';
import 'package:my_app/screens/otp_screen.dart';
import 'package:my_app/screens/preference_screen.dart';
import 'package:my_app/screens/signup_screen.dart';
import 'package:my_app/screens/splash_screen.dart';

class Routes {
  static const splash = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const otp = '/otp';
  static const preference = '/preference';
  static const dashboard = '/dashboard';

  static final all = <String, WidgetBuilder>{
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    signup: (context) {
      final mobileNumber = ModalRoute.of(context)!.settings.arguments as String;
      return SignupScreen(mobileNumber: mobileNumber);
    },
    otp: (context) {
      final mobileNumber = ModalRoute.of(context)!.settings.arguments as String;
      return OtpScreen(mobileNumber: mobileNumber);
    },
    preference: (context) {
      final mobileNumber = ModalRoute.of(context)!.settings.arguments as String;
      return PreferenceScreen(mobileNumber: mobileNumber);
    },
    dashboard: (context) => const DashboardScreen(),
  };
}
