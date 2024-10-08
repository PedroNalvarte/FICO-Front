import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'validate_code_page.dart';

class ResetMailPage extends StatefulWidget {
  const ResetMailPage({super.key});

  @override
  _ResetMailPageState createState() => _ResetMailPageState();
}

class _ResetMailPageState extends State<ResetMailPage> {
  final TextEditingController _emailController = TextEditingController();
  String _message = '';

  Future<void> _sendResetCode() async {
    final String email = _emailController.text;

    final url =
        Uri.parse('https://fico-back.onrender.com/auth/resetMail/$email');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final result = json.decode(response.body);

        if (result.containsKey('codigo')) {
          // Redirigir a ValidateCodePage con el email y código enviado
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ValidateCodePage(
                email: email,
                codigoEnviado: result['codigo'],
              ),
            ),
          );
        } else {
          setState(() {
            _message = 'Error al enviar el código. Inténtalo de nuevo.';
          });
        }
      } else if (response.statusCode == 400) {
        // Mostrar modal si la cuenta no existe
        _showErrorDialog('La cuenta no existe');
      } else {
        setState(() {
          _message = 'Error al enviar el código. Inténtalo de nuevo.';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error de red. Inténtalo de nuevo.';
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Center(
            child: Text(
              "Error",
              style: TextStyle(
                color: const Color(0xFFB71C1C),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB71C1C),
                  padding: const EdgeInsets.symmetric(
                      vertical: 15, horizontal: 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Cerrar el diálogo
                },
                child: const Text(
                  "OK",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Restablecer Contraseña',
          style: TextStyle(color: Colors.grey[800]),
        ),
        iconTheme: IconThemeData(color: Colors.grey[800]),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: size.height * 0.1),
              // Campo de correo electrónico
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Correo Electrónico',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Introduce tu correo para recibir el código',
                style: TextStyle(
                  color: Color(0xFF757575),
                ),
              ),
              const SizedBox(height: 30),
              // Botón de enviar código
              ElevatedButton(
                onPressed: _sendResetCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB71C1C),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Enviar Código',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                _message,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
