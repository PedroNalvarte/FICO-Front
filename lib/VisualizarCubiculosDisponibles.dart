import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'ReservarCubiculo.dart';
import 'HomePage.dart';
import 'Perfil.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class CubiculoDisponible {
  final int idCubiculo;
  final String nombreCubiculo;
  final int capacidad;

  CubiculoDisponible({
    required this.idCubiculo,
    required this.nombreCubiculo,
    required this.capacidad,
  });

  factory CubiculoDisponible.fromJson(Map<String, dynamic> json) {
    return CubiculoDisponible(
      idCubiculo: json['id_cubiculo'] ?? 0,
      nombreCubiculo: json['nombre_cubiculo'] ?? "Cubículo sin nombre",
      capacidad: json['capacidad'] ?? 0,
    );
  }
}

class VisualizarCubiculosDisponibles extends StatefulWidget {
  final String emailUsuario;

  VisualizarCubiculosDisponibles({required this.emailUsuario});

  @override
  _VisualizarCubiculosDisponiblesState createState() => _VisualizarCubiculosDisponiblesState();
}

class _VisualizarCubiculosDisponiblesState extends State<VisualizarCubiculosDisponibles> {
  List<CubiculoDisponible> cubiculosDisponibles = [];
  bool isLoading = true;
  String? mensajeError;
  int _selectedIndex = 1; // Mantener el índice de 'Reservas' seleccionado

  @override
  void initState() {
    super.initState();
    _fetchCubiculosDisponibles();
  }

  Future<void> _fetchCubiculosDisponibles() async {
    setState(() {
      isLoading = true;
      mensajeError = null;
    });

    final url = Uri.parse('https://fico-back.onrender.com/cubicles/available');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          cubiculosDisponibles = data.map((item) => CubiculoDisponible.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          mensajeError = 'Error al obtener cubículos disponibles. Código de estado: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        mensajeError = 'Error de conexión: $e';
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
          : mensajeError != null
              ? Center(child: Text(mensajeError!, style: TextStyle(color: Colors.red)))
              : cubiculosDisponibles.isEmpty
                  ? Center(child: Text('No hay cubículos disponibles.'))
                  : GridView.builder(
                      padding: EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: cubiculosDisponibles.length,
                      itemBuilder: (context, index) {
                        final cubiculo = cubiculosDisponibles[index];
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
                                Icon(Icons.library_books, color: const Color.fromRGBO(158, 17, 15, 1), size: 80),
                                Text(
                                  cubiculo.nombreCubiculo,
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
                                SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ReservarCubiculo(
                                          idCubiculo: cubiculo.idCubiculo,
                                          emailUsuario: widget.emailUsuario,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Ingresar',
                                    style: TextStyle(color: Colors.white), // Texto en color blanco
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromRGBO(158, 17, 15, 1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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
                    builder: (context) => HomePage(email: widget.emailUsuario),
                  ),
                );
              } else if (index == 2) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PerfilPage(emailUsuario: widget.emailUsuario),
                  ),
                );
              } else {
                setState(() {
                  _selectedIndex = index;
                });
              }
            },
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
