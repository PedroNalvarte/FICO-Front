import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show File; 
import 'dart:typed_data'; 
import 'package:image_picker/image_picker.dart'; 
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart'; 
import 'package:flutter/foundation.dart'; 
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
class RegistrarEvento extends StatefulWidget {
  @override
  _RegistrarEventoState createState() => _RegistrarEventoState();
}

class _RegistrarEventoState extends State<RegistrarEvento> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto para los campos del formulario
  TextEditingController nombreController = TextEditingController();
  TextEditingController lugarController = TextEditingController();
  TextEditingController aforoController = TextEditingController();
  TextEditingController costoController = TextEditingController();
  TextEditingController creadorController = TextEditingController();
  TextEditingController fechaController = TextEditingController();

  File? _imageFile;
  Uint8List? _webImage; // Para almacenar la imagen seleccionada en la web
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String userId = prefs.getString('user_id') ?? '';
    setState(() {
      creadorController.text = userId; // Asignar el ID del usuario automáticamente
    });
  }
  // Función para seleccionar una imagen
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      if (kIsWeb) {
        // Si estamos en la web, obtener los bytes de la imagen
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes;
        });
      } else {
        // Si estamos en móviles, manejar como archivo
        setState(() {
          _imageFile = File(pickedFile.path);
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

  // Función para registrar el evento a través de la API
  Future<void> registrarEvento() async {
    if (_formKey.currentState!.validate()) {
      const String apiUrl = 'https://fico-back.onrender.com/events/create';

      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      // Adjuntar la imagen según el dispositivo
      if (kIsWeb && _webImage != null) {
        // Para Flutter Web: Subir la imagen como bytes
        var mimeTypeData = lookupMimeType('', headerBytes: _webImage);
        var mimeType = mimeTypeData?.split('/');
        if (mimeType != null && mimeType.length == 2) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'image',
              _webImage!,
              contentType: MediaType(mimeType[0], mimeType[1]), // Maneja cualquier tipo de imagen (png, jpg, etc.)
              filename: 'upload.${mimeType[1]}',  // Usa la extensión correcta (png o jpg)
            ),
          );
        } else {
          print("Tipo MIME desconocido.");
        }
      } else if (_imageFile != null) {
        // Para móviles: Subir la imagen como archivo
        var mimeTypeData = lookupMimeType(_imageFile!.path);
        var mimeType = mimeTypeData?.split('/');
        if (mimeType != null && mimeType.length == 2) {
          var imageUpload = await http.MultipartFile.fromPath(
            'image',
            _imageFile!.path,
            contentType: MediaType(mimeType[0], mimeType[1]),
            filename: 'upload.${mimeType[1]}', // Usa la extensión correcta (png o jpg)
          );
          request.files.add(imageUpload);
        } else {
          print("Tipo MIME desconocido.");
        }
      } else {
        // Si no hay imagen seleccionada, puedes manejarlo como quieras
        print("No se ha seleccionado una imagen.");
      }

      // Agregar los otros campos del formulario como form-data
      request.fields['nombre_evento'] = nombreController.text;
      request.fields['lugar'] = lugarController.text;
      request.fields['aforo'] = aforoController.text;
      request.fields['costo'] = costoController.text;
      request.fields['fecha'] = fechaController.text;

      try {
        // Enviar la solicitud
        var response = await request.send();
        var responseData = await response.stream.bytesToString();

        // Manejo de la respuesta
        if (response.statusCode == 201) { // Código 201 indica creación exitosa
        var jsonResponse = json.decode(responseData);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Evento creado exitosamente: ${jsonResponse['message']}'),
          backgroundColor: Colors.green,  // Fondo verde para éxito
        ));
        Navigator.pop(context); // Cierra el pop-up si es necesario
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al crear el evento: ${response.statusCode}'),
          backgroundColor: Colors.red,  // Fondo rojo para error
        ));
      }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error al conectar con el servidor: $e'),
            backgroundColor: Colors.red,  // Fondo rojo para error
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor, completa todos los campos y selecciona una imagen.'),
          backgroundColor: Colors.orange,  // Fondo naranja para advertencia
        ));
      }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Registrar Nuevo Evento',
        style: TextStyle(
          fontWeight: FontWeight.bold, // Negrita
          color: Color(0xFF9E110F),    // Color rojo oscuro
          fontSize: 20,                // Puedes ajustar el tamaño de fuente si lo deseas
        ),
      ),

      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              //campo nombre del evento
              TextFormField(
                controller: nombreController,
                decoration: InputDecoration(

                labelText: 'Nombre del evento',
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
                    return 'Por favor ingresa el nombre del evento';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16),

              //campo Lugar
              TextFormField(
                controller: lugarController,
                decoration: InputDecoration(

                labelText: 'Lugar',
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
                    return 'Por favor ingresa el lugar';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16),
              //Campo Foro
              
              TextFormField(
                controller: aforoController,
                decoration: InputDecoration(

                labelText: 'Aforo',
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
                    return 'Por favor ingresa el aforo';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16),
              //Campo costo
              TextFormField(
                controller: costoController,
                decoration: InputDecoration(

                labelText: 'Costo',
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
                    return 'Por favor ingresa el costo';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16),
              
            //Campo Fecha
              TextFormField(
                controller: fechaController,
                decoration: InputDecoration(
                  labelText: 'Fecha y hora',
                  labelStyle: TextStyle(color: Colors.grey[700]),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: const Color.fromRGBO(158, 17, 15, 1), width: 2.0),
                  ),
                ),
                readOnly: true,
                onTap: () => _selectDateTime(context),

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la fecha y hora';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text(_webImage == null && _imageFile == null ? 'Seleccionar Imagen' : 'Cambiar Imagen'),
              ),
              if (_webImage != null) 
                Image.memory(_webImage!, height: 100, width: 100),
              if (_imageFile != null && !kIsWeb)
                Image.file(_imageFile!, height: 100, width: 100),
            ],
          ),
        ),
      ),
      actions: [
  // Botón de "Cancelar"
  ElevatedButton(
    onPressed: () {
      Navigator.of(context).pop();
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.grey[600], // Color para el botón de cancelar
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Bordes redondeados
      ),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15), // Tamaño del botón
    ),
    child: const Text(
      'Cancelar',
      style: TextStyle(
        color: Colors.white, // Texto blanco
      ),
    ),
  ),
  
  // Botón de "Registrar"
  ElevatedButton(
    onPressed: registrarEvento,
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF9E110F), // Color de fondo (rojo oscuro)
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Bordes redondeados
      ),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15), // Tamaño del botón
    ),
        child: const Text(
          'Registrar',
          style: TextStyle(
            color: Colors.white, // Texto blanco
          ),
        ),
      ),
    ],
    );
  }
}