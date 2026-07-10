import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'country_list.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();

  double _age = 25;
  String? _country; // nullable for safety
  List<String> _countries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  // 🔥 Initialize everything cleanly
  Future<void> _initData() async {
    await _loadCountries();
    await _loadUserData();

    setState(() {
      _isLoading = false;
    });
  }

  // ✅ Load local countries
  Future<void> _loadCountries() async {
    try {
      _countries = await fetchCountries();
    } catch (e) {
      _showToast('Error loading countries');
    }
  }

  // ✅ Load saved data
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _nameController.text = prefs.getString('name') ?? '';
    _usernameController.text = prefs.getString('username') ?? '';
    _age = prefs.getDouble('age') ?? 25;

    String savedCountry =
        prefs.getString('country') ?? 'United States';

    // Ensure country exists in list
    if (_countries.contains(savedCountry)) {
      _country = savedCountry;
    } else {
      _country = _countries.isNotEmpty ? _countries[0] : null;
    }
  }

  // ✅ Save data
  Future<void> _saveUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('name', _nameController.text);
    await prefs.setString('username', _usernameController.text);
    await prefs.setDouble('age', _age);
    await prefs.setString('country', _country ?? '');

    Fluttertoast.showToast(
      msg: "Profile updated successfully",
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );

    Navigator.pop(context, _nameController.text);
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 Loading screen
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: const Text('Personal Info'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 30),

            _buildTextField(
              controller: _nameController,
              label: 'Name',
              icon: Icons.person,
            ),

            const SizedBox(height: 16),

            _buildTextField(
              controller: _usernameController,
              label: 'Username',
              icon: Icons.alternate_email,
            ),

            const SizedBox(height: 20),

            Text(
              'Age: ${_age.round()}',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 18,
              ),
            ),

            Slider(
              value: _age,
              min: 18,
              max: 100,
              divisions: 82,
              activeColor: Colors.blue,
              onChanged: (value) {
                setState(() => _age = value);
              },
            ),

            const SizedBox(height: 20),

            // 🌍 Country Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<String>(
                value: _country,
                isExpanded: true,
                underline: const SizedBox(),
                hint: const Text("Select Country"),
                items: _countries.map((country) {
                  return DropdownMenuItem(
                    value: country,
                    child: Text(country),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _country = value);
                },
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _saveUserData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                padding:
                    const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Save Changes',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Reusable TextField
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.blue),
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // 🔹 Toast
  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }
}
