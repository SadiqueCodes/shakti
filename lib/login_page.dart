import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';  // Firebase Auth import
import 'home_page.dart';  // Your Home Page import

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
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  Future<void> _registerUser() async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'An error occurred.')),
      );
    }
  }

  Future<void> _loginUser() async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'An error occurred.')),
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
                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(
                    email: _emailForPasswordReset.text,
                  );
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Password reset email sent.")),
                  );
                } on FirebaseAuthException catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.message ?? "Error sending reset email")),
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
