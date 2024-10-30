import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'VisualizarCubiculosAdmin.dart'; // Importa tu pantalla de VisualizarCubiculosAdmin

class RegistrarCubiculo extends StatefulWidget {
  @override
  _RegistrarCubiculoState createState() => _RegistrarCubiculoState();
}

class _RegistrarCubiculoState extends State<RegistrarCubiculo> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _capacidadController = TextEditingController();
  bool isLoading = false;
  String? mensajeRespuesta;

  Future<void> _registrarCubiculo() async {
    final nombre = _nombreController.text;
    final capacidad = _capacidadController.text;

    // Validación de campos vacíos
    if (nombre.isEmpty || capacidad.isEmpty) {
      _showAlertDialog('Campos Vacíos', 'Por favor, complete todos los campos.');
      return;
    }

    // Validación de capacidad
    if (int.tryParse(capacidad) == null || int.parse(capacidad) <= 0) {
      _showAlertDialog('Capacidad Inválida', 'Por favor, ingresa una capacidad válida.');
      return;
    }

    setState(() {
      isLoading = true;
      mensajeRespuesta = null;
    });

    try {
      final url = Uri.parse('https://fico-back.onrender.com/cubicles/create/$nombre/$capacidad');
      final response = await http.post(url);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        setState(() {
          mensajeRespuesta = data['message'] ?? 'Cubículo registrado exitosamente';
        });
        _showSuccessDialog(); // Muestra el diálogo de éxito
      } else {
        setState(() {
          mensajeRespuesta = 'Error al registrar el cubículo. Intente nuevamente.';
        });
      }
    } catch (e) {
      setState(() {
        mensajeRespuesta = 'Error de conexión. Verifique su red.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Método para mostrar alertas
  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  // Método para mostrar diálogo de éxito
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Éxito'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 40),
              SizedBox(width: 10),
              Text('Cubículo registrado exitosamente!'),
            ],
          ),
        );
      },
    );

    // Cierra el diálogo después de 2 segundos y navega a VisualizarCubiculosAdmin
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop(); // Cierra el diálogo de éxito
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => VisualizarCubiculosAdmin(emailUsuario: '',), // Asegúrate de pasar el email del usuario
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center( // Centra el texto
        child: Text(
          'Registrar Cubículo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF9E110F), // Color rojo oscuro
            fontSize: 20,
          ),
        ),
      ),
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre del Cubículo',
                  labelStyle: TextStyle(color: Colors.grey[700]),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: const Color.fromRGBO(158, 17, 15, 1), width: 2.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre del cubículo';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _capacidadController,
                decoration: InputDecoration(
                  labelText: 'Capacidad',
                  labelStyle: TextStyle(color: Colors.grey[700]),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: const Color.fromRGBO(158, 17, 15, 1), width: 2.0),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la capacidad';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _registrarCubiculo,
                      child: Text('Registrar Cubículo', style: TextStyle(color: Colors.white)), // Texto en blanco
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(158, 17, 15, 1),
                      ),
                    ),
              if (mensajeRespuesta != null) ...[
                SizedBox(height: 16),
                Text(
                  mensajeRespuesta!,
                  style: TextStyle(
                    color: mensajeRespuesta == 'Cubículo registrado exitosamente'
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cerrar', style: TextStyle(color: Colors.white)), // Texto en blanco
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
