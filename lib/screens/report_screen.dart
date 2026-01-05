import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../routes.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  bool _isSubmitEnabled = false; // State variable to track button status
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Add listeners to validate input on every change
    _messageController.addListener(_validateInput);
    _mobileController.addListener(_validateInput);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  void _validateMobileInput(String value) {
    setState(() {
      if (value.isNotEmpty && value.length < 10) {
        _errorMessage = "Please enter valid mobile number";
      } else {
        _errorMessage = null;
      }
    });
  }

  void _validateInput() {
    final mobile = _mobileController.text;
    final message = _messageController.text;

    // Check conditions: mobile must be 10 digits and message not empty
    final isValid = (mobile.length == 10) && (message.trim().isNotEmpty);

    if (_isSubmitEnabled != isValid) {
      setState(() {
        _isSubmitEnabled = isValid;
      });
    }
  }

  Future<void> _submit() async {
    // Double-check validation (though button should be disabled if invalid)
    if (!_isSubmitEnabled) return;

    final messageText = _messageController.text;
    final mobile = _mobileController.text;

    debugPrint("Report Mobile: $mobile");
    debugPrint("Report Message: $messageText");

    // 2. Launch Email App
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'nitinchandra770@gmail.com',
      query:
          'subject=${Uri.encodeComponent('Traveller AI issue report raised by $mobile')}&body=${Uri.encodeComponent(messageText)}',
    );

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        debugPrint('Could not launch email app');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Could not open email app")),
          );
        }
      }
    } catch (e) {
      debugPrint('Error launching email: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error launching email: $e")));
      }
    }

    // 3. Show Success Dialog (after launching email)
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Column(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 50),
                SizedBox(height: 10),
                Text("Success"),
              ],
            ),
            content: const Text(
              "Report submitted successfully!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                onPressed: () {
                  // Close dialog
                  Navigator.pop(context);
                  // Go back to login screen (remove all previous routes to be safe)
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    Routes.login,
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Report Issue")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Mobile Number",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _mobileController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              autofocus: true,
              // Autofocus moved here
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: _validateMobileInput,
              decoration: InputDecoration(
                hintText: "Enter 10 digits",
                counterText: "",
                errorText: _errorMessage,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixText: "+91 ",
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Please enter your message inside the box",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _messageController,
              // autofocus: false, // Removed autofocus from here
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Describe your issue here...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitEnabled
                    ? _submit
                    : null, // Disable if invalid
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("Submit", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
