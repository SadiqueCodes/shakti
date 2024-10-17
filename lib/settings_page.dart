import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'login_page.dart'; // Assuming you have a login page

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  File? _profileImage;
  final picker = ImagePicker();
  String _age = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('name') ?? ''; // Since name and username are the same
      _dobController.text = prefs.getString('dob') ?? ''; // Load DOB
      String? profilePicPath = prefs.getString('profilePic');
      if (profilePicPath != null) {
        _profileImage = File(profilePicPath);
      }
      _age = _calculateAge(_dobController.text); // Calculate age
    });
  }

  String _calculateAge(String dob) {
    if (dob.isEmpty) return '';

    final parts = dob.split('/');
    if (parts.length != 3) return ''; // Invalid format

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) return '';

    final dobDate = DateTime(year, month, day);
    final now = DateTime.now();
    final age = now.year - dobDate.year;

    // Adjust if the birthday hasn't occurred yet this year
    if (now.month < month || (now.month == month && now.day < day)) {
      return (age - 1).toString();
    }

    return age.toString();
  }

  Future<void> _updateUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _nameController.text); // Saving the name as the username
    await prefs.setString('dob', _dobController.text); // Saving the date of birth
    if (_profileImage != null) {
      await prefs.setString('profilePic', _profileImage!.path);
    }
    Navigator.pop(context);
  }

  Future<void> _changeProfileImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _deleteAccount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clears all saved data
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()), // Takes user back to login page
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(fontFamily: 'Poppins')),
        backgroundColor: Colors.pink,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Image Section
              GestureDetector(
                onTap: _changeProfileImage, // Allow changing profile picture
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : AssetImage('assets/default_user.jpg') as ImageProvider,
                ),
              ),
              SizedBox(height: 20),
              // Name Field
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name', // Since name and username are the same
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Date of Birth Field
              TextField(
                controller: _dobController,
                decoration: InputDecoration(
                  labelText: 'Date of Birth (dd/mm/yyyy)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _age = _calculateAge(value); // Update age on DOB change
                  });
                },
              ),
              SizedBox(height: 20),
              // Age Display Field
              TextField(
                readOnly: true, // Make it read-only since the age is calculated
                decoration: InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  hintText: _age, // Show calculated age
                ),
              ),
              SizedBox(height: 20),
              // Update Button
              ElevatedButton(
                onPressed: _updateUserData,
                child: Text('Update', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
              ),
              SizedBox(height: 20),
              // Delete Account Button
              ElevatedButton(
                onPressed: _deleteAccount,
                child: Text('Delete Account', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
