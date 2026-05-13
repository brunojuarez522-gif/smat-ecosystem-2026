import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _user = TextEditingController();
  final _pass = TextEditingController();
  bool _cargando = false;

  void _entrar() async {
    setState(() => _cargando = true); // Activamos carga
    
    bool ok = await AuthService().login(_user.text, _pass.text);
    
    if (ok && mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error")));
    }

    if (mounted) setState(() => _cargando = false); // Desactivamos carga
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            TextField(controller: _user, decoration: const InputDecoration(labelText: "Usuario")),
            TextField(controller: _pass, decoration: const InputDecoration(labelText: "Clave"), obscureText: true),
            const SizedBox(height: 20),
            // Si _cargando es true muestra el círculo, si no, muestra el botón 
            _cargando 
              ? const CircularProgressIndicator() 
              : ElevatedButton(onPressed: _entrar, child: const Text("ENTRAR")),
          ],
        ),
      ),
    );
  }
}