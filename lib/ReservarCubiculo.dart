import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'VisualizarCubiculosDisponibles.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'HomePage.dart';
import 'Perfil.dart';

class ReservarCubiculo extends StatefulWidget {
  final int idCubiculo;
  final String emailUsuario;

  ReservarCubiculo({required this.idCubiculo, required this.emailUsuario});

  @override
  _ReservarCubiculoState createState() => _ReservarCubiculoState();
}

class _ReservarCubiculoState extends State<ReservarCubiculo> {
  final _formKey = GlobalKey<FormState>();
  List<String> horasReservadas = [];
  String? horaSeleccionada;
  int cantidadHoras = 1;
  String _mensaje = '';

  @override
  void initState() {
    super.initState();
    _fetchHorasReservadas();
  }

  Future<void> _fetchHorasReservadas() async {
    final url = Uri.parse('https://fico-back.onrender.com/cubicles/reservedHours/${widget.idCubiculo}');
    try {
      final response = await http.post(url);
      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          horasReservadas = List<String>.from(data);
        });
      } else {
        setState(() {
          _mensaje = 'Error al obtener horas reservadas.';
        });
      }
    } catch (e) {
      setState(() {
        _mensaje = 'Error de conexión: $e';
      });
    }
  }

  List<String> _calcularHorasEnRango() {
    if (horaSeleccionada == null) return [];
    int horaInicial = int.parse(horaSeleccionada!.split(':')[0]);
    List<String> horasEnRango = [];
    for (int i = 0; i < cantidadHoras; i++) {
      String hora = '${horaInicial + i}:00:00';
      horasEnRango.add(hora);
    }
    return horasEnRango;
  }

  Future<void> _reservarCubiculo() async {
    if (horaSeleccionada == null) {
      setState(() {
        _mensaje = 'Por favor selecciona una hora de reserva.';
      });
      return;
    }

    // Verifica si alguna de las horas en el rango está ocupada
    final horasEnRango = _calcularHorasEnRango();
    if (horasEnRango.any((hora) => horasReservadas.contains(hora))) {
      // Si hay horas ocupadas, muestra una alerta
      _mostrarAlertaHorasOcupadas();
      return;
    }

    final url = Uri.parse('https://fico-back.onrender.com/cubicles/reserveCubicle');
    final body = jsonEncode({
      'email': widget.emailUsuario,
      'id_cubiculo': widget.idCubiculo,
      'hora_reserva': horaSeleccionada,
      'cantidad_horas': cantidadHoras,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _mensaje = data['message'] ?? 'Reserva creada exitosamente';
          horasReservadas.addAll(horasEnRango); // Actualiza las horas reservadas
        });
        _mostrarDialogExito(); // Llamar al modal de éxito
      } else {
        setState(() {
          _mensaje = data['error'] ?? 'Error al reservar el cubículo';
        });
      }
    } catch (e) {
      setState(() {
        _mensaje = 'Error de conexión: $e';
      });
    }
  }

  void _mostrarAlertaHorasOcupadas() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error de Reserva"),
          content: Text("No puedes reservar las horas seleccionadas, ya que están ocupadas."),
          actions: [
            TextButton(
              child: Text("Cerrar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogExito() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Reserva Exitosa"),
          content: Text("Tu reserva ha sido realizada con éxito."),
          actions: [
            TextButton(
              child: Text("Cerrar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
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
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VisualizarCubiculosDisponibles(emailUsuario: widget.emailUsuario),
                        ),
                      );
                    },
                  ),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 20),
              Text(
                'Selecciona la hora de inicio de la reserva:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 12, // Cambiado para incluir desde las 9 AM hasta las 9 PM
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final hora = '${9 + index}:00:00'; // Cambiado para comenzar a las 9 AM
                  final reservada = horasReservadas.contains(hora);
                  final enRangoSeleccionado = _calcularHorasEnRango().contains(hora);

                  return GestureDetector(
                    onTap: reservada
                        ? null
                        : () {
                            setState(() {
                              horaSeleccionada = hora;
                            });
                          },
                    child: Container(
                      decoration: BoxDecoration(
                        color: enRangoSeleccionado
                            ? Colors.green
                            : (reservada ? Colors.grey : Color.fromRGBO(158, 17, 15, 1)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            enRangoSeleccionado
                                ? Icons.check_circle 
                                : (reservada ? Icons.lock : Icons.access_time),
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 4),
                          Text(
                            hora,
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              Text(
                'Cantidad de Horas:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              DropdownButton<int>(
                value: cantidadHoras,
                items: [1, 2].map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value hora(s)', style: TextStyle(fontSize: 16)),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    cantidadHoras = newValue!;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _reservarCubiculo,
                child: Text('Reservar', style: TextStyle(color: Colors.white, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(158, 17, 15, 1),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (_mensaje.isNotEmpty)
                Text(
                  _mensaje,
                  style: TextStyle(
                    color: _mensaje.contains('exitosamente') ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: GNav(
            selectedIndex: 1,
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
