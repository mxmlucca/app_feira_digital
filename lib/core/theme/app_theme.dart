import 'package:flutter/material.dart';

/// Define o tema visual completo para a aplicação "App Feira Digital".
///
/// Esta classe centraliza todas as cores, estilos de texto e temas de widgets,
/// garantindo uma aparência consistente em todo o aplicativo.
class AppTheme {
  // Construtor privado para prevenir que esta classe seja instanciada.
  // Todos os seus membros são estáticos.
  AppTheme._();

  // --- CORES PRINCIPAIS DA PALETA ---
  static const Color kCorPrimaria = Color.fromARGB(255, 171, 10, 78);
  static const Color kCorSecundaria = Color.fromARGB(255, 248, 172, 32);
  static const Color kCorSuperficie = Color.fromARGB(255, 19, 79, 130);
  static const Color kCorSeed = Color(0xFF134F82);
  static const Color kCorErro = Colors.red;
  static const Color kCorTextoPrimaria = Colors.white;
  static const Color kCorTextoSecundaria = Colors.black;

  /// Retorna o [ThemeData] principal da aplicação no modo claro (light).
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: kCorPrimaria,
        primary: kCorPrimaria,
        secondary: kCorSecundaria,
        surface: kCorSuperficie,
        error: kCorErro,
        brightness: Brightness.light,
        onPrimary: kCorTextoPrimaria,
        onSecondary: kCorTextoSecundaria,
        onSurface: Colors.white,
        onError: kCorTextoPrimaria,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: kCorPrimaria,
        foregroundColor: kCorTextoPrimaria,
        elevation: 1,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: kCorTextoPrimaria,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color.fromARGB(255, 31, 37, 47),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: kCorPrimaria, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: kCorErro, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: kCorErro, width: 2.0),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 14.0,
        ),
        hintStyle: const TextStyle(color: Colors.white),
        prefixIconColor: Colors.white,
        suffixIconColor: Colors.white,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kCorPrimaria,
          foregroundColor: kCorTextoPrimaria,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 2,
        ),
      ),

      cardTheme: CardTheme(
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
        color: Colors.white,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: kCorPrimaria,
        foregroundColor: kCorTextoPrimaria,
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: kCorPrimaria,
        selectedItemColor: kCorSecundaria,
        unselectedItemColor: kCorTextoPrimaria.withOpacity(0.7),
        type: BottomNavigationBarType.fixed,
      ),

      textTheme: TextTheme(
        titleLarge: const TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
          color: kCorPrimaria,
        ),
        labelMedium: const TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          color: kCorErro,
        ),
        // ... adicione outros estilos de texto padrão se necessário
      ),
    );
  }
}
