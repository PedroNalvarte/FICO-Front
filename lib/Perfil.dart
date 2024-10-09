import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_nav_bar/google_nav_bar.dart';
import 'CambiarContra.dart'; 

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
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                        ],
                      ),
                    ),
                  ],
                ),
                bottomNavigationBar: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20), 
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: GNav(
                      onTabChange: (index) {
                        setState(() {
                          if (index == 0) { // Eventos
                            vistaActual = "eventos";
                          } else if (index == 1) { // Reservas
                            vistaActual = "reservas";
                          } else if (index == 2) { // Equipos
                            vistaActual = "equipos";
                          } else if (index == 3) { // Perfil
                            vistaActual = "perfil";
                          }
                        });
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
                        GButton(icon: Icons.computer, text: 'Equipos'),
                        GButton(icon: Icons.person, text: 'Perfil'),
                      ],
                    ),
                  ),
                ),
              );
            }
          }
