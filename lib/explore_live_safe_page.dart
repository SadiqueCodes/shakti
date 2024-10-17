import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ExploreLiveSafePage extends StatelessWidget {
  final List<Map<String, dynamic>> icons = [
    {'label': 'Police Stations', 'url': 'https://maps.google.com/?q=Police+Stations'},
    {'label': 'Hospitals', 'url': 'https://maps.google.com/?q=Hospitals'},
    {'label': 'Pharmacies', 'url': 'https://maps.google.com/?q=Pharmacies'},
    {'label': 'Bus Stations', 'url': 'https://maps.google.com/?q=Bus+Stations'},
  ];

  void _openMap(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Explore LiveSafe',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.pink,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: icons.map((item) {
          return GestureDetector(
            onTap: () => _openMap(item['url']),
            child: Card(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, size: 40, color: Colors.pink),
                  SizedBox(height: 10),
                  Text(
                    item['label'],
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
