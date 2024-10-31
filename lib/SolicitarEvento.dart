import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SolicitarEvento extends StatefulWidget {
  @override
  _SolicitarEventoState createState() => _SolicitarEventoState();
}

class _SolicitarEventoState extends State<SolicitarEvento> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto para los campos del formulario
  TextEditingController nombreEventoController = TextEditingController();
  TextEditingController lugarController = TextEditingController();
  TextEditingController aforoController = TextEditingController();
  TextEditingController costoController = TextEditingController();
  TextEditingController fechaController = TextEditingController();
  TextEditingController imagenController = TextEditingController();
  TextEditingController equipoNecesarioController = TextEditingController();

  File? _imageFile;
  Uint8List? _webImage; // Para almacenar la imagen seleccionada en la web
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;
  String? mensajeRespuesta;

  @override
  void initState() {
    super.initState();
  }

  // Función para seleccionar una imagen
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        // Si estamos en la web, obtener los bytes de la imagen de manera asíncrona
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes;
          imagenController.text = pickedFile.path; // Asigna la ruta de la imagen
        });
      } else {
        // Si estamos en móviles, manejar como archivo
        setState(() {
          _imageFile = File(pickedFile.path);
          imagenController.text = pickedFile.path; // Asigna la ruta de la imagen
        });
      }
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          fechaController.text = DateFormat('yyyy-MM-dd HH:mm').format(
            DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            ),
          );
        });
      }
    }
  }

  Future<void> _solicitarEvento() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      const String apiUrl = 'https://fico-back.onrender.com/events/eventRequest';

      try {
        final request = http.MultipartRequest('POST', Uri.parse(apiUrl));

        // Adjuntar la imagen según el dispositivo
        if (_webImage != null) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'image',
              _webImage!,
              contentType: MediaType('image', 'jpeg'), // O el tipo adecuado
              filename: 'upload.jpg', // Puedes usar cualquier nombre de archivo
            ),
          );
        } else if (_imageFile != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'image',
              _imageFile!.path,
              contentType: MediaType('image', 'jpeg'), // O el tipo adecuado
            ),
          );
        }

        // Agregar los otros campos del formulario como form-data
        request.fields['nombre_evento'] = nombreEventoController.text;
        request.fields['lugar'] = lugarController.text;
        request.fields['aforo'] = aforoController.text;
        request.fields['costo'] = costoController.text;
        request.fields['fecha'] = fechaController.text;
        request.fields['equipo_necesario'] = equipoNecesarioController.text;

        final response = await request.send();
        final responseData = await response.stream.bytesToString();

        if (response.statusCode == 200 || response.statusCode == 201) {
          setState(() {
            mensajeRespuesta = json.decode(responseData)['message'] ?? 'Evento creado exitosamente';
          });
          await _showSuccessDialog();
          Navigator.pop(context); // Cierra la página actual
        } else {
          setState(() {
            mensajeRespuesta = 'Error al solicitar el evento: ${response.statusCode}';
          });
        }
      } catch (e) {
        setState(() {
          mensajeRespuesta = 'Error de conexión: $e';
        });
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _showSuccessDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Éxito'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Icon(Icons.check_circle, color: Colors.green, size: 60),
                SizedBox(height: 20),
                Text(mensajeRespuesta ?? 'Evento creado exitosamente.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    ).then((_) {
      Future.delayed(Duration(seconds: 3), () {
        Navigator.of(context).pop(); // Cierra el diálogo
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Text(
          'Solicitar Evento',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF9E110F), // Color rojo oscuro
            fontSize: 20,
          ),
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Campo nombre del evento
              TextFormField(
                controller: nombreEventoController,
                decoration: InputDecoration(labelText: 'Nombre del Evento'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa el nombre del evento';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: lugarController,
                decoration: InputDecoration(labelText: 'Lugar'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa el lugar';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: aforoController,
                decoration: InputDecoration(labelText: 'Aforo'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa el aforo';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: costoController,
                decoration: InputDecoration(labelText: 'Costo'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa el costo';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: fechaController,
                decoration: InputDecoration(labelText: 'Fecha y Hora'),
                readOnly: true,
                onTap: () => _selectDateTime(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa la fecha y hora';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text(_webImage == null && _imageFile == null ? 'Seleccionar Imagen' : 'Cambiar Imagen'),
              ),
              if (_webImage != null) 
                Image.memory(_webImage!, height: 100, width: 100),
              if (_imageFile != null && !kIsWeb)
                Image.file(_imageFile!, height: 100, width: 100),
              SizedBox(height: 16),
              TextFormField(
                controller: equipoNecesarioController,
                decoration: InputDecoration(labelText: 'Equipo Necesario'),
              ),
              SizedBox(height: 20),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _solicitarEvento,
                      child: Text('Solicitar Evento'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(158, 17, 15, 1),
                      ),
                    ),
              if (mensajeRespuesta != null) ...[
                SizedBox(height: 16),
                Text(
                  mensajeRespuesta!,
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
