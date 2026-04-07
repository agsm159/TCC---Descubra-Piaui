import 'package:flutter/material.dart';

class AppColors {
  static const Color verdePrincipal = Color(0xFF1B5E20);
  static const Color verdeClaro = Color(0xFF2E7D32);
  static const Color verdeSutil = Color(0xFFE8F5E9);

  static const Color azulPrincipal = Color(0xFF0D47A1);
  static const Color azulClaro = Color(0xFFE3F2FD);

  static const Color dourado = Color(0xFFF9A825);
  static const Color douradoClaro = Color(0xFFFFF8E1);

  static const Color branco = Color(0xFFFFFFFF);
  static const Color fundoSuave = Color(0xFFF5F5F5);
  static const Color cinzaTexto = Color(0xFF757575);
  static const Color cinzaBorda = Color(0xFFE0E0E0);
  static const Color cinzaEscuro = Color(0xFF212121);

  static const Color erro = Color(0xFFB71C1C);
  static const Color sucesso = Color(0xFF2E7D32);
  static const Color atencao = Color(0xFFF9A825);
}

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  fontFamily: 'Roboto',

  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.verdePrincipal,
    primary: AppColors.verdePrincipal,
    secondary: AppColors.azulPrincipal,
    tertiary: AppColors.dourado,
    surface: AppColors.branco,
    error: AppColors.erro,
    onPrimary: AppColors.branco,
    onSecondary: AppColors.branco,
    onSurface: AppColors.cinzaEscuro,
    brightness: Brightness.light,
  ),

  scaffoldBackgroundColor: AppColors.fundoSuave,

  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.verdePrincipal,
    foregroundColor: AppColors.branco,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
      color: AppColors.branco,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    iconTheme: IconThemeData(color: AppColors.branco),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.verdePrincipal,
      foregroundColor: AppColors.branco,
      elevation: 1,
      minimumSize: const Size(120, 44),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.verdePrincipal,
      side: const BorderSide(color: AppColors.verdePrincipal, width: 1.5),
      minimumSize: const Size(120, 44),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.verdePrincipal,
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.branco,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.cinzaBorda),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.cinzaBorda),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.verdePrincipal, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.erro),
    ),
    labelStyle: const TextStyle(color: AppColors.cinzaTexto),
    prefixIconColor: AppColors.verdePrincipal,
    suffixIconColor: AppColors.cinzaTexto,
  ),

  cardTheme: CardThemeData(
    color: AppColors.branco,
    elevation: 2,
    shadowColor: Colors.black12,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
  ),

  chipTheme: ChipThemeData(
    backgroundColor: AppColors.verdeSutil,
    labelStyle: const TextStyle(
      color: AppColors.verdePrincipal,
      fontSize: 13,
      fontWeight: FontWeight.w500,
    ),
    side: const BorderSide(color: AppColors.verdeClaro, width: 1),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.verdePrincipal,
    foregroundColor: AppColors.branco,
    elevation: 4,
    shape: CircleBorder(),
  ),

  iconTheme: const IconThemeData(color: AppColors.verdePrincipal, size: 24),

  dividerTheme: const DividerThemeData(
    color: AppColors.cinzaBorda,
    thickness: 1,
    space: 1,
  ),

  listTileTheme: const ListTileThemeData(
    iconColor: AppColors.verdePrincipal,
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  ),

  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColors.cinzaEscuro,
    ),
    headlineMedium: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: AppColors.cinzaEscuro,
    ),
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.cinzaEscuro,
    ),
    bodyLarge: TextStyle(fontSize: 16, color: AppColors.cinzaEscuro),
    bodyMedium: TextStyle(fontSize: 14, color: AppColors.cinzaTexto),
    bodySmall: TextStyle(fontSize: 12, color: AppColors.cinzaTexto),
    labelLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.branco,
    ),
  ),
);
