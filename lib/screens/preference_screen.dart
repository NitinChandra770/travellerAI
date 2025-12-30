import 'package:flutter/material.dart';

import '../data/local/traveller.dart';
import '../main.dart';
import '../routes.dart';

class PreferenceScreen extends StatefulWidget {
  final String mobileNumber;
  const PreferenceScreen({super.key, required this.mobileNumber});

  @override
  State<PreferenceScreen> createState() => _PreferenceScreenState();
}

class _PreferenceScreenState extends State<PreferenceScreen> {
  String? _selectedTravelType;
  final Set<String> _selectedInterests = {};
  bool _isButtonEnabled = false;

  final List<String> _travelTypes = [
    'Road Trip',
    'Bike',
    'Bus',
    'Train',
    'Flight',
  ];
  final List<String> _interests = [
    'Food',
    'Nature',
    'Temples',
    'Kids',
    'Adventure',
    'Culture',
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() {
    // Fix: Use .where().firstOrNull
    final traveller = travellerBox.values
        .where((t) => t.mobile == widget.mobileNumber)
        .firstOrNull;
    if (traveller != null) {
      setState(() {
        _selectedTravelType = traveller.travelType;
        _selectedInterests.addAll(traveller.interests ?? []);
        _validateSelection();
      });
    }
  }

  void _validateSelection() {
    setState(() {
      _isButtonEnabled =
          _selectedTravelType != null && _selectedInterests.isNotEmpty;
    });
  }

  void _submit() async {
    if (!_isButtonEnabled) return;

    // Fix: Use .where().firstOrNull
    final traveller = travellerBox.values
        .where((t) => t.mobile == widget.mobileNumber)
        .firstOrNull;

    if (traveller != null) {
      traveller.travelType = _selectedTravelType;
      traveller.interests = _selectedInterests.toList();
      traveller.isPreferenceSet = true;
      await traveller.save();

      if (mounted) {
        Navigator.pushReplacementNamed(context, Routes.dashboard);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error: Could not find user data to update."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Set Your Preferences")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Travel Type",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _travelTypes.map((type) {
                  return ChoiceChip(
                    label: Text(type),
                    selected: _selectedTravelType == type,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedTravelType = type;
                        });
                        _validateSelection();
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
              const Text(
                "Interests",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _interests.map((interest) {
                  final isSelected = _selectedInterests.contains(interest);
                  return FilterChip(
                    label: Text(interest),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedInterests.add(interest);
                        } else {
                          _selectedInterests.remove(interest);
                        }
                      });
                      _validateSelection();
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: _isButtonEnabled ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  "Submit",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
