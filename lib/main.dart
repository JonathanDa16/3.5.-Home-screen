import 'package:flutter/material.dart';

/// Inicia la aplicacion del catalogo de peliculas.
void main() {
  runApp(const WelcomeApp());
}

/// Configura la aplicacion y muestra la pantalla de inicio.
class WelcomeApp extends StatelessWidget {
  const WelcomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catálogo de películas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB54B43),
          brightness: Brightness.dark,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

/// Compone la bienvenida sobre una imagen local para funcionar sin conexion.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to Flutter')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/cinema_background.png',
            fit: BoxFit.cover,
            excludeFromSemantics: true,
          ),
          Container(color: Colors.black.withValues(alpha: 0.48)),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 40,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: (constraints.maxHeight - 80).clamp(
                        0,
                        double.infinity,
                      ),
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.movie_outlined,
                              size: 52,
                              semanticLabel: 'Películas',
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Catálogo de películas',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Bienvenido a mi catálogo',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 22),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Hello World',
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
