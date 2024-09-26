import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'homepage.dart';

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

    final url =
        Uri.parse('https://fico-back.onrender.com/auth/login/$email/$password');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final result = json.decode(response.body);

        setState(() {
          if (result == "Usuario no existe") {
            _showErrorDialog("Usuario no existe");
          } else if (result == "Contraseña incorrecta") {
            _showErrorDialogWithImage("Contraseña incorrecta");
          } else {
            _message = 'Bienvenido, $result';
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
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

  // Función para mostrar el pop-up de error para "Usuario no existe"
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text("Error")),
          content: Text(
            message,
            textAlign: TextAlign.center, // Centra el texto del contenido
          ),
          actions: [
            Center(
              child: TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop(); // Cerrar el diálogo
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // Función para mostrar el pop-up con la imagen para "Contraseña incorrecta"
  void _showErrorDialogWithImage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text("Error")),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Añadir la imagen de "incorrecto.png"
              Image.asset(
                'web/icons/incorrecto.png', // Ruta de la imagen
                height: 80, // Ajusta el tamaño de la imagen si es necesario
              ),
              const SizedBox(height: 20),
              // Mensaje centrado
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
                  Navigator.of(context).pop(); // Cerrar el diálogo
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
              // Logo de la parte superior centrado
              Center(
                child: Image.asset(
                  'web/icons/1.png', // Aquí va tu logo de FICO
                  height: 200, // Ajusta el tamaño del logo de FICO
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
              // Campo de correo electrónico
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
              // Campo de contraseña
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
              // Botón de iniciar sesión
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB71C1C), // Color rojo del botón
                  padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.white), // Asegura que el texto sea blanco
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // Lógica para iniciar sesión con Microsoft
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Fondo blanco
                  padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal:
                          30), // Aumentamos el padding para hacerlo más grande
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Colors.grey),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize
                      .min, // Para que el ancho se ajuste al contenido
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Centrar el contenido
                  children: [
                    Image.asset(
                      'web/icons/microsoftlogo (1).png', // Ruta de la imagen
                      height: 32, // Aumenta el tamaño del ícono a 32px
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text('- O -'),
              const SizedBox(height: 10),
              // Texto de crear cuenta
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
              Text(_message),
            ],
          ),
        ),
      ),
    );
  }
}
