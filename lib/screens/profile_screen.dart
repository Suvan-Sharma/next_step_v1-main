import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/widgets/custom_app_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  String? _age;
  String? _city;
  String? _state;
  String? _role;

  final List<String> _ages = List.generate(33, (i) => (i + 18).toString());
  final List<String> _roles = const ['Student', 'Professional', 'Mentor', 'Other'];

  // Full lists aligned with registration options
  final List<String> _states = const [
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

  final List<String> _cities = const [
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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedAge = prefs.getString('age');
    final String? savedState = prefs.getString('state');
    final String? savedCity = prefs.getString('city');
    final String? savedRole = prefs.getString('role');
    _nameController.text = prefs.getString('name') ?? '';
    setState(() {
      _age = _ages.contains(savedAge) ? savedAge : null;
      _state = _states.contains(savedState) ? savedState : null;
      _city = _cities.contains(savedCity) ? savedCity : null;
      _role = _roles.contains(savedRole) ? savedRole : null;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _nameController.text.trim());
    await prefs.setString('age', _age ?? '');
    await prefs.setString('state', _state ?? '');
    await prefs.setString('city', _city ?? '');
    await prefs.setString('role', _role ?? '');
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Profile'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _card(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      validator: (val) => (val == null || val.trim().isEmpty)
                          ? 'Enter your name'
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _card(
                    child: DropdownButtonFormField<String>(
                      value: _age,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      items: _ages
                          .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                          .toList(),
                      onChanged: (v) => setState(() => _age = v),
                      validator: (v) => v == null ? 'Select your age' : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _card(
                    child: DropdownButtonFormField<String>(
                      value: _state,
                      decoration: const InputDecoration(
                        labelText: 'State',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      items: _states
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) => setState(() => _state = v),
                      validator: (v) => v == null ? 'Select your state' : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _card(
                    child: DropdownButtonFormField<String>(
                      value: _city,
                      decoration: const InputDecoration(
                        labelText: 'City',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      items: _cities
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => _city = v),
                      validator: (v) => v == null ? 'Select your city' : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _card(
                    child: DropdownButtonFormField<String>(
                      value: _role,
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      items: _roles
                          .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                          .toList(),
                      onChanged: (v) => setState(() => _role = v),
                      validator: (v) => v == null ? 'Select your role' : null,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006EDA),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
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