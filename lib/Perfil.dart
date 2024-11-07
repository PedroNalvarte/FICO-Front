import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_nav_bar/google_nav_bar.dart';
import 'CambiarContra.dart'; 
import 'HomePage.dart';
import 'VisualizarCubiculosDisponibles.dart';
import 'login_page.dart'; // Importa tu página de login

class PerfilPage extends StatefulWidget {
  final String emailUsuario;

  const PerfilPage({Key? key, required this.emailUsuario}) : super(key: key);

  @override
  _PerfilPageState createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  int _selectedIndex = 3;
  String vistaActual = "Perfil";
  String? nombreUsuario;
  String? apellidoUsuario;
  String? emailUsuario;
  String? passwordUsuario;
  String? avatarUrl;
  String? carreraAcad; // Añadido para carrera académica
  int? ciclo; // Añadido para ciclo
  bool isLoading = true;
  String error = '';

  TextEditingController passwordActualController = TextEditingController();
  TextEditingController passwordNuevoController = TextEditingController();
  TextEditingController passwordConfirmacionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserProfile(widget.emailUsuario);
  }

  Future<void> fetchUserProfile(String email) async {
    final url = 'https://fico-back.onrender.com/user/getUserProfile/$email';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          nombreUsuario = data['nombre'];
          apellidoUsuario = data['apellido'];
          emailUsuario = data['email'];
          passwordUsuario = data['password'];
          avatarUrl = data['avatar'];
          carreraAcad = data['carrera_acad']; // Obtener carrera académica
          ciclo = data['ciclo']; // Obtener ciclo
          isLoading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          error = 'Usuario no existe';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error al obtener datos del usuario';
        isLoading = false;
      });
    }
  }

  void _cerrarSesion() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()), // Redirige a login_page.dart
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 150,
        flexibleSpace: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        'web/icons/LogoFico.png',
                        height: 110,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.black),
                    onPressed: () {
                      // Lógica para notificaciones
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(child: Text(error))
              : ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                       mainAxisAlignment: MainAxisAlignment.center, // Centrar el contenido verticalmente
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                            child: avatarUrl == null ? Icon(Icons.person) : null,
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: TextEditingController(text: nombreUsuario ?? ''),
                            decoration: InputDecoration(
                              labelText: 'Nombre',
                              labelStyle: TextStyle(color: Colors.grey[700]),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: const Color.fromRGBO(158, 17, 15, 1), width: 2.0),
                              ),
                            ),
                            readOnly: true,
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: TextEditingController(text: apellidoUsuario ?? ''),
                            decoration: InputDecoration(
                              labelText: 'Apellido',
                              labelStyle: TextStyle(color: Colors.grey[700]),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: const Color.fromRGBO(158, 17, 15, 1), width: 2.0),
                              ),
                            ),
                            readOnly: true,
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: TextEditingController(text: carreraAcad ?? ''),
                            decoration: InputDecoration(
                              labelText: 'Carrera Académica',
                              labelStyle: TextStyle(color: Colors.grey[700]),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: const Color.fromRGBO(158, 17, 15, 1), width: 2.0),
                              ),
                            ),
                            readOnly: true,
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: TextEditingController(text: ciclo != null ? ciclo.toString() : ''),
                            decoration: InputDecoration(
                              labelText: 'Ciclo',
                              labelStyle: TextStyle(color: Colors.grey[700]),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: const Color.fromRGBO(158, 17, 15, 1), width: 2.0),
                              ),
                            ),
                            readOnly: true,
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: TextEditingController(text: widget.emailUsuario),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(color: Colors.grey[700]),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: const Color.fromRGBO(158, 17, 15, 1), width: 2.0),
                              ),
                            ),
                            readOnly: true,
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: TextEditingController(text: passwordUsuario ?? ''),
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              labelStyle: TextStyle(color: Colors.grey[700]),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: const Color.fromRGBO(158, 17, 15, 1), width: 2.0),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        child: CambiarContrasenaPage(userEmail: widget.emailUsuario),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            readOnly: true,
                          ),
                          
                          SizedBox(height: 30),
                          Center(
                            child: ElevatedButton(
                              onPressed: _cerrarSesion,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromRGBO(158, 17, 15, 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                              ),
                              child: Text(
                                'Cerrar Sesión',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: GNav(
            selectedIndex: 2, // Perfil como seleccionado
            onTabChange: (index) {
              if (index == 0) { // Eventos
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(email: widget.emailUsuario),
                  ),
                );
              } else if (index == 1) { // Reservas
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VisualizarCubiculosDisponibles(emailUsuario: widget.emailUsuario),
                  ),
                );
              } else if (index == 2) { // Perfil
                setState(() {
                  // Mantener la selección en Perfil
                });
              }
            },
            backgroundColor: const Color.fromRGBO(158, 17, 15, 1),
            color: Colors.white,
            activeColor: const Color.fromRGBO(158, 17, 15, 1),
            tabBackgroundColor: Colors.white,
            gap: 12,
            padding: const EdgeInsets.all(22),
            tabs: const [
              GButton(icon: Icons.calendar_today, text: 'Eventos'),
              GButton(icon: Icons.tab, text: 'Reservas'),
              GButton(icon: Icons.person, text: 'Perfil'),
            ],
          ),
        ),
      ),
    );
  }
}
