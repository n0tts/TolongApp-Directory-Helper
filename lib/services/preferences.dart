import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  AppPreferences();
  Future<String> getHelperId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('helperId');
  }

  Future<void> setHelperId(String uid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('helperId', uid);
  }
}

AppPreferences preferences = new AppPreferences();
