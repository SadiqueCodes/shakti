import 'package:flutter/material.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'services/auth_service.dart';
import 'settings_page.dart';
import 'emergency_contact_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: FirebaseOptions(
   apiKey: "AIzaSyD9t89mGzQpfVj6dGcqCSofRDfSuAgZuc4",
   appId: "1:854527594466:android:d30c344219b41b697033bb",
   messagingSenderId: "854527594466	",
   projectId: "shakti-f1320",
  
    authDomain: 'shakti-f1320.firebaseapp.com',
    databaseURL: 'https://shakti-f1320-default-rtdb.firebaseio.com',
    storageBucket: 'shakti-f1320.appspot.com',
    ),
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  bool isLoggedIn = await AuthService.isLoggedIn();
  runApp(MyApp(isLoggedIn: isLoggedIn));
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
        primarySwatch: Colors.pink,
      ),
      home: isLoggedIn ? HomePage() : LoginPage(),
      routes: {
        '/settings': (context) => SettingsPage(),
        '/emergency_contact': (context) {
          String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

          // Ensure userId is not empty before passing it
          if (userId.isNotEmpty) {
            return EmergencyContactPage(
              onContactsUpdated: (contacts) {
                print("Emergency contacts updated: $contacts");
              },
              userId: userId, // Pass userId here
            );
          } else {
            // Handle the case where the user is not logged in (optional)
            return LoginPage(); // Redirect to login page if no user is found
          }
        },
      },
    );
  }
}
