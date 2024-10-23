import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'auto_alert_page.dart'; // Ensure the path is correct

class EmergencyCardWidget extends StatelessWidget {
  final List<Map<String, String>> emergencyCards = [
    {'title': 'Women Helpline', 'number': 'tel:1091', 'icon': 'female'}, // Female icon for Women Helpline
    {'title': 'Ambulance', 'number': 'tel:102', 'icon': 'ambulance'}, // Ambulance icon
    {'title': 'Auto Alert', 'number': '', 'icon': 'alert'}, // Alert icon for Auto Alert
  ];

  final List<Map<String, String>> emergencyContacts; // List of emergency contacts

  EmergencyCardWidget({Key? key, required this.emergencyContacts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: emergencyCards.length,
        itemBuilder: (context, index) {
          final item = emergencyCards[index];
          IconData? cardIcon;

          // Set appropriate icons based on the card title
          switch (item['icon']) {
            case 'female':
              cardIcon = Icons.female; // Icon for Women Helpline
              break;
            case 'ambulance':
              cardIcon = Icons.local_hospital; // Icon for Ambulance
              break;
            case 'alert':
              cardIcon = Icons.battery_alert; // Icon for Auto Alert
              break;
            default:
              cardIcon = Icons.warning; // Default warning icon
          }

          return GestureDetector(
            onTap: () {
              if (item['title'] == 'Auto Alert') {
                // Navigate to Auto Alert page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AutoAlertPage(
                      emergencyContacts: emergencyContacts, // Pass emergency contacts
                      onToggle: (isActive) {
                        // Handle activation/deactivation here
                        if (isActive) {
                          // Code to activate auto alert
                        } else {
                          // Code to deactivate auto alert
                        }
                      },
                    ),
                  ),
                );
              } else {
                // Launch the emergency number
                final Uri url = Uri.parse(item['number']!);
                launchUrl(url);
              }
            },
            child: Container(
              width: 200,
              margin: const EdgeInsets.symmetric(horizontal: 10.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFA726), Color(0xFFEF5350)], // Orange to Red Gradient
                ),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(cardIcon, size: 50, color: Colors.white), // Dynamic icon based on card title
                    const SizedBox(height: 10),
                    Text(
                      item['title']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 5),
                    if (item['number']!.isNotEmpty) // Show number if not empty
                      Text(
                        item['number']!.replaceAll('tel:', ''),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
