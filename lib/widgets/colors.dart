import 'package:flutter/material.dart';

class ThemeColors {
  static const int mainColor = 0xFF0A3E91;
  static MaterialColor get colorTheme => const MaterialColor(mainColor, {
        50: Color(0xFFE1F5FE),
        100: Color(0xFFB3E0FF),
        200: Color(0xFF81C7FF),
        300: Color(0xFF4F9DFF),
        400: Color(0xFF2196F3),
        500: Color(mainColor),
        600: Color(0xFF1976D2),
        700: Color(0xFF1565C0),
        800: Color(0xFF0D47A1),
        900: Color(0xFF0A3E91)
      });
}

Color transparent = Colors.transparent;
Color black = Colors.black;
Color grey = Colors.grey;
Color white = Colors.white;

Color blue = Colors.blue;
Color green = Colors.green;
Color red = Colors.red;
Color yellow = Colors.yellow;

Color darkBlue = Colors.blue.shade900;
Color darkGreen = Colors.green.shade900;
Color darkGrey = Colors.grey.shade700;
Color darkRed = Colors.red.shade900;
Color darkYellow = Colors.yellow.shade900;
