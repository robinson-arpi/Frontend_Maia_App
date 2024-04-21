import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maia_app/providers/api_provider.dart';
import 'package:provider/provider.dart';
import 'package:maia_app/theme/app_theme.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late ApiProvider apiProvider;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();

    // Verificar si existen credenciales guardadas y realizar inicio de sesión automático
    checkAutoLogin();
  }

  void checkAutoLogin() async {
    final email = await _storage.read(key: 'email');
    final password = await _storage.read(key: 'password');
    if (email != null && password != null) {
      // Intentar iniciar sesión automáticamente
      await apiProvider.login(email, password);
      // Navegar a la pantalla de inicio si el inicio de sesión automático es exitoso
      context.go('/home');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    apiProvider = Provider.of<ApiProvider>(context);
  }

  void _login(BuildContext context) async {
    final String email = emailController.text;
    final String password = passwordController.text;

    try {
      await apiProvider.login(email, password);
      context.go('/home');
    } catch (error) {
      // Manejar cualquier error que pueda ocurrir durante la autenticación
      print('Error durante la autenticación: $error');
      // Mostrar un mensaje de error al usuario, por ejemplo:
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error de autenticación')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.softColorA,
      appBar: AppBar(
        title: Text(
          "Bienvenido",
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                labelStyle: Theme.of(context).textTheme.headlineSmall,
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.strongColorA),
                  // Color de la línea cuando el campo está enfocado
                ),
                hoverColor: AppTheme.strongColorA,
              ),

              cursorColor:
                  AppTheme.strongColorA, // Cambia el color del cursor aquí
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                labelStyle: Theme.of(context).textTheme.headlineSmall,
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.strongColorA),
                  // Color de la línea cuando el campo está enfocado
                ),
                hoverColor: AppTheme.strongColorA,
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _login(context),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    AppTheme.strongColorA), // Fondo del botón azul
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10), // Bordes menos redondeados
                  ),
                ),
                overlayColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed)) {
                      return AppTheme.strongColorA
                          .withOpacity(0.5); // Color de sombreado al presionar
                    }
                    return null; // No hay sombreado en otros estados
                  },
                ),
              ),
              child: const Text(
                'Iniciar sesión',
                style: TextStyle(
                    color: AppTheme.softColorB), // Color de texto blanco
              ),
            ),
          ],
        ),
      ),
    );
  }
}
