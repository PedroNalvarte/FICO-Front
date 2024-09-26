import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'homepage.dart'; // Página del cliente
import 'listarEventosAdmin.dart'; // Página del admin
import 'reset_mail_page.dart'; // Página de recuperación de contraseña

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _message = '';

  Future<void> _login() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;

    final url = Uri.parse('https://fico-back.onrender.com/auth/login/$email/$password');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final result = json.decode(response.body);

        setState(() {
          if (result['id_rol'] == 1) {
            // Redirigir a la página del admin
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ListarEventAdmin()),
            );
          } else if (result['id_rol'] == 2) {
            // Redirigir a la página del cliente
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }
        });
      } else if (response.statusCode == 400) {
        // Si el backend devuelve 400, manejamos los errores de manera separada
        final result = json.decode(response.body);
        setState(() {
          if (result['error'] == "Usuario no existe") {
            _showErrorDialog("Usuario no existe");
          } else if (result['error'] == "Contraseña incorrecta") {
            _showErrorDialogWithImage("Contraseña incorrecta");
          }
        });
      } else {
        setState(() {
          _message = 'Error al iniciar sesión';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error de red';
      });
    }
  }

  // Mostrar diálogo de error si el usuario no existe
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text("Error")),
          content: Text(
            message,
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // Mostrar diálogo de error si la contraseña es incorrecta
  void _showErrorDialogWithImage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text("Error")),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'web/icons/incorrecto.png',
                height: 80,
              ),
              const SizedBox(height: 20),
              Text(
                message,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            Center(
              child: TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: size.height * 0.1),
              Center(
                child: Image.asset(
                  'web/icons/1.png',
                  height: 200,
                ),
              ),
              SizedBox(height: size.height * 0.05),
              Text(
                'Inicia sesión en tu cuenta',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Correo',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB71C1C),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Iniciar Sesión',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // Lógica para iniciar sesión con Microsoft
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Colors.grey),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'web/icons/microsoftlogo (1).png',
                      height: 32,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text('- O -'),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("¿Aún no tienes cuenta?",
                      style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      // Lógica para crear una cuenta
                    },
                    child: const Text(
                      "Crear Cuenta",
                      style: TextStyle(
                        color: Color(0xFFB71C1C),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ResetMailPage(), // Redirige a la página de recuperación de contraseña
                    ),
                  );
                },
                child: const Text(
                  "Recuperar Contraseña",
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(_message),
            ],
          ),
        ),
      ),
    );
  }
}
