import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'login_page.dart';
import 'package:flutter/services.dart'; // To format date

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _securityAnswerController = TextEditingController();
  File? _profileImage;
  final picker = ImagePicker();
  String _age = '';
  String _selectedSecurityQuestion = 'Pet Name'; // Default security question
  String _errorText = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('name') ?? '';
      _dobController.text = prefs.getString('dob') ?? '';
      _selectedSecurityQuestion = prefs.getString('securityQuestion') ?? 'Pet Name'; // Default to Pet Name
      _securityAnswerController.text = prefs.getString('securityAnswer') ?? '';
      String? profilePicPath = prefs.getString('profilePic');
      if (profilePicPath != null) {
        _profileImage = File(profilePicPath);
      }
      _age = _calculateAge(_dobController.text);
    });
  }

  String _calculateAge(String dob) {
    if (dob.isEmpty) return '';
    final parts = dob.split('/');
    if (parts.length != 3) return '';
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return '';
    final dobDate = DateTime(year, month, day);
    final now = DateTime.now();
    final age = now.year - dobDate.year;
    if (now.month < month || (now.month == month && now.day < day)) {
      return (age - 1).toString();
    }
    return age.toString();
  }

  Future<void> _updateUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _nameController.text);
    await prefs.setString('dob', _dobController.text);
    await prefs.setString('securityQuestion', _selectedSecurityQuestion);
    await prefs.setString('securityAnswer', _securityAnswerController.text);
    if (_profileImage != null) {
      await prefs.setString('profilePic', _profileImage!.path);
    }
    Navigator.pop(context);
  }

  Future<void> _deleteAccount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _validateDate(String value) {
    final parts = value.split('/');
    if (parts.length != 3) {
      setState(() {
        _errorText = 'Please enter a valid date format (dd/mm/yyyy)';
      });
      return;
    }
    
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    // Clear error if the value is correct
    if (day != null && month != null && year != null && _isValidDate(day, month, year)) {
      setState(() {
        _errorText = ''; // Clear error if the date is valid
        _age = _calculateAge(value);
      });
    } else {
      setState(() {
        _errorText = 'Please enter a valid date (dd: 1-31, mm: 1-12)';
      });
    }
  }

  bool _isValidDate(int day, int month, int year) {
    if (month < 1 || month > 12 || day < 1) {
      return false;
    }

    // Check for the number of days in the month
    int daysInMonth;
    if (month == 2) {
      // Check for leap year
      daysInMonth = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0) ? 29 : 28;
    } else {
      daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][month - 1];
    }

    return day <= daysInMonth;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.pink,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _dobController,
              decoration: InputDecoration(
                labelText: 'Date of Birth (dd/mm/yyyy)',
                errorText: _errorText.isNotEmpty ? _errorText : null,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10), // Adjusted for DD/MM/YYYY format
                _DateFormatter(), // Custom date formatter to add '/'
              ],
              onChanged: _validateDate,
            ),
            SizedBox(height: 20),
            TextField(
              readOnly: true,
              decoration: InputDecoration(labelText: 'Age', hintText: _age),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedSecurityQuestion,
              items: [
                DropdownMenuItem(child: Text("Pet Name"), value: "Pet Name"),
                DropdownMenuItem(child: Text("Favorite Movie"), value: "Favorite Movie"),
                DropdownMenuItem(child: Text("Favorite Book"), value: "Favorite Book"),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedSecurityQuestion = value!;
                });
              },
              decoration: InputDecoration(labelText: 'Select Security Question'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _securityAnswerController,
              decoration: InputDecoration(labelText: 'Security Answer'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateUserData,
              child: Text('Update'),
            ),
            ElevatedButton(
              onPressed: _deleteAccount,
              child: Text('Delete Account'),
              
            ),
          ],
        ),
      ),
    );
  }
}

// Custom InputFormatter to automatically add '/' when entering date
class _DateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    // If the user is deleting, allow backspacing over the slash
    if (oldValue.text.length > text.length) {
      return TextEditingValue(
        text: text,
        selection: newValue.selection.copyWith(
          baseOffset: text.length,
          extentOffset: text.length,
        ),
      );
    }

    // Remove any existing slashes to reformat the input
    text = text.replaceAll('/', '');

    // Add slashes after day and month
    if (text.length >= 2) {
      text = text.substring(0, 2) + '/' + (text.length > 2 ? text.substring(2) : '');
    }
    if (text.length >= 5) {
      text = text.substring(0, 5) + '/' + (text.length > 5 ? text.substring(5) : '');
    }

    return TextEditingValue(
      text: text,
      selection: newValue.selection.copyWith(
        baseOffset: text.length,
        extentOffset: text.length,
      ),
    );
  }
}
