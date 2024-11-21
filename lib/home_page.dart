import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'widgets/carousel_widget.dart';
import 'widgets/emergency_card_widget.dart';
import 'widgets/explore_icon_widget.dart';
import 'siren_page.dart'; // Import SirenPage
import 'emergency_contact_page.dart'; // Import EmergencyContactPage
import 'package:badges/badges.dart' as badgePackage;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, String>> emergencyContacts = [];
  bool _hasAlertNotification = false;

  void _updateEmergencyContacts(List<Map<String, String>> contacts) {
    setState(() {
      emergencyContacts = contacts;
    });
  }

  void _triggerAlertNotification() {
    setState(() {
      _hasAlertNotification = true;
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
                    showBadge: _hasAlertNotification,
                    badgeContent: Text('!', style: TextStyle(color: Colors.white)),
                    child: Icon(Icons.notifications, color: Colors.black),
                  ),
                  onPressed: () {
                    setState(() {
                      _hasAlertNotification = false;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.settings, color: Colors.black),
                  onPressed: () {
                    Navigator.pushNamed(context, '/settings');
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
              child: EmergencyCardWidget(emergencyContacts: emergencyContacts),
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
            String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

            if (userId.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EmergencyContactPage(
                    onContactsUpdated: _updateEmergencyContacts,
                    userId: userId,
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('User is not logged in')),
              );
            }
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
          String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

          if (userId.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SirenPage(
      userId: userId,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('User is not logged in')),
            );
          }
        },
        backgroundColor: Colors.red,
        child: Icon(Icons.security),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
