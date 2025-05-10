import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final nombreController = TextEditingController();
  final contrasenaController = TextEditingController();

  void iniciarSesion() async {
    final nombre = nombreController.text.trim();
    final contrasena = contrasenaController.text.trim();

    if (nombre.isEmpty || contrasena.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor llena todos los campos')),
      );
      return;
    }

    final usuario = await ApiService.login(nombre, contrasena);

    if (usuario != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bienvenido, ${usuario['Nombre']}')),
      );
      Navigator.pushReplacementNamed(context, '/crearOficio', arguments: usuario);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Credenciales incorrectas')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nombreController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: contrasenaController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: iniciarSesion,
              child: Text('Iniciar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}



