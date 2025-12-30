import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/storage/app_preferences.dart';
import '../main.dart';
import '../routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _mobileController = TextEditingController();
  bool _isButtonEnabled = false;
  String? _errorMessage;

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  void _validateInput(String value) {
    setState(() {
      _isButtonEnabled = value.length == 10;
      if (value.isNotEmpty && value.length < 10) {
        _errorMessage = "Please enter valid mobile number";
      } else {
        _errorMessage = null;
      }
    });
  }

  void _login() async {
    final mobile = _mobileController.text;
    final traveller = travellerBox.values
        .where((t) => t.mobile == mobile)
        .firstOrNull;

    if (traveller != null) {
      // User exists, save their session
      await AppPreferences.setLoggedIn(true, mobileNumber: mobile);

      if (mounted) {
        if (traveller.isPreferenceSet) {
          // Preferences are set, go straight to the dashboard
          Navigator.pushReplacementNamed(context, Routes.dashboard);
        } else {
          // Preferences not set, go to the preference screen
          Navigator.pushReplacementNamed(
            context,
            Routes.preference,
            arguments: mobile,
          );
        }
      }
    } else {
      // New user, go to OTP screen
      Navigator.pushNamed(context, Routes.otp, arguments: mobile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Align(
          alignment: const Alignment(0.0, -0.4),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Enter Mobile Number",
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 35),
                TextField(
                  controller: _mobileController,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: _validateInput,
                  decoration: InputDecoration(
                    prefixText: "+91 ",
                    counterText: "",
                    hintText: "Enter 10 digits",
                    errorText: _errorMessage,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: _isButtonEnabled ? _login : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: const Text("Login", style: TextStyle(fontSize: 24)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
