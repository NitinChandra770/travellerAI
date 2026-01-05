import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../core/storage/app_preferences.dart';
import '../data/local/traveller.dart';
import '../main.dart';
import '../routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

  Traveller? _currentUser;
  bool _isLoading = true;
  String? _profileImagePath; // Holds the local path (Mobile) or Base64 (Web)

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final mobile = await AppPreferences.getMobileNumber();
    if (mobile != null) {
      try {
        final traveller = travellerBox.values.firstWhere(
          (t) => t.mobile == mobile,
        );
        _currentUser = traveller;
        _nameController.text = traveller.name;
        _ageController.text = traveller.age ?? '';
        _emailController.text = traveller.email ?? '';
        _mobileController.text = traveller.mobile;

        // Load image path/data from Hive object first
        if (traveller.profileImagePath != null) {
          _profileImagePath = traveller.profileImagePath;
        } else {
          // Fallback to SharedPreferences
          final savedPath = await AppPreferences.getProfileImage(mobile);
          if (savedPath != null) {
            if (kIsWeb) {
              // On web, we assume it's valid if not null
              _profileImagePath = savedPath;
            } else {
              // On mobile, check if file exists
              if (File(savedPath).existsSync()) {
                _profileImagePath = savedPath;
              }
            }
          }
        }
      } catch (e) {
        // Handle user not found
      }
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      // Added maxWidth to reduce size for web storage
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        String savedData;

        if (kIsWeb) {
          // WEB: Convert to Base64
          final bytes = await image.readAsBytes();
          savedData = base64Encode(bytes);
        } else {
          // MOBILE: Save to local file
          final directory = await getApplicationDocumentsDirectory();
          final String fileName =
              'profile_${_currentUser?.mobile ?? "user"}_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final String localPath = '${directory.path}/$fileName';
          await File(image.path).copy(localPath);
          savedData = localPath;
        }

        setState(() {
          _profileImagePath = savedData;
        });

        // Save immediately
        await _saveProfileImageToDb(savedData);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to capture image: $e")));
      }
    }
  }

  void _removeImage() async {
    setState(() {
      _profileImagePath = null;
    });

    // Remove immediately
    await _removeProfileImageFromDb();
  }

  Future<void> _saveProfileImageToDb(String pathOrData) async {
    if (_currentUser != null) {
      // 1. Save to Hive
      _currentUser!.profileImagePath = pathOrData;
      await _currentUser!.save();
      debugPrint("Immediate Save: Image saved to Hive.");

      // 2. Save to AppPreferences
      await AppPreferences.setProfileImage(_currentUser!.mobile, pathOrData);
    }
  }

  Future<void> _removeProfileImageFromDb() async {
    if (_currentUser != null) {
      // 1. Remove from Hive
      _currentUser!.profileImagePath = null;
      await _currentUser!.save();
      debugPrint("Immediate Save: Image removed from Hive.");

      // 2. Remove from AppPreferences
      await AppPreferences.removeProfileImage(_currentUser!.mobile);
    }
  }

  void _saveUserData() async {
    if (_currentUser != null) {
      _currentUser!.name = _nameController.text;
      _currentUser!.age = _ageController.text;
      _currentUser!.email = _emailController.text;

      await _currentUser!.save();

      debugPrint("Traveller Data Saved: ${_currentUser.toString()}");

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
                "Profile updated successfully!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
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
  }

  void _goToPreferences() async {
    final mobile = await AppPreferences.getMobileNumber();
    if (mobile != null && mounted) {
      Navigator.pushNamed(context, Routes.preference, arguments: mobile);
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await AppPreferences.logout();

              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.login,
                  (route) => false,
                );
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.indigo),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          filled: true,
          fillColor: readOnly ? Colors.grey.shade200 : Colors.white,
        ),
      ),
    );
  }

  ImageProvider _getProfileImageProvider() {
    if (_profileImagePath == null) {
      return const AssetImage('assets/images/app_logo.png');
    }

    if (kIsWeb) {
      try {
        return MemoryImage(base64Decode(_profileImagePath!));
      } catch (e) {
        debugPrint('Error decoding base64 image: $e');
        return const AssetImage('assets/images/app_logo.png');
      }
    } else {
      return FileImage(File(_profileImagePath!));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Circular Avatar with Upload and Remove Icons
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.indigo.shade100,
                    backgroundImage: _getProfileImageProvider(),
                  ),
                  // Camera Icon
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.indigo,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      onPressed: _pickImage,
                    ),
                  ),
                  // Delete Icon (Only show if image exists)
                  if (_profileImagePath != null)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _removeImage,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Editable Fields
            _buildTextField(
              controller: _nameController,
              label: "Full Name",
              icon: Icons.person,
            ),
            _buildTextField(
              controller: _ageController,
              label: "Age",
              icon: Icons.calendar_today,
              keyboardType: TextInputType.number,
            ),
            _buildTextField(
              controller: _emailController,
              label: "Email",
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            _buildTextField(
              controller: _mobileController,
              label: "Mobile Number",
              icon: Icons.phone,
              readOnly: true,
            ),

            const SizedBox(height: 20),

            // Edit Preferences Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _goToPreferences,
                icon: const Icon(Icons.settings),
                label: const Text('Edit Travel Preferences'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  side: const BorderSide(color: Colors.indigo),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveUserData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                child: const Text('Save', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
