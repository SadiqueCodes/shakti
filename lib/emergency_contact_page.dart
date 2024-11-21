import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyContactPage extends StatefulWidget {
  final Function(List<Map<String, String>>) onContactsUpdated;
  final String userId;

  EmergencyContactPage({required this.onContactsUpdated, required this.userId});

  @override
  _EmergencyContactPageState createState() => _EmergencyContactPageState();
}

class _EmergencyContactPageState extends State<EmergencyContactPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController(text: '+91 ');
  List<Map<String, String>> emergencyContacts = [];
  late DatabaseReference _contactsRef;

  @override
  void initState() {
    super.initState();
    _contactsRef = FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(widget.userId)
        .child('emergencyContacts');
    _loadContacts();
  }

  Future<void> _loadContacts() async {
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

  Future<void> _saveContacts() async {
    final Map<String, Map<String, String>> contactsMap = {};
    for (int i = 0; i < emergencyContacts.length; i++) {
      contactsMap['contact_$i'] = {
        'name': emergencyContacts[i]['name']!,
        'number': emergencyContacts[i]['number']!,
      };
    }

    await _contactsRef.set(contactsMap);
  }

  bool _isValidIndianPhoneNumber(String number) {
    final RegExp phoneRegex = RegExp(r'^\+91\s\d{10}$');
    return phoneRegex.hasMatch(number);
  }

  void _addContact() {
    if (_nameController.text.isNotEmpty && _numberController.text.isNotEmpty) {
      if (_isValidIndianPhoneNumber(_numberController.text)) {
        setState(() {
          emergencyContacts.add({
            'name': _nameController.text,
            'number': _numberController.text,
          });
          _saveContacts();
          _nameController.clear();
          _numberController.text = '+91 ';
        });
        widget.onContactsUpdated(emergencyContacts);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter a valid Indian phone number.')),
        );
      }
    }
  }

  void _makeCall(String number) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: number,
    );
    if (await canLaunch(launchUri.toString())) {
      await launch(launchUri.toString());
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
            color: Colors.white,
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
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                LengthLimitingTextInputFormatter(14),
                _PhoneNumberFormatter(),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addContact,
              child: Text('Add Contact', style: TextStyle(color: Colors.white)),
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

class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text;
    if (!newText.startsWith('+91 ')) {
      newText = '+91 ' + newText.replaceAll('+91 ', '');
    }

    String digitsAfterPrefix = newText.replaceAll('+91 ', '').replaceAll(RegExp(r'\D'), '');
    if (digitsAfterPrefix.length > 10) {
      digitsAfterPrefix = digitsAfterPrefix.substring(0, 10);
    }

    newText = '+91 ' + digitsAfterPrefix;
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
