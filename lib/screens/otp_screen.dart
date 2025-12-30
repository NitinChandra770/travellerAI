import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../routes.dart';

class OtpScreen extends StatefulWidget {
  final String mobileNumber;
  const OtpScreen({super.key, required this.mobileNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isButtonEnabled = false;
  String? _errorMessage;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _validateInput(String value) {
    setState(() {
      _isButtonEnabled = value.length == 6;
      if (value.isNotEmpty && value.length < 6) {
        _errorMessage = "Please enter valid OTP";
      } else {
        _errorMessage = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Otp Verification")),
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
                const SizedBox(height: 20),
                Text(
                  'Please enter the OTP sent to +91 ${widget.mobileNumber}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                const Text("Enter Otp", style: TextStyle(fontSize: 24)),
                const SizedBox(height: 35),
                TextField(
                  controller: _otpController,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: _validateInput,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    counterText: "",
                    hintText: "Enter 6 digits",
                    errorText: _errorMessage,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: _isButtonEnabled
                      ? () {
                          Navigator.pushNamed(
                            context,
                            Routes.signup,
                            arguments: widget.mobileNumber,
                          );
                        }
                      : null,
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
                  child: const Text(
                    "Submit OTP",
                    style: TextStyle(fontSize: 24),
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
