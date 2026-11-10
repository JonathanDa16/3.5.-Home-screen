import 'package:flutter/material.dart';

import 'pantallas/pantalla_inicio_35.dart';
import 'tema/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppActividad35());
}

class AppActividad35 extends StatelessWidget {
  const AppActividad35({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CineCatálogo',
      debugShowCheckedModeBanner: false,
      theme: construirTema(),
      home: const PantallaInicio35(),
    );
  }
}
