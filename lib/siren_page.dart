import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // To use SystemChrome.setEnabledSystemUIMode
import 'package:geolocator/geolocator.dart'; // Geolocation
import 'package:http/http.dart' as http; // For sending HTTP requests
import 'dart:convert'; // For JSON encoding/decoding

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

      // Replace with your backend URL
      String url = 'https://your-backend-url.com/api/alert'; // Update this URL

      // Prepare the data to send
      Map<String, dynamic> data = {
        'latitude': latitude,
        'longitude': longitude,
        'radius': 600, // Radius in meters
        'contacts': widget.emergencyContacts.map((contact) => contact['number']?.substring(4)).toList(), // Extract phone numbers without 'tel:'
      };

      // Send the alert to your backend
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      // Check the response from the server
      if (response.statusCode == 200) {
        print('Emergency alert sent successfully');
      } else {
        print('Failed to send alert: ${response.body}');
      }
    } catch (e) {
      print('Error occurred while sending alert: $e');
    } finally {
      setState(() {
        _isSending = false; // Set sending state to false after the operation
      });
    }
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
                  : 'Your emergency contacts and nearby authorities have been notified.',
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
