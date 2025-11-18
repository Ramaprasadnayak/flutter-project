import 'package:flutter/material.dart';

class ThemeConfig {
  // Singleton instance
  static final ThemeConfig _instance =ThemeConfig._internal();
  factory ThemeConfig() => _instance;
  ThemeConfig._internal();

  // Default colors
  Color color4 = Color.fromARGB(255, 170, 200, 220) ;
  Color color3 = Color.fromARGB(255, 200, 230, 230);
  Color color1 = Color(0xFF0F0C29);
  Color color2 = Color(0xFF302B63);
  Color fcolor2=Color.fromARGB(255, 0, 0, 0);
  Color fcolor1=Color.fromARGB(255, 237, 237, 237);  
  bool isDark = false;
}
