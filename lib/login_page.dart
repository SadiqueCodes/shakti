import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'package:flutter/services.dart'; // For input formatters

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Only allow input if it's a valid digit
    if (newValue.text.isEmpty) {
      return TextEditingValue();
    }

    // Remove any non-digit characters
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    StringBuffer formatted = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 2 || i == 4) {
        formatted.write('/');
      }
      formatted.write(digits[i]);
    }

    return TextEditingValue(
      text: formatted.toString(),
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  File? _image;
  final picker = ImagePicker();

  Future<void> _getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedFile!.path);
    });
  }

  Future<void> _saveUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _nameController.text);
    await prefs.setString('dob', _dobController.text);
    if (_image != null) {
      await prefs.setString('profilePic', _image!.path);
    }
    // Mark that user is logged in
    await prefs.setBool('isLoggedIn', true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  @override
  void initState() {
    super.initState();
    _checkIfLoggedIn();
  }

  Future<void> _checkIfLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isLoggedIn = prefs.getBool('isLoggedIn');
    if (isLoggedIn == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  bool _isValidDate(String date) {
    // Check if the date is in the format dd/mm/yyyy
    RegExp regex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (!regex.hasMatch(date)) return false;

    // Further validate the date components
    List<String> parts = date.split('/');
    int day = int.parse(parts[0]);
    int month = int.parse(parts[1]);
    int year = int.parse(parts[2]);

    // Check for valid date
    if (month < 1 || month > 12 || day < 1 || day > 31) return false;
    if ((month == 4 || month == 6 || month == 9 || month == 11) && day > 30) return false;
    if (month == 2) {
      bool leapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
      if ((leapYear && day > 29) || (!leapYear && day > 28)) return false;
    }
    return true;
  }

  void _validateAndLogin() {
    if (_nameController.text.isEmpty || _dobController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter all details to proceed')),
      );
    } else if (!_isValidDate(_dobController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid date of birth (dd/mm/yyyy)')),
      );
    } else {
      _saveUserData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Replace the circle with your logo
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://cdn-icons-png.flaticon.com/512/6174/6174454.png'),
            ),
            SizedBox(height: 30),
            Text(
              'Welcome to Shakti Mitr!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Keeping you safe',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 30),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _dobController,
              decoration: InputDecoration(
                labelText: 'Date of Birth (dd/mm/yyyy)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                suffixIcon: Icon(Icons.cake),
              ),
              keyboardType: TextInputType.number, // Only allow numbers
              inputFormatters: [
                DateInputFormatter(), // Use the custom input formatter
              ],
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _validateAndLogin, // Validation before login
              child: Text(
                'LOGIN',
                style: TextStyle(fontSize: 18, fontFamily: 'Poppins'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[700],
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
