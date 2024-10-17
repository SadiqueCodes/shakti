import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyContactPage extends StatefulWidget {
  final Function(List<Map<String, String>>) onContactsUpdated; // Accept the callback

  EmergencyContactPage({required this.onContactsUpdated}); // Constructor

  @override
  _EmergencyContactPageState createState() => _EmergencyContactPageState();
}

class _EmergencyContactPageState extends State<EmergencyContactPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  List<Map<String, String>> emergencyContacts = [];

  void _addContact() {
    if (_nameController.text.isNotEmpty && _numberController.text.isNotEmpty) {
      setState(() {
        emergencyContacts.add({
          'name': _nameController.text,
          'number': 'tel:${_numberController.text}',
        });
        _nameController.clear();
        _numberController.clear();
      });
      // Call the callback to update the contacts in HomePage
      widget.onContactsUpdated(emergencyContacts);
    }
  }

  void _makeCall(String number) async {
    if (await canLaunch(number)) {
      await launch(number);
    } else {
      throw 'Could not launch $number';
    }
  }

  void _onContactPressed(String number) {
    _makeCall(number);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Emergency Contacts',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.pink,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Contact Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _numberController,
              decoration: InputDecoration(
                labelText: 'Contact Number',
                border: OutlineInputBorder(),
                prefixText: '+', // For country code indication
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addContact,
              child: Text('Add Contact'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: emergencyContacts.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.all(10),
                    color: Colors.pinkAccent,
                    child: ListTile(
                      leading: Icon(Icons.contact_phone, color: Colors.white),
                      title: Text(
                        emergencyContacts[index]['name']!,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      trailing: Icon(Icons.call, color: Colors.white),
                      onTap: () => _onContactPressed(emergencyContacts[index]['number']!),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
