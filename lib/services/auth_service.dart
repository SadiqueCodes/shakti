import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<void> saveUser(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
  }

  static Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') != null;
  }
}
