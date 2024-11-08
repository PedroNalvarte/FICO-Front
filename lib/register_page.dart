import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Nuevos campos
  String? _selectedGrade; // Carrera
  int? _selectedPeriod; // Ciclo
  final List<String> _grades = ['Ingeniería de Sistemas', 'Ingeniería Industrial', 'Arquitectura', 'Ingeniería Civil',  'Aeronáutica'];
  final List<int> _periods = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  Future<void> _register() async {
    final String nombre = _nombreController.text;
    final String apellido = _apellidoController.text;
    final String email = _emailController.text;
    final String password = _passwordController.text;

    final url = Uri.parse('https://fico-back.onrender.com/auth/registerUser');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'nombre': nombre,
          'apellido': apellido,
          'email': email,
          'password': password, // Contraseña sin encriptar
          'grade': _selectedGrade,
          'period': _selectedPeriod,
        }),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result == "Usuario registrado exitosamente") {
          _showSuccessDialog("Cuenta registrada exitosamente");
        } else {
          _showErrorDialog("Registro no exitoso: $result");
        }
      } else {
        _showErrorDialog("Error al registrar el usuario: ${response.statusCode}");
      }
    } catch (e) {
      _showErrorDialog("Error de red: ${e.toString()}");
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
              child: Text("OK"),
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
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Éxito"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[800]),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Color.fromRGBO(158, 17, 15, 1)),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<dynamic> items, dynamic selectedItem, Function(dynamic) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Color.fromRGBO(158, 17, 15, 1)),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<dynamic>(
            value: selectedItem,
            onChanged: onChanged,
            isExpanded: true,
            items: items.map<DropdownMenuItem<dynamic>>((dynamic value) {
              return DropdownMenuItem<dynamic>(
                value: value,
                child: Text(value.toString()),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Registrar Usuario",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromRGBO(158, 17, 15, 1),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Crear Cuenta",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(158, 17, 15, 1),
                  ),
                ),
                SizedBox(height: 20),
                _buildTextField("Nombre", _nombreController),
                _buildTextField("Apellido", _apellidoController),
                _buildTextField("Correo electrónico", _emailController),
                _buildTextField("Contraseña", _passwordController, obscureText: true),
                _buildDropdownField("Carrera", _grades, _selectedGrade, (value) {
                  setState(() {
                    _selectedGrade = value;
                  });
                }),
                _buildDropdownField("Ciclo", _periods, _selectedPeriod, (value) {
                  setState(() {
                    _selectedPeriod = value;
                  });
                }),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(158, 17, 15, 1),
                    padding: EdgeInsets.symmetric(horizontal: 100, vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                  ),
                  onPressed: _register,
                  child: Text(
                    'Registrar',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
