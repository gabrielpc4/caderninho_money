import 'package:flutter/material.dart';
import 'themes_preferences.dart';

class ThemeModel extends ChangeNotifier {
  String _appColor = "FFE91E63";
  final ThemePreferences _preferences = ThemePreferences();
  String get appColor => _appColor;

  ThemeModel() {
    getPreferences();
  }
//Switching themes in the flutter apps - Flutterant
  set appColor(String value) {
    _appColor = value;
    _preferences.setTheme(value);
    notifyListeners();
  }

  getPreferences() async {
    _appColor = await _preferences.getTheme();
    notifyListeners();
  }
}
