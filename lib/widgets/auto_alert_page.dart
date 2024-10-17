import 'package:flutter/material.dart';

class AutoAlertPage extends StatefulWidget {
  final List<Map<String, String>> emergencyContacts;
  final Function(bool) onToggle; // Callback for activation/deactivation

  AutoAlertPage({
    Key? key,
    required this.emergencyContacts,
    required this.onToggle,
  }) : super(key: key);

  @override
  _AutoAlertPageState createState() => _AutoAlertPageState();
}

class _AutoAlertPageState extends State<AutoAlertPage> {
  double _selectedBatteryPercentage = 0; // Slider value
  bool _isActivated = false; // Activation status
  List<bool> _selectedContacts = []; // Track selected contacts

  @override
  void initState() {
    super.initState();
    // Initialize the selected contacts list based on the number of emergency contacts
    _selectedContacts = List<bool>.filled(widget.emergencyContacts.length, false);
  }

  void _toggleActivation() {
    setState(() {
      _isActivated = !_isActivated; // Toggle the activation state
    });
    widget.onToggle(_isActivated); // Notify the parent
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Auto Alert'),
        backgroundColor: Colors.pink,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align contents to the start
          children: [
            Text(
              'Select Battery Percentage:',
              style: TextStyle(fontSize: 18),
            ),
            Slider(
              value: _selectedBatteryPercentage,
              min: 0,
              max: 100,
              divisions: 100,
              label: _selectedBatteryPercentage.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _selectedBatteryPercentage = value;
                });
              },
            ),
            SizedBox(height: 20),
            Text('Selected Percentage: ${_selectedBatteryPercentage.round()}%'),
            SizedBox(height: 20),
            Text(
              'Select Emergency Contacts:',
              style: TextStyle(fontSize: 18),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.emergencyContacts.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(widget.emergencyContacts[index]['name']!),
                      subtitle: Text(widget.emergencyContacts[index]['number']!.replaceAll('tel:', '')),
                      trailing: Checkbox(
                        value: _selectedContacts[index],
                        onChanged: (bool? value) {
                          setState(() {
                            _selectedContacts[index] = value ?? false; // Update the selection status
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            // Add space before the button
            SizedBox(height: 20),
            Center( // Center the button
              child: ElevatedButton(
                onPressed: _toggleActivation,
                child: Text(
                  _isActivated ? 'Deactivate' : 'Activate',
                  style: TextStyle(color: Colors.white), // Make text white
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  minimumSize: Size(double.infinity, 50), // Make button full-width
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
