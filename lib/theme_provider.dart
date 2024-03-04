// Import the Flutter material package
import 'package:flutter/material.dart';

// Define the ThemeProvider class
class ThemeProvider extends ChangeNotifier {
  // Private field to store the theme data
  ThemeData _themeData;

  // Constructor to initialize the ThemeProvider with default theme data
  ThemeProvider(this._themeData);

  // Getter to retrieve the current theme data
  ThemeData get themeData => _themeData;

  // Setter to change the theme data and notify listeners about the change
  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners(); // This is crucial to update the UI when the theme changes
  }
}
