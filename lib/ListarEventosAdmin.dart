import 'package:fico_app/VerSolicitudesEventos.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'RegistrarEvento.dart'; // Asegúrate de que este archivo exista
import 'PerfilAdmin.dart';
import 'EliminarEvento.dart';
import 'VisualizarCubiculosAdmin.dart';
import 'VerSolicitudesEventos.dart';
class Evento {
  final int idEvento;
  final String nombreEvento;
  final String lugar;
  final int aforo;
  final double costo;
  final List<String> equipoNecesario;
  final String estado;
  final String date;
  final String fechaCreacion;
  final int entradasVendidas;
  final String fecha;
  final String hora;
  final String fechaFormateada;
  final String? imagen;

  Evento({
    required this.idEvento,
    required this.nombreEvento,
    required this.lugar,
    required this.aforo,
    required this.costo,
    required this.equipoNecesario,
    required this.estado,
    required this.date,
    required this.fechaCreacion,
    required this.entradasVendidas,
    required this.fecha,
    required this.hora,
    required this.fechaFormateada,
    required this.imagen,
  });

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      idEvento: json['id_evento'],
      nombreEvento: json['nombre_evento'],
      lugar: json['lugar'],
      aforo: json['aforo'],
      costo: double.parse(json['costo']),
      equipoNecesario: List<String>.from(json['equipo_necesario']),
      estado: json['estado'],
      date: json['date'],
      fechaCreacion: json['fecha_creacion'],
      entradasVendidas: json['entradas_vendidas'],
      fecha: json['fecha'],
      hora: json['hora'],
      fechaFormateada: json['fecha_formateada'],
      imagen: json['imagen'] as String?,
    );
  }
}

class ListarEventAdmin extends StatefulWidget {
  final String email;

  const ListarEventAdmin({Key? key, required this.email}) : super(key: key);

  @override
  State<ListarEventAdmin> createState() => _ListarEventAdminState();
}

class _ListarEventAdminState extends State<ListarEventAdmin> {
  late Future<List<Evento>> eventosActivos;

  @override
  void initState() {
    super.initState();
    eventosActivos = fetchEventosActivos();
  }

  Future<List<Evento>> fetchEventosActivos() async {
    const String apiUrl = 'https://fico-back.onrender.com/events/getActive';
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((event) => Evento.fromJson(event)).toList();
    } else {
      throw Exception('Error al obtener los eventos activos: ${response.statusCode}');
    }
  }

  Widget _buildEventosList() {
    return FutureBuilder<List<Evento>>(
      future: eventosActivos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay eventos activos actualmente.'));
        } else {
          final eventos = snapshot.data!;
          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: eventos.length,
            itemBuilder: (context, index) {
              final evento = eventos[index];
              return Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (evento.imagen != null)
                        Image.network(evento.imagen!, height: 150, width: double.infinity, fit: BoxFit.cover)
                      else
                        Container(height: 150, color: Colors.grey, alignment: Alignment.center, child: Icon(Icons.image_not_supported, size: 50)),
                      Text(evento.nombreEvento, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Lugar: ${evento.lugar}'),
                      Text('Fecha: ${evento.fechaFormateada}'),
                      Text('Hora: ${evento.hora}'),
                      Text('Aforo: ${evento.aforo}'),
                      Text('Costo: S/.${evento.costo}'),
                      Text('Entradas Vendidas: ${evento.entradasVendidas}'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return EliminarEventoDialog(eventoId: eventos[index].idEvento);
                                },
                              ).then((_) {
                                // Actualizar la lista de eventos si es necesario
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
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
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(158, 17, 15, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: () {
                      setState(() {
                        eventosActivos = fetchEventosActivos();
                      });
                    },
                    child: const Text(
                      'Eventos Publicados',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _buildEventosList(),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 20, bottom: 120),
        child: Align(
          alignment: Alignment.bottomRight,
          child: FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return RegistrarEvento(); // Asegúrate de que esto esté bien definido
                },
              );
            },
            child: Icon(Icons.add, color: Colors.white),
            backgroundColor: Color.fromRGBO(158, 17, 15, 1),
            shape: CircleBorder(),
          ),
        ),
      ),
      
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: GNav(
            onTabChange: (index) {
              if (index == 3) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PerfilAdminPage(emailUsuario: widget.email),
                  ),
                );
              } else if (index == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VisualizarCubiculosAdmin(emailUsuario: widget.email),
                  ),
                );
              
              } else if (index == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VerSolicitudesEventos(),
                  ),
                );
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
              GButton(icon: Icons.meeting_room, text: 'Cubículos'),
              GButton(icon: Icons.computer, text: 'Solicitudes'),
              GButton(icon: Icons.person, text: 'Perfil'),
            ],
          ),
        ),
      ),
    );
  }
}
