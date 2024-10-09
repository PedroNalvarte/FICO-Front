import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CambiarContrasenaPage extends StatefulWidget {
  final String userEmail;

  CambiarContrasenaPage({Key? key, required this.userEmail}) : super(key: key);

  @override
  _CambiarContrasenaPageState createState() => _CambiarContrasenaPageState();
}


class _CambiarContrasenaPageState extends State<CambiarContrasenaPage> {
  
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();

Future<void> updatePassword() async {
  if (_newPasswordController.text != _confirmNewPasswordController.text) {
    _showErrorDialog('La contraseña nueva no fue repetida correctamente');
    return;
  }

  if (_newPasswordController.text == _oldPasswordController.text) {
    _showErrorDialog('La contraseña nueva no puede ser igual a la anterior');
    return;
  }

  _showConfirmationDialog();
}

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min, // Esto asegura que la columna solo sea tan alta como sus hijos
            children: [
              Icon(Icons.warning, color: Color(0xFF9E110F), size: 120), // Ícono de advertencia más grande y en color rojo
              SizedBox(height: 10), // Espacio vertical
              Text("¿Seguro que deseas cambiar de contraseña?"), // Texto de confirmación
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                "No",
                style: TextStyle(color: Color(0xFF9E110F)), // Establece el color del texto
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo de confirmación
              },
            ),

            TextButton(
              child: Text(
                "Sí",
                style: TextStyle(color: Color(0xFF9E110F)),
                ),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo de confirmación
                _performPasswordUpdate(); // Llama a la actualización de la contraseña
              },
            ),
          ],
        );
      },
    );
  }


Future<void> _performPasswordUpdate() async {
  var url = Uri.parse('https://fico-back.onrender.com/user/updatePassword/${widget.userEmail}/${_oldPasswordController.text}/${_newPasswordController.text}/${_confirmNewPasswordController.text}');
  try {
    var response = await http.post(url);
    if (response.statusCode == 200) {
      _showSuccessDialog('Contraseña actualizada correctamente');
    } else {
      var result = jsonDecode(response.body);
      _showErrorDialog(result['error']);
    }
  } catch (e) {
    _showErrorDialog('No se pudo conectar al servidor');
  }
}
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
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


void _showSuccessDialog(String message) {
  showDialog(
    context: context,
    barrierDismissible: false, // Para que no se pueda cerrar el diálogo tocando fuera de él
    builder: (BuildContext context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min, // Para que el contenido no ocupe más espacio del necesario
          children: <Widget>[
            Icon(Icons.check_circle, color: Colors.green, size: 100), // Icono grande y verde
            SizedBox(height: 10), // Espacio vertical para separar el ícono del texto
            Text(
              message,
              style: TextStyle(
                fontSize: 20, // Aumentar // Hacer el texto negrita
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text('OK', style: TextStyle(color: Color(0xFF9E110F))), // Botón con texto en color rojo
            onPressed: () {
              Navigator.of(context).pop(); // Cierra el AlertDialog
              Navigator.of(context).pop(); // Cierra el diálogo de cambiar contraseña
            },
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), // Bordes redondeados para el AlertDialog
        backgroundColor: Colors.white, // Fondo blanco para el AlertDialog
      );
    },
  );
}




  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      width: MediaQuery.of(context).size.width * 0.9, // Ajusta el tamaño según necesites
      child: Column(
        mainAxisSize: MainAxisSize.min, // Esto hace que el tamaño del diálogo sea el mínimo necesario
        children: <Widget>[
          Text(
            'Actualizar Contraseña',  // Título del formulario
            style: TextStyle(
              fontSize: 20,  // Tamaño de fuente
              fontWeight: FontWeight.bold,  // Negrita
              color: Color(0xFF9E110F),   // Color del texto
            ),
          ),

          SizedBox(height: 20),

          TextFormField(
            controller: _oldPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Contraseña actual',
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
                return 'Por favor ingresa tu contraseña actual';
              }
              return null;
            },
          ),

          SizedBox(height: 20),

          TextFormField(
            controller: _newPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Nueva contraseña',
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
                return 'Por favor ingresa una nueva contraseña';
              }
              return null;
            },
          ),

          SizedBox(height: 20),

          TextFormField(
            controller: _confirmNewPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Confirmar nueva contraseña',
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
                return 'Por favor confirma tu nueva contraseña';
              }
              if (value != _newPasswordController.text) {
                return 'La confirmación no coincide con la nueva contraseña';
              }
              return null;
            },
          ),

          SizedBox(height: 20),

          ElevatedButton(
            onPressed: updatePassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF9E110F), // Color de fondo (rojo oscuro)
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // Bordes redondeados
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15), // Tamaño del botón
            ),
            child: Text(
              'Actualizar Contraseña',
              style: TextStyle(
                color: Colors.white, // Texto blanco
              ),
            ),
          ),
        ],
      ),
    );
  }
}