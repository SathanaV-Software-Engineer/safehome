import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveUser(String user) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('user', user);
}

Future<String> getUser() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('user') ?? '';
}

Future<void> removeUser() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('user');
}
