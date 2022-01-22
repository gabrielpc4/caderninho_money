import 'package:shared_preferences/shared_preferences.dart';

class ThemePreferences {
  static const prefKey = "pref_key";

  setTheme(String value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(prefKey, value);
  }

  getTheme() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(prefKey) ?? "FFE91E63";
  }
}
