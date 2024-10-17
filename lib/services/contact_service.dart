import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';

class ContactService {
  // Request permission to access contacts
  Future<bool> requestPermission() async {
    var status = await Permission.contacts.status;
    if (!status.isGranted) {
      status = await Permission.contacts.request();
    }
    return status.isGranted;
  }

  // Get the user's contacts
  Future<List<Contact>> getContacts() async {
    if (await requestPermission()) {
      return await ContactsService.getContacts();
    } else {
      throw Exception('Permission denied');
    }
  }
}
