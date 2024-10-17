import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ExploreIconWidget extends StatelessWidget {
  final List<Map<String, dynamic>> exploreItems = [
  {'icon': Icons.local_police, 'label': 'Police Stations', 'query': 'police+stations+near+me'},
  {'icon': Icons.local_hospital, 'label': 'Hospitals', 'query': 'hospitals+near+me'},
  {'icon': Icons.local_pharmacy, 'label': 'Pharmacies', 'query': 'pharmacies+near+me'},
  {'icon': Icons.directions_bus, 'label': 'Bus Stations', 'query': 'bus+stations+near+me'},
];


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: exploreItems.map((item) {
          return GestureDetector(
            onTap: () async {
              final Uri url = Uri.parse('https://www.google.com/maps/search/${item['query']}');
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              }
            },
        child: Column(
  children: [
    Icon(item['icon'], size: 50, color: Colors.pink),
    const SizedBox(height: 5),
    Text(
      item['label'],
      style: const TextStyle(
        fontSize: 14,
        fontFamily: 'Poppins',
        color: Colors.black,
         ),
    ),

              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
