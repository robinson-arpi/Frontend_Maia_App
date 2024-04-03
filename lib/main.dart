import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maia_app/src/pages/map_screen.dart';
import 'package:maia_app/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:maia_app/environment.dart';
import 'package:maia_app/providers/api_provider.dart';
import 'package:maia_app/src/pages/home_screen.dart';

import 'package:maia_app/src/pages/splash_screen.dart';
import 'package:maia_app/src/pages/login_screen.dart';

void main() => runApp(const MyApp());

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        return const SplashScreen();
      },
      routes: [
        GoRoute(
          path: 'login',
          builder: (context, state) {
            return const LoginScreen();
          },
        ),
        GoRoute(
          path: 'home',
          builder: (context, state) {
            return const HomeScreen();
          },
        ),
        GoRoute(
          path: 'map',
          builder: (context, state) {
            return const MapScreen();
          },
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => ApiProvider(apiUrl),
        child: MaterialApp.router(
          title: 'Material App',
          locale: const Locale(
              'es', 'ES'), // Establecer localización en español (España)
          debugShowMaterialGrid: false,
          theme: ThemeData(
            // Utiliza el tema personalizado definido en AppTheme
            textTheme: AppTheme.textTheme,
            // Aquí puedes definir más propiedades del tema según sea necesario
          ),
          routerConfig: _router,
        ));
  }
}
