import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class SirenPage extends StatefulWidget {
  final String userId;

  SirenPage({Key? key, required this.userId}) : super(key: key);

  @override
  _SirenPageState createState() => _SirenPageState();
}

class _SirenPageState extends State<SirenPage> {
  bool _isSending = false;
  List<Map<String, String>> emergencyContacts = [];
  late FirebaseMessaging messaging;

  @override
  void initState() {
    super.initState();
    messaging = FirebaseMessaging.instance;
    _loadEmergencyContacts();
  }

  // Load emergency contacts from Firebase
  Future<void> _loadEmergencyContacts() async {
    final DatabaseReference _contactsRef = FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(widget.userId)
        .child('emergencyContacts');

    final DatabaseEvent event = await _contactsRef.once();
    final contactsData = event.snapshot.value;

    if (contactsData != null) {
      final List<Map<String, String>> loadedContacts = [];
      (contactsData as Map).forEach((key, value) {
        loadedContacts.add({
          'name': value['name'],
          'number': value['number'],
        });
      });

      setState(() {
        emergencyContacts = loadedContacts;
      });
    }
  }

  // Send emergency alert with location
  Future<void> _sendEmergencyAlert() async {
    setState(() {
      _isSending = true;
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      double latitude = position.latitude;
      double longitude = position.longitude;

      String message =
          'Emergency! I need help. My location: https://maps.google.com/?q=$latitude,$longitude';

      // Call the Firebase Function to send notifications
      await _sendNotificationToServer(message);

      setState(() {
        _isSending = false;
      });
    } catch (e) {
      print('Error occurred: $e');
      setState(() {
        _isSending = false;
      });
    }
  }

  // Call Firebase Function to send notification
  Future<void> _sendNotificationToServer(String message) async {
    try {
      // Use Firebase Functions or a backend endpoint to send the notification
      DatabaseReference ref = FirebaseDatabase.instance
          .ref()
          .child('notifications')
          .push(); // Example path in the database

      await ref.set({
        'userId': widget.userId,
        'emergencyContacts': emergencyContacts,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      });

      print('Notification data pushed to the server.');
    } catch (e) {
      print('Failed to send notification to the server: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    return Scaffold(
      appBar: AppBar(
        title: Text('Help is on the way!'),
        backgroundColor: Colors.redAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning, size: 100, color: Colors.red),
            SizedBox(height: 20),
            Text(
              _isSending ? 'Sending Alert...' : 'Emergency Alert Sent!',
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            SizedBox(height: 10),
            Text(
              _isSending
                  ? 'Please wait while we notify your contacts.'
                  : 'Your emergency contacts have been notified.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            SizedBox(height: 40),
            if (!_isSending)
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Return Home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
