import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'package:flutter/services.dart'; // For TextInputFormatter

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoginMode = true; // Toggle between login and register

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

  Future<void> _registerUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _nameController.text);
    await prefs.setString('email', _emailController.text);
    await prefs.setString('password', _passwordController.text);
    await prefs.setString('securityAnswer', "mySecurityAnswer"); // Hardcoded for simplicity
    await prefs.setString('securityQuestion', "Pet Name"); // Assuming a default security question
    await prefs.setBool('isLoggedIn', true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  Future<void> _loginUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedEmail = prefs.getString('email');
    String? savedPassword = prefs.getString('password');

    if (_emailController.text == savedEmail && _passwordController.text == savedPassword) {
      await prefs.setBool('isLoggedIn', true);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Incorrect email or password.')),
      );
    }
  }

  // Email validation regex
  bool _isValidEmail(String email) {
    String pattern =
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(email);
  }

  void _validateAndProceed() {
    if (_emailController.text.isEmpty ||
        !_isValidEmail(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid email address.')),
      );
      return;
    }

    if (_isLoginMode) {
      _loginUser();
    } else {
      if (_nameController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty) {
        _registerUser();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('All fields are required.')),
        );
      }
    }
  }

  // Forgot Password Dialog
  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _emailForPasswordReset = TextEditingController();
        return AlertDialog(
          title: Text("Forgot Password"),
          content: TextField(
            controller: _emailForPasswordReset,
            decoration: InputDecoration(labelText: "Enter your email"),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String? savedEmail = prefs.getString('email');
                if (_emailForPasswordReset.text == savedEmail) {
                  Navigator.of(context).pop();
                  _showSecurityQuestionDialog();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Email not registered.")),
                  );
                }
              },
              child: Text("Verify"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  // Show Security Question
  void _showSecurityQuestionDialog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedSecurityQuestion = prefs.getString('securityQuestion') ?? 'Pet Name'; // Fetch the saved security question
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _securityAnswerController = TextEditingController();
        return AlertDialog(
          title: Text("Security Question"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Question: $savedSecurityQuestion"), // Display the user's saved security question
              TextField(
                controller: _securityAnswerController,
                decoration: InputDecoration(labelText: "Enter your answer"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String? savedSecurityAnswer = prefs.getString('securityAnswer');
                
                if (_securityAnswerController.text == savedSecurityAnswer) {
                  Navigator.of(context).pop();
                  _showResetPasswordDialog();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Incorrect answer.")),
                  );
                }
              },
              child: Text("Verify"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  // Show Reset Password Dialog
  void _showResetPasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _newPasswordController = TextEditingController();
        return AlertDialog(
          title: Text("Reset Password"),
          content: TextField(
            controller: _newPasswordController,
            decoration: InputDecoration(labelText: "Enter new password"),
            obscureText: true,
          ),
          actions: [
            TextButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString('password', _newPasswordController.text);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Password updated successfully.")),
                );
                Navigator.of(context).pop();
              },
              child: Text("Update Password"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
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
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://cdn-icons-png.flaticon.com/512/6174/6174454.png'),
            ),
            SizedBox(height: 30),
            Text(
              _isLoginMode ? 'Welcome Back!' : 'Create an Account',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            if (!_isLoginMode)
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _validateAndProceed,
              child: Text(_isLoginMode ? 'Login' : 'Register'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLoginMode = !_isLoginMode;
                });
              },
              child: Text(
                _isLoginMode ? "Don't have an account? Register" : "Already have an account? Login",
              ),
            ),
            if (_isLoginMode)
              TextButton(
                onPressed: _showForgotPasswordDialog,
                child: Text("Forgot Password?"),
              ),
          ],
        ),
      ),
    );
  }
}
