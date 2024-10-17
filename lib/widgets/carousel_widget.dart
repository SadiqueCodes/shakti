import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';

class CarouselWidget extends StatelessWidget {
  final List<Map<String, String>> carouselItems = [
    {
      'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS1HxRFYQ96I4_ZpDogf1EtLbcyQ0DWREd9jQr41emD3djJTwST6aLmiYNPSvERS7_kwzo&usqp=CAU',
      'text': '',
      'url': 'https://cmsadmin.amritmahotsav.nic.in/blogdetail.htm?75'
    }, {
      'image': 'https://media.licdn.com/dms/image/v2/D5612AQF5L8muOkExTQ/article-cover_image-shrink_720_1280/article-cover_image-shrink_720_1280/0/1723114632046?e=2147483647&v=beta&t=Y8BNJFLD6Ki1FhqHDVIDTVAKfUpEWuE2C2SoIQ5hnhA',
      'text': '',
      'url': 'https://www.forbes.com/sites/cherylrobinson/2024/01/22/womens-empowerment-isnt-enough-activating-women-is-more-powerful/'
    }
    // Add more items here if needed
  ];

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 200.0,
        autoPlay: true,
        enlargeCenterPage: true,
      ),
      items: carouselItems.map((item) {
        return Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () async {
                final Uri url = Uri.parse(item['url']!);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  image: DecorationImage(
                    image: NetworkImage(item['image']!),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Align(
  alignment: Alignment.bottomCenter,
  child: Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text(
      item['text']!,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        fontFamily: 'Poppins',
        backgroundColor: Colors.black45, // Semi-transparent black
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
