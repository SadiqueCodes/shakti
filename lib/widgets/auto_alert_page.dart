import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AutoAlertPage extends StatefulWidget {
  final List<Map<String, String>> emergencyContacts;
  final Function(bool) onToggle;

  AutoAlertPage({
    Key? key,
    required this.emergencyContacts,
    required this.onToggle,
  }) : super(key: key);

  @override
  _AutoAlertPageState createState() => _AutoAlertPageState();
}

class _AutoAlertPageState extends State<AutoAlertPage> {
  double _selectedBatteryPercentage = 0;
  bool _isActivated = false;
  List<bool> _selectedContacts = [];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedBatteryPercentage = prefs.getDouble('batteryPercentage') ?? 0;
      _isActivated = prefs.getBool('isActivated') ?? false;

      // Load the selected contacts state
      final savedContacts = prefs.getStringList('selectedContacts') ?? [];
      
      // Initialize _selectedContacts list
      _selectedContacts = List<bool>.filled(widget.emergencyContacts.length, false);
      
      for (int i = 0; i < savedContacts.length && i < _selectedContacts.length; i++) {
        _selectedContacts[i] = savedContacts[i] == 'true';
      }
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('batteryPercentage', _selectedBatteryPercentage);
    await prefs.setBool('isActivated', _isActivated);

    // Save the selected contacts state
    await prefs.setStringList(
      'selectedContacts',
      _selectedContacts.map((isSelected) => isSelected.toString()).toList(),
    );
  }

  void _toggleActivation() {
    setState(() {
      _isActivated = !_isActivated;
    });
    widget.onToggle(_isActivated);
    _savePreferences(); // Save the state when toggling activation
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
                _savePreferences(); // Save the selected percentage when it changes
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
                            _selectedContacts[index] = value ?? false;
                          });
                          _savePreferences(); // Save the selected contacts state
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _toggleActivation,
                child: Text(
                  _isActivated ? 'Deactivate' : 'Activate',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
