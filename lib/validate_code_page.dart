import 'package:flutter/material.dart';
import 'reset_password_page.dart';

class ValidateCodePage extends StatefulWidget {
  final String email;
  final String codigoEnviado;

  const ValidateCodePage({required this.email, required this.codigoEnviado});

  @override
  _ValidateCodePageState createState() => _ValidateCodePageState();
}

class _ValidateCodePageState extends State<ValidateCodePage> {
  final TextEditingController _codigoController = TextEditingController();

  void _validateCode() {
    if (_codigoController.text == widget.codigoEnviado) {
      // Mostrar modal de éxito
      showDialog(
        context: context,
        barrierDismissible: false, // Evita cerrar el modal al tocar fuera de él
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Center(child: Text("Éxito")),
            content: const Text("Código correcto. Redirigiendo..."),
          );
        },
      );

      // Redirigir después de 3 segundos
      Future.delayed(Duration(seconds: 3), () {
        Navigator.of(context).pop(); // Cerrar el modal
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordPage(email: widget.email),
          ),
        );
      });
    } else {
      // Mostrar error si el código es incorrecto
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: const Text("Código incorrecto. Inténtalo de nuevo."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cerrar el diálogo
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Validar Código',
          style: TextStyle(color: Colors.grey[800]),
        ),
        iconTheme: IconThemeData(color: Colors.grey[800]), // Color del ícono de retroceso
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _codigoController,
              decoration: InputDecoration(
                labelText: 'Ingresa el código recibido',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _validateCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB71C1C), // Color rojo del botón
                padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Validar Código',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
