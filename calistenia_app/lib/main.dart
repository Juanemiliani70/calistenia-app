import 'package:flutter/material.dart';
import 'package:calistenia_app/core/constants/app_theme.dart';
import 'package:calistenia_app/core/storage/token_storage.dart';
import 'package:calistenia_app/features/auth/presentation/screens/login_screen.dart';
import 'package:calistenia_app/features/home/presentation/screens/home_screen.dart';

void main() async {
  // Necesario para usar plugins antes de runApp
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KaizenCalistenia());
}

class KaizenCalistenia extends StatelessWidget {
  const KaizenCalistenia({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kaizen Calistenia',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      // Verificar si el usuario ya tiene sesión iniciada
      home: FutureBuilder<bool>(
        future: TokenStorage.estaLogueado(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          // Si tiene token → ir al home, si no → ir al login
          if (snapshot.data == true) {
            return const HomeScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}