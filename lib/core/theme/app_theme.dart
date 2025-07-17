import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(
          255,
          32,
          2,
          150,
        ), // Choose your app's main color
      ),
      appBarTheme: const AppBarTheme(elevation: 2, centerTitle: true),
    );
  }
}
