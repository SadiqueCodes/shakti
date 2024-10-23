import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart'; // For input formatters
import 'home_page.dart';
import 'login_page.dart'; // To reset back to login page after password reset

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isFirstTime = true;
  String _greetName = "";

  @override
  void initState() {
    super.initState();
    _checkIfLoggedIn();
  }

  Future<void> _checkIfLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isLoggedIn = prefs.getBool('isLoggedIn');
    String? savedName = prefs.getString('name');
    if (isLoggedIn == true && savedName != null) {
      setState(() {
        _isFirstTime = false; // Not first time anymore
        _greetName = savedName; // Greet the user with their name
      });
    }
  }

  Future<void> _saveUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _nameController.text);
    await prefs.setString('password', _passwordController.text);
    await prefs.setBool('isLoggedIn', true); // Mark the user as logged in
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  void _validateAndProceed() {
    if (_isFirstTime) {
      // First time user: name and password are required
      if (_nameController.text.isEmpty || _passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter your name and a 4-digit password')),
        );
      } else if (_passwordController.text.length != 4 || !RegExp(r'^\d{4}$').hasMatch(_passwordController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password must be 4 digits')),
        );
      } else {
        _saveUserData();
      }
    } else {
      // Returning user: only ask for password
      _validateReturningUser();
    }
  }

  Future<void> _validateReturningUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedPassword = prefs.getString('password');

    if (_passwordController.text == savedPassword) {
      // Password is correct, proceed
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Incorrect password. Try again.')),
      );
    }
  }

  Future<void> _forgotPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? securityQuestion = prefs.getString('securityQuestion');
    String? securityAnswer = prefs.getString('securityAnswer');

    if (securityQuestion != null && securityAnswer != null) {
      final TextEditingController _answerController = TextEditingController();

      // Ask for the security question answer
      String? userAnswer = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Forgot Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(securityQuestion),
              TextField(
                controller: _answerController,
                decoration: InputDecoration(labelText: 'Your answer'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(_answerController.text); // Pass the entered answer
              },
              child: Text('Submit'),
            ),
          ],
        ),
      );

      // Check if the entered answer matches the stored security answer
      if (userAnswer == securityAnswer) {
        final TextEditingController _newPasswordController = TextEditingController();
        final TextEditingController _confirmPasswordController = TextEditingController();

        // Allow the user to reset the password
        String? newPassword = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Reset Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _newPasswordController,
                  decoration: InputDecoration(labelText: 'Enter new 4-digit password'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                ),
                TextField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(labelText: 'Re-enter new password'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  if (_newPasswordController.text == _confirmPasswordController.text) {
                    Navigator.of(context).pop(_newPasswordController.text); // Pass the new password
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Passwords do not match')),
                    );
                  }
                },
                child: Text('Reset Password'),
              ),
            ],
          ),
        );

        if (newPassword != null && newPassword.length == 4) {
          await prefs.setString('password', newPassword);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Password has been reset.')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()), // Return to login page
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Password must be 4 digits.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Incorrect answer to the security question.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No security question set.')),
      );
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
            // App logo
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://cdn-icons-png.flaticon.com/512/6174/6174454.png'),
            ),
            SizedBox(height: 30),
            Text(
              _isFirstTime ? 'Welcome to Shakti Mitr!' : 'Welcome back, $_greetName!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 30),
            
            if (_isFirstTime)
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            SizedBox(height: _isFirstTime ? 20 : 0),
            
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: _isFirstTime ? 'Create a 4-digit Password' : 'Enter your 4-digit Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // Only allow numbers
                LengthLimitingTextInputFormatter(4), // Limit to 4 digits
              ],
              obscureText: true, // For password security
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _validateAndProceed, // Validation before proceeding
              child: Text(
                _isFirstTime ? 'Register' : 'Login',
                style: TextStyle(fontSize: 18, fontFamily: 'Poppins'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[700],
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 50),
              ),
            ),
            if (!_isFirstTime) // Show forgot password option only for returning users
              TextButton(
                onPressed: _forgotPassword,
                child: Text('Forgot Password?'),
              ),
          ],
        ),
      ),
    );
  }
}
