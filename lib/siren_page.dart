import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // To use SystemChrome.setEnabledSystemUIMode
import 'package:geolocator/geolocator.dart'; // Geolocation
import 'package:url_launcher/url_launcher.dart'; // For dialing phone numbers

class SirenPage extends StatefulWidget {
  final List<Map<String, String>> emergencyContacts; // Add this to store contacts

  SirenPage({Key? key, required this.emergencyContacts}) : super(key: key); // Constructor to accept contacts

  @override
  _SirenPageState createState() => _SirenPageState();
}

class _SirenPageState extends State<SirenPage> {
  bool _isSending = false; // Track sending state

  @override
  void initState() {
    super.initState();
    _sendEmergencyAlert(); // Automatically send alert on initialization
  }

  Future<void> _sendEmergencyAlert() async {
    setState(() {
      _isSending = true; // Set sending state to true
    });

    try {
      // Get the current location of the user
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      double latitude = position.latitude;
      double longitude = position.longitude;

      String message = 'Emergency! I need help. My current location is: https://maps.google.com/?q=$latitude,$longitude';

      // Iterate through all emergency contacts and send the alert
      for (var contact in widget.emergencyContacts) {
        String phoneNumber = contact['number']?.substring(4) ?? ''; // Extract phone number without 'tel:'

        if (phoneNumber.isNotEmpty) {
          _sendAlertToContact(phoneNumber, message);
        }
      }

      // Set the UI after sending alerts
      setState(() {
        _isSending = false; // Set sending state to false after the operation
      });

    } catch (e) {
      print('Error occurred while sending alert: $e');
      setState(() {
        _isSending = false;
      });
    }
  }

  // Function to dial the emergency contact
  void _sendAlertToContact(String phoneNumber, String message) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunch(launchUri.toString())) {
      await launch(launchUri.toString());
    } else {
      throw 'Could not launch $launchUri';
    }

    // In a real-world scenario, you could send the message via an SMS API.
    print('Alert sent to $phoneNumber: $message');
  }

  @override
  Widget build(BuildContext context) {
    // Change the status bar to a transparent style
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
            Icon(
              Icons.warning,
              size: 100,
              color: Colors.red,
            ),
            SizedBox(height: 20),
            Text(
              _isSending ? 'Sending Alert...' : 'Emergency Alert Sent!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 10),
            Text(
              _isSending 
                  ? 'Please wait while we notify your contacts.' 
                  : 'Your emergency contacts have been notified.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 40),
            if (!_isSending) // Show this button only when alert has been sent
              ElevatedButton(
                onPressed: () {
                  // Navigate back to home page
                  Navigator.pop(context);
                },
                child: Text('Return Home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Button color
                  foregroundColor: Colors.white, // Text color
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
          ],
        ),
      ),
      backgroundColor: Colors.white, // Set background color
    );
  }
}
