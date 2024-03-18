import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    var d = const Duration(seconds: 4);
    Future.delayed(d, () {
      context.go('/home');
    });
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
                  fit: BoxFit
                      .contain, // Usa BoxFit.contain para que la imagen no cubra toda la pantalla
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
                  ListTile(
                    titleTextStyle: TextStyle(color: Colors.white),
                    title: Text(
                      "Habla prro",
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
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
