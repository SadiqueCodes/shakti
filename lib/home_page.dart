import 'package:flutter/material.dart';
import 'widgets/carousel_widget.dart';
import 'widgets/emergency_card_widget.dart';
// Ensure this import is correct
import 'widgets/explore_icon_widget.dart';
import 'siren_page.dart'; // Import SirenPage
import 'emergency_contact_page.dart'; // Import EmergencyContactPage
import 'package:badges/badges.dart' as badgePackage; // Import badges package with alias

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // List to hold emergency contacts
  List<Map<String, String>> emergencyContacts = [];
  bool _hasAlertNotification = false; // Track if there's an alert

  // Function to update emergency contacts
  void _updateEmergencyContacts(List<Map<String, String>> contacts) {
    setState(() {
      emergencyContacts = contacts;
    });
  }

  // Function to trigger the alert notification
  void _triggerAlertNotification() {
    setState(() {
      _hasAlertNotification = true; // Set notification flag
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "SHAKTI MITRA",
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: badgePackage.Badge(
                    showBadge: _hasAlertNotification, // Show badge if there's a notification
                    badgeContent: Text('!', style: TextStyle(color: Colors.white)),
                    child: Icon(Icons.notifications, color: Colors.black),
                  ),
                  onPressed: () {
                    // Handle notification icon tap
                    setState(() {
                      _hasAlertNotification = false; // Reset notification when viewed
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.settings, color: Colors.black),
                  onPressed: () {
                    Navigator.pushNamed(context, '/settings'); // Navigate to SettingsPage
                  },
                ),
              ],
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Women Empowerment",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CarouselWidget(),
            ),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Emergency",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: EmergencyCardWidget(emergencyContacts: emergencyContacts), // Pass the contacts here
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Explore LiveSafe",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ExploreIconWidget(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        iconSize: 40,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/home');
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EmergencyContactPage(
                onContactsUpdated: _updateEmergencyContacts,
              )),
            );
          }
        },
        selectedItemColor: Colors.pink,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.pink),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.call, color: Colors.green),
            label: '',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SirenPage(emergencyContacts: emergencyContacts)),
          );
        },
        backgroundColor: Colors.red,
        child: Icon(Icons.security),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
