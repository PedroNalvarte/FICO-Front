import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EliminarEventoDialog extends StatelessWidget {
  final int eventoId;

  const EliminarEventoDialog({Key? key, required this.eventoId}) : super(key: key);

  Future<void> eliminarEvento(BuildContext context) async {
    var url = Uri.parse('https://fico-back.onrender.com/events/eventDelete/$eventoId');
    try {
      var response = await http.delete(url);
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        if (result['Success'] == "Evento eliminado correctamente") {
          Navigator.of(context).pop(); // Cierra el diálogo de confirmación
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['Success']), backgroundColor: Colors.green)
          );
        }
      } else {
        throw Exception('Error al eliminar el evento');
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text('No se pudo conectar al servidor o error en la eliminación'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Confirmar Eliminación'),
      content: Text('¿Estás seguro de que quieres eliminar este evento?'),
      actions: <Widget>[
        TextButton(
          child: Text('No'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text('Sí'),
          onPressed: () => eliminarEvento(context),
        ),
      ],
    );
  }
}
