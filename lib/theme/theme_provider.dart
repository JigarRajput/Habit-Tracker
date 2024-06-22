import 'package:flutter/material.dart';

import 'dark_mode.dart';
import 'light_mode.dart';

class ThemeProvider extends ChangeNotifier {
  /// initially theme is light mode
  ThemeData _themeData = lightMode;

  /// get [themeData]
  ThemeData get themeData => _themeData;

  /// is current theme dark mode
  bool get isDarkMode => _themeData == darkMode;

  /// sets the theme
  set themeData(ThemeData themeData) => _themeData = themeData;

  /// toggle theme
  void toggleTheme() {
    themeData = _themeData == lightMode ? darkMode : lightMode;
    notifyListeners();
  }
}
