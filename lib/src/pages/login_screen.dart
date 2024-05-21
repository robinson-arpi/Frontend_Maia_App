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

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  void _login(BuildContext context) async {
    final String email = emailController.text;
    final String password = passwordController.text;

    try {
      final apiProvider = Provider.of<ApiProvider>(context, listen: false);
      await apiProvider.login(email, password);
      await _storage.write(key: 'email', value: email);
      await _storage.write(key: 'password', value: password);
      await apiProvider.getClassSchedule();

      context.go('/home');
    } catch (error) {
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
                ),
                hoverColor: AppTheme.strongColorA,
              ),
              cursorColor: AppTheme.strongColorA,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                labelStyle: Theme.of(context).textTheme.headlineSmall,
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.strongColorA),
                ),
                hoverColor: AppTheme.strongColorA,
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _login(context),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(AppTheme.strongColorA),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                overlayColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed)) {
                      return AppTheme.strongColorA.withOpacity(0.5);
                    }
                    return null;
                  },
                ),
              ),
              child: const Text(
                'Iniciar sesión',
                style: TextStyle(color: AppTheme.softColorB),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
