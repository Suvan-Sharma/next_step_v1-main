import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _age;
  String? _city;
  String? _state;
  String? _role;

  final List<String> _ages = List.generate(33, (i) => (i + 18).toString());

  // All cities with state codes, used to filter by selected state
  final List<String> _allCities = [
    'New York, NY',
    'Los Angeles, CA',
    'Chicago, IL',
    'Houston, TX',
    'Phoenix, AZ',
    'Philadelphia, PA',
    'San Antonio, TX',
    'San Diego, CA',
    'Dallas, TX',
    'San Jose, CA',
    'Austin, TX',
    'Jacksonville, FL',
    'San Francisco, CA',
    'Columbus, OH',
    'Fort Worth, TX',
    'Indianapolis, IN',
    'Charlotte, NC',
    'Seattle, WA',
    'Denver, CO',
    'Washington, DC',
    'Boston, MA',
    'El Paso, TX',
    'Nashville, TN',
    'Detroit, MI',
    'Oklahoma City, OK',
    'Portland, OR',
    'Las Vegas, NV',
    'Memphis, TN',
    'Louisville, KY',
    'Baltimore, MD',
    'Milwaukee, WI',
    'Albuquerque, NM',
    'Tucson, AZ',
    'Fresno, CA',
    'Mesa, AZ',
    'Sacramento, CA',
    'Atlanta, GA',
    'Kansas City, MO',
    'Colorado Springs, CO',
    'Miami, FL',
    'Raleigh, NC',
    'Omaha, NE',
    'Long Beach, CA',
    'Virginia Beach, VA',
    'Oakland, CA',
    'Minneapolis, MN',
    'Tulsa, OK',
    'Arlington, TX',
    'Tampa, FL',
    'New Orleans, LA',
    'Honolulu, HI',
    'Anchorage, AK',
    'Other'
  ];

  final List<String> _states = [
    'Alabama (AL)',
    'Alaska (AK)',
    'Arizona (AZ)',
    'Arkansas (AR)',
    'California (CA)',
    'Colorado (CO)',
    'Connecticut (CT)',
    'Delaware (DE)',
    'District of Columbia (DC)',
    'Florida (FL)',
    'Georgia (GA)',
    'Hawaii (HI)',
    'Idaho (ID)',
    'Illinois (IL)',
    'Indiana (IN)',
    'Iowa (IA)',
    'Kansas (KS)',
    'Kentucky (KY)',
    'Louisiana (LA)',
    'Maine (ME)',
    'Maryland (MD)',
    'Massachusetts (MA)',
    'Michigan (MI)',
    'Minnesota (MN)',
    'Mississippi (MS)',
    'Missouri (MO)',
    'Montana (MT)',
    'Nebraska (NE)',
    'Nevada (NV)',
    'New Hampshire (NH)',
    'New Jersey (NJ)',
    'New Mexico (NM)',
    'New York (NY)',
    'North Carolina (NC)',
    'North Dakota (ND)',
    'Ohio (OH)',
    'Oklahoma (OK)',
    'Oregon (OR)',
    'Pennsylvania (PA)',
    'Rhode Island (RI)',
    'South Carolina (SC)',
    'South Dakota (SD)',
    'Tennessee (TN)',
    'Texas (TX)',
    'Utah (UT)',
    'Vermont (VT)',
    'Virginia (VA)',
    'Washington (WA)',
    'West Virginia (WV)',
    'Wisconsin (WI)',
    'Wyoming (WY)',
    'Other'
  ];
    
  final List<String> _roles = ['Student', 'Professional', 'Mentor', 'Other'];

  // Extract state code from label like "California (CA)" => "CA"
  String? _extractStateCode(String? stateLabel) {
    if (stateLabel == null) return null;
    final int open = stateLabel.indexOf('(');
    final int close = stateLabel.indexOf(')');
    if (open != -1 && close != -1 && close > open + 1) {
      return stateLabel.substring(open + 1, close);
    }
    return null;
  }

  // Display helpers to hide trailing state codes in UI
  String _displayState(String value) {
    if (value == 'Other') return value;
    return value.replaceAll(RegExp(r"\s*\([A-Z]{2}\)$"), '');
  }

  String _displayCity(String value) {
    if (value == 'Other') return value;
    return value.replaceAll(RegExp(r",\s*[A-Z]{2}$"), '');
  }

  List<String> get _filteredCities {
    if (_state == null) return const [];
    if (_state == 'Other') return const ['Other'];
    final String? code = _extractStateCode(_state);
    if (code == null) return const ['Other'];
    final List<String> matches = _allCities
        .where((c) => c.endsWith(', $code'))
        .toList()
      ..sort();
    if (matches.isEmpty) {
      return const ['Other'];
    }
    return [...matches, 'Other'];
  }

  Future<String?> _showSearchSelectSheet({
    required String title,
    required List<String> options,
    String? initialValue,
    String Function(String)? labelBuilder,
  }) async {
    return await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        String query = '';
        List<String> filtered = List.of(options);
        return StatefulBuilder(
          builder: (context, setModalState) {
            void updateFilter(String q) {
              setModalState(() {
                query = q;
                final String qLower = q.toLowerCase();
                filtered = options
                    .where((o) {
                      final String label = (labelBuilder?.call(o) ?? o).toLowerCase();
                      return o.toLowerCase().contains(qLower) || label.contains(qLower);
                    })
                    .toList();
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: query.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => updateFilter(''),
                            ),
                      filled: true,
                      fillColor: const Color(0xFFF7F7F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    ),
                    onChanged: updateFilter,
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 360),
                    child: filtered.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Text('No results'),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final String option = filtered[index];
                              final String label = labelBuilder?.call(option) ?? option;
                              final bool selected = option == initialValue;
                              return ListTile(
                                title: Text(label),
                                trailing: selected
                                    ? const Icon(Icons.check, color: Colors.blue)
                                    : null,
                                onTap: () => Navigator.pop(context, option),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveData() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      
      // Save profile data
      await prefs.setString('name', _nameController.text);
      await prefs.setString('age', _age ?? '');
      await prefs.setString('state', _state ?? '');
      await prefs.setString('city', _city ?? '');
      await prefs.setString('role', _role ?? '');
      
      // Mark user as fully registered (no longer needs password change)
      await prefs.setBool('needsPasswordChange', false);
      await prefs.remove('temporaryPassword');
      
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // Header Section
                  const Center(
                    child: Column(
                      children: [
                        Text(
                          "Tell us about yourself",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Help others get to know you better",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Form Fields with Card Design
                  _buildFormField(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      validator: (val) => val!.isEmpty ? 'Enter your name' : null,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildFormField(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                        suffixIcon: Padding(
                          padding: EdgeInsets.only(right: 0),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: Color(0xFFD2691E),
                            size: 24,
                          ),
                        ),
                        suffixIconConstraints: BoxConstraints(minWidth: 24, minHeight: 24),
                      ),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      value: _age,
                      items: _ages
                          .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                          .toList(),
                      onChanged: (val) => setState(() => _age = val),
                      validator: (val) => val == null ? 'Select your age' : null,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildFormField(
                    child: FormField<String>(
                      validator: (val) => (_state == null) ? 'Select your state' : null,
                      builder: (fieldState) {
                        return InkWell(
                          onTap: () async {
                            final String? selected = await _showSearchSelectSheet(
                              title: 'Select State',
                              options: _states,
                              initialValue: _state,
                              labelBuilder: _displayState,
                            );
                            if (selected != null) {
                              setState(() {
                                _state = selected;
                                _city = null; // reset city when state changes
                              });
                              fieldState.didChange(selected);
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'State',
                              labelStyle: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                              hintText: 'Select your state',
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 16),
                              suffixIcon: Padding(
                                padding: EdgeInsets.only(right: 0),
                                child: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Color(0xFFD2691E),
                                  size: 24,
                                ),
                              ),
                              suffixIconConstraints: BoxConstraints(minWidth: 24, minHeight: 24),
                            ),
                            isEmpty: _state == null,
                            child: _state == null
                                ? const SizedBox.shrink()
                                : Text(
                                    _displayState(_state!),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildFormField(
                    child: FormField<String>(
                      validator: (val) => (_city == null) ? 'Select your city' : null,
                      builder: (fieldState) {
                        final List<String> cityOptions = _filteredCities;
                        return InkWell(
                          onTap: () async {
                            if (_state == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please select a state first')),
                              );
                              return;
                            }
                            final String? selected = await _showSearchSelectSheet(
                              title: 'Select City',
                              options: cityOptions,
                              initialValue: _city,
                              labelBuilder: _displayCity,
                            );
                            if (selected != null) {
                              setState(() {
                                _city = selected;
                              });
                              fieldState.didChange(selected);
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'City',
                              labelStyle: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                              hintText: 'Select your city',
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 16),
                              suffixIcon: Padding(
                                padding: EdgeInsets.only(right: 0),
                                child: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Color(0xFFD2691E),
                                  size: 24,
                                ),
                              ),
                              suffixIconConstraints: BoxConstraints(minWidth: 24, minHeight: 24),
                            ),
                            isEmpty: _city == null,
                            child: _city == null
                                ? const SizedBox.shrink()
                                : Text(
                                    _displayCity(_city!),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildFormField(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                        suffixIcon: Padding(
                          padding: EdgeInsets.only(right: 0),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: Color(0xFFD2691E),
                            size: 24,
                          ),
                        ),
                        suffixIconConstraints: BoxConstraints(minWidth: 24, minHeight: 24),
                      ),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      value: _role,
                      items: _roles
                          .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                          .toList(),
                      onChanged: (val) => setState(() => _role = val),
                      validator: (val) => val == null ? 'Select your role' : null,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Continue",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: child,
      ),
    );
  }
}
