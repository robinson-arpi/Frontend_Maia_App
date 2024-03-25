import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maia_app/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:maia_app/environment.dart';
import 'package:maia_app/providers/api_provider.dart';
import 'package:maia_app/src/pages/home_screen.dart';
import 'package:maia_app/src/pages/splash_screen.dart';

void main() => runApp(const MyApp());

final GoRouter _router = GoRouter(routes: [
  GoRoute(
      path: '/',
      builder: (context, state) {
        return const SplashScreen();
      },
      routes: [
        GoRoute(
            path: 'home',
            builder: (context, state) {
              return const HomeScreen();
            })
      ]),
]);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => ApiProvider(apiUrl),
        child: MaterialApp.router(
          title: 'Material App',
          debugShowMaterialGrid: false,
          theme: AppTheme.getThemeData(), // Usa tu tema aquí

          routerConfig: _router,
        ));
  }
}
