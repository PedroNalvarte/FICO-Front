import 'dart:convert';
import 'package:fico_app/ListarEventosAdmin.dart';
import 'package:fico_app/RegistrarCubiculos.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_nav_bar/google_nav_bar.dart';
import 'PerfilAdmin.dart';

class Cubiculo {
  final int id;
  final String nombre;
  final int capacidad;

  Cubiculo({required this.id, required this.nombre, required this.capacidad});

  factory Cubiculo.fromJson(Map<String, dynamic> json) {
    return Cubiculo(
      id: json['id_cubiculo'],
      nombre: json['nombre_cubiculo'],
      capacidad: json['capacidad'],
    );
  }
}

class VisualizarCubiculosAdmin extends StatefulWidget {
  final String emailUsuario;

  VisualizarCubiculosAdmin({required this.emailUsuario});

  @override
  _VisualizarCubiculosAdminState createState() => _VisualizarCubiculosAdminState();
}

class _VisualizarCubiculosAdminState extends State<VisualizarCubiculosAdmin> {
  List<Cubiculo> cubiculos = [];
  bool mostrarDisponibles = true;
  bool isLoading = false;
  int _selectedIndex = 1; // Inicializa el índice seleccionado

  @override
  void initState() {
    super.initState();
    _cargarCubiculos();
  }

  Future<void> _cargarCubiculos() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<Cubiculo> listaCubiculos = mostrarDisponibles
          ? await obtenerCubiculosDisponibles()
          : await obtenerCubiculosNoDisponibles();
      
      setState(() {
        cubiculos = listaCubiculos;
      });
    } catch (e) {
      print("Error al cargar cubículos: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<List<Cubiculo>> obtenerCubiculosDisponibles() async {
    final response = await http.get(Uri.parse('https://fico-back.onrender.com/cubicles/available'));
    print("Status code (disponibles): ${response.statusCode}");
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => Cubiculo.fromJson(item)).toList();
    } else {
      throw Exception('Error al obtener cubículos disponibles');
    }
  }

  Future<List<Cubiculo>> obtenerCubiculosNoDisponibles() async {
    final response = await http.get(Uri.parse('https://fico-back.onrender.com/cubicles/notAvailable'));
    print("Status code (no disponibles): ${response.statusCode}");
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => Cubiculo.fromJson(item)).toList();
    } else {
      throw Exception('Error al obtener cubículos no disponibles');
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
          : cubiculos.isEmpty
              ? Center(
                  child: Text(
                    'No hay cubículos ${mostrarDisponibles ? 'disponibles' : 'no disponibles'}.',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : GridView.builder(
                  padding: EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: cubiculos.length,
                  itemBuilder: (context, index) {
                    final cubiculo = cubiculos[index];
                    return Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(Icons.meeting_room, color: const Color.fromRGBO(158, 17, 15, 1), size: 80),
                            Text(
                              cubiculo.nombre,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Capacidad: ${cubiculo.capacidad} personas',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20, bottom: 120),
            child: Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return RegistrarCubiculo(); // Llama al pop-up de registro
                    },
                  );
                },
                child: Icon(Icons.add, color: Colors.white),
                backgroundColor: Color.fromRGBO(158, 17, 15, 1),
                shape: CircleBorder(),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  mostrarDisponibles = !mostrarDisponibles;
                  _cargarCubiculos();
                });
              },
              backgroundColor: const Color.fromARGB(255, 54, 114, 244),
              child: Icon(
                mostrarDisponibles ? Icons.visibility : Icons.visibility_off,
                color: Colors.white,
              ),
              tooltip: mostrarDisponibles ? 'Ver no disponibles' : 'Ver disponibles',
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: GNav(
            backgroundColor: const Color.fromRGBO(158, 17, 15, 1),
            color: Colors.white,
            activeColor: const Color.fromRGBO(158, 17, 15, 1),
            tabBackgroundColor: Colors.white,
            gap: 12,
            padding: const EdgeInsets.all(22),
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              if (index == 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListarEventAdmin(email: widget.emailUsuario),
                  ),
                );
              } else if (index == 1) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VisualizarCubiculosAdmin(emailUsuario: widget.emailUsuario),
                  ),
                );
              } else if (index == 2) {
                // Si tienes una vista de Equipos, maneja la navegación aquí
              } else if (index == 3) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PerfilAdminPage(emailUsuario: widget.emailUsuario),
                  ),
                );
              }
            },
            tabs: const [
              GButton(icon: Icons.calendar_today, text: 'Eventos'),
              GButton(icon: Icons.meeting_room, text: 'Cubículos'),
              GButton(icon: Icons.computer, text: 'Equipos'), // Si tienes una vista de equipos
              GButton(icon: Icons.person, text: 'Perfil'),
            ],
          ),
        ),
      ),
    );
  }
}
