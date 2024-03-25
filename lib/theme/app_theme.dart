import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color strongColorA = Color(0xFF001781);
  static const Color strongColorB = Color(0xFFD2070F);
  static const Color softColorA = Color(0xFFE7EDF7);
  static const Color softColorB = Color(0xFFFFFFFF);

  // Theme Data
  static ThemeData getThemeData() {
    return ThemeData(
      // Configuración de la fuente y el tamaño de fuente
      fontFamily: 'sans-serif', // Especifica la fuente sans-serif
      textTheme: TextTheme(
        // Tamaños de fuente para diferentes estilos de texto
        headline1: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
          color: strongColorB,
        ),
        bodyText1: TextStyle(
          fontSize: 14.0,
          color: strongColorA,
        ),
      ),

      // Resto de la configuración del tema...
      primarySwatch: Colors.blue,
      primaryColor: strongColorA,
      colorScheme: ColorScheme.fromSwatch().copyWith(secondary: strongColorB),
      scaffoldBackgroundColor: softColorA,
      appBarTheme: AppBarTheme(
        color: softColorB,
        iconTheme: IconThemeData(color: softColorB),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: strongColorB,
        textTheme: ButtonTextTheme.primary,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: strongColorB,
      ),
      cardTheme: CardTheme(
        color: softColorB,
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: softColorA,
        filled: true,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: strongColorA),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
