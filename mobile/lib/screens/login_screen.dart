import 'package:flutter/material.dart';
import 'home_page.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar Sesión')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Esto es solo un puente temporal para que puedas entrar al Home
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
          child: const Text('Entrar a la App'),
        ),
      ),
    );
  }
}