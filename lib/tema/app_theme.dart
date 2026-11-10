import 'package:flutter/material.dart';

class Paleta {
  const Paleta._();

  static const Color fondo = Color(0xFF0F1011);
  static const Color superficie = Color(0xFF191B1D);
  static const Color superficieAlta = Color(0xFF212427);
  static const Color acento = Color(0xFFC8A24B);
  static const Color acentoOscuro = Color(0xFF8F7334);
  static const Color ambar = Color(0xFFC8A24B);
  static const Color texto = Color(0xFFECECEC);
  static const Color textoSuave = Color(0xFF9BA0A6);
  static const Color borde = Color(0xFF2C3034);
}

class Radios {
  const Radios._();

  static const double tarjeta = 8;
  static const double campo = 6;
  static const double chip = 6;
  static const double poster = 6;
}

ThemeData construirTema() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Barlow',
    scaffoldBackgroundColor: Paleta.fondo,
    colorScheme: const ColorScheme.dark(
      primary: Paleta.acento,
      onPrimary: Color(0xFF15130C),
      secondary: Paleta.acento,
      onSecondary: Color(0xFF15130C),
      surface: Paleta.superficie,
      onSurface: Paleta.texto,
      outline: Paleta.borde,
    ),
  );

  return base.copyWith(
    textTheme: base.textTheme
        .apply(
          bodyColor: Paleta.texto,
          displayColor: Paleta.texto,
          fontFamily: 'Barlow',
        )
        .copyWith(
          displayLarge: base.textTheme.displayLarge?.copyWith(fontFamily: 'Barlow', fontWeight: FontWeight.w600),
          titleLarge: base.textTheme.titleLarge?.copyWith(fontFamily: 'Barlow', fontWeight: FontWeight.w600),
        ),
    splashFactory: InkSparkle.splashFactory,
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Paleta.superficieAlta,
      contentTextStyle: const TextStyle(color: Paleta.texto, fontSize: 13.5),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Paleta.superficie,
      surfaceTintColor: Colors.transparent,
    ),
    dividerTheme: const DividerThemeData(color: Paleta.borde, thickness: 1),
  );
}
