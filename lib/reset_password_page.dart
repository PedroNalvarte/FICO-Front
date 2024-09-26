import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_page.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;

  const ResetPasswordPage({required this.email});

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _resetPassword() async {
    final String newPassword = _passwordController.text;

    final url = Uri.parse('https://fico-back.onrender.com/auth/resetPassword/${widget.email}/$newPassword');

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result == 'Contraseña actualizada exitosamente') {
          // Mostrar modal de éxito
          showDialog(
            context: context,
            barrierDismissible: false, // Evita cerrar el modal tocando fuera de él
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Éxito"),
                content: const Text("Contraseña cambiada con éxito."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                        (Route<dynamic> route) => false,
                      );
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          setState(() {
            _message = result;
          });
        }
      } else {
        setState(() {
          _message = 'Error al cambiar la contraseña';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error de red';
      });
    }
  }

  String _message = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Cambiar Contraseña',
          style: TextStyle(color: Colors.grey[800]),
        ),
        iconTheme: IconThemeData(color: Colors.grey[800]),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Nueva Contraseña',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB71C1C),
                padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Cambiar Contraseña',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _message,
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
