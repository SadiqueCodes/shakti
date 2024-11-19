import 'package:flutter/material.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'services/auth_service.dart';
import 'settings_page.dart';
import 'emergency_contact_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool isLoggedIn = await AuthService.isLoggedIn(); // Check if the user is logged in
  runApp(MyApp(isLoggedIn: isLoggedIn)); // Pass the login status to MyApp
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LiveSafe App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink, // Set the app's primary theme color
      ),
      // Conditionally show either HomePage or LoginPage based on login status
      home: isLoggedIn ? HomePage() : LoginPage(),
      routes: {
        '/settings': (context) => SettingsPage(),
        // Pass the update function for emergency contacts to EmergencyContactPage
        '/emergency_contact': (context) => EmergencyContactPage(
          onContactsUpdated: (contacts) {
            // Handle the updated contacts here, possibly notify HomePage
            print("Emergency contacts updated: $contacts");
          },
        ),
      },
    );
  }
}
