import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maia_app/providers/api_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    checkAutoLogin();
  }

  void checkAutoLogin() async {
    final email = await _storage.read(key: 'email');
    final password = await _storage.read(key: 'password');
    if (email != null && password != null) {
      // Intentar iniciar sesión automáticamente
      try {
        _navigateToHome(email, password);
      } catch (error) {
        _navigateToLogin();
      }
    } else {
      // Si no hay credenciales almacenadas, muestra la pantalla de inicio de sesión
      _navigateToLogin();
    }
  }

  void _navigateToLogin() async {
    // Espera 2 segundos antes de navegar a la pantalla de inicio de sesión
    await Future.delayed(const Duration(seconds: 2));
    context.go('/login');
  }

  void _navigateToHome(String email, String password) async {
    final apiProvider = Provider.of<ApiProvider>(context, listen: false);
    await apiProvider.login(email, password);
    await apiProvider.getClassSchedule();
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF002957), // Cambia el color de fondo aquí
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/splash.png"),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.all(70),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 20),
                  CircularProgressIndicator(
                    color: Colors.indigo,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
