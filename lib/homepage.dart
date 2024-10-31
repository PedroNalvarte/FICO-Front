import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Perfil.dart';
import 'VisualizarCubiculosDisponibles.dart';
import 'EventDetailsPage.dart';
import 'Evento.dart'; // Asegúrate de que este import es correcto

class HomePage extends StatefulWidget {
  final String email;

  const HomePage({Key? key, required this.email}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Evento>> eventosActivos;
  int _selectedIndex = 0;

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
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EventDetailsPage(evento: evento)),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(width: 10, color: Color.fromRGBO(158, 17, 15, 1)),
                    ),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      evento.imagen != null
                          ? Image.network(evento.imagen!, height: 150, width: double.infinity, fit: BoxFit.cover)
                          : Container(height: 150, color: Colors.grey, alignment: Alignment.center, child: Icon(Icons.image_not_supported, size: 50)),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(evento.nombreEvento, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('Lugar: ${evento.lugar}'),
                            Text('Fecha: ${evento.fechaFormateada}'),
                            Text('Hora: ${evento.hora}'),
                            Text('Aforo: ${evento.aforo}'),
                            Text('Costo de la entrada: S/.${evento.costo.toStringAsFixed(2)}'),
                            Text('Entradas vendidas: ${evento.entradasVendidas}'),
                          ],
                        ),
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

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) { // Navegar a Reservas
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VisualizarCubiculosDisponibles(emailUsuario: widget.email),
        ),
      );
    } else if (index == 2) { // Navegar a Perfil
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PerfilPage(emailUsuario: widget.email),
        ),
      );
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
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),

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
      body: _selectedIndex == 0 ? _buildEventosList() : const Center(child: Text("Vista no disponible")),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),

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
            onTabChange: _onTabSelected,
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
