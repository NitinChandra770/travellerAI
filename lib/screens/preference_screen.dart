import 'package:flutter/material.dart';

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

  final List<String> _travelTypes = ['Car', 'Bike', 'Bus', 'Train', 'Flight'];

  // Map of Categories to Sub-Interests
  final Map<String, List<String>> _interestOptions = {
    'Food & Lifestyle': [
      'Local Cuisine',
      'Street Food',
      'Fine Dining',
      'Vegan/Vegetarian',
      'Cafe Hopping',
    ],
    'Nature & Outdoors': [
      'Mountains',
      'Beaches',
      'Forests',
      'Deserts',
      'Wildlife',
      'WaterFalls',
      'Dams',
    ],
    'Spiritual & Heritage': [
      'Temples/Places of Worship',
      'Historical Monuments',
    ],
    'Family & Companions': [
      'Kid-Friendly',
      'Couples/Romantic',
      'Group Tours',
      'Pet-Friendly',
    ],
    'Adventure & Activities': ['Trekking', 'Water Sports', 'Camping', 'Safari'],
    'Culture & Experiences': [
      'Museums',
      'Art Galleries',
      'Local Workshops',
      'Music & Dance',
    ],
    'Leisure & Relaxation': [
      'Spa & Wellness',
      'Luxury Resorts',
      'Cruises',
      'Staycations',
    ],
    'Shopping & Local Life': [
      'Local Markets',
      'Malls',
      'Handicrafts',
      'Nightlife',
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() {
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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Travel Type",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
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
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ..._interestOptions.entries.map((entry) {
                      final category = entry.key;
                      final subOptions = entry.value;

                      final int selectedCount = subOptions
                          .where((sub) => _selectedInterests.contains(sub))
                          .length;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: selectedCount > 0
                                ? const BorderSide(
                                    color: Colors.indigo,
                                    width: 1.5,
                                  )
                                : BorderSide.none,
                          ),
                          child: ExpansionTile(
                            title: Text(
                              category,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: selectedCount > 0
                                    ? Colors.indigo
                                    : Colors.black,
                              ),
                            ),
                            subtitle: selectedCount > 0
                                ? Text(
                                    "$selectedCount selected",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  )
                                : null,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: subOptions.map((subInterest) {
                                    final isSelected = _selectedInterests
                                        .contains(subInterest);
                                    return FilterChip(
                                      label: Text(subInterest),
                                      selected: isSelected,
                                      selectedColor: Colors.indigo.shade100,
                                      checkmarkColor: Colors.indigo,
                                      onSelected: (selected) {
                                        setState(() {
                                          if (selected) {
                                            _selectedInterests.add(subInterest);
                                          } else {
                                            _selectedInterests.remove(
                                              subInterest,
                                            );
                                          }
                                        });
                                        _validateSelection();
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    // Added extra padding at bottom to ensure last item isn't hidden behind button if we overlap (though here we separate them)
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            // Fixed Submit Button at the bottom
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
