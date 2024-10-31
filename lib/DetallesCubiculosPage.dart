import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReservaDetalle {
  final int idReserva;
  final int idUsuario;
  final String nombre;
  final String apellido;
  final String fechaReserva;
  final String horaReserva;
  final int cantidadHoras;

  ReservaDetalle({
    required this.idReserva,
    required this.idUsuario,
    required this.nombre,
    required this.apellido,
    required this.fechaReserva,
    required this.horaReserva,
    required this.cantidadHoras,
  });

  factory ReservaDetalle.fromJson(Map<String, dynamic> json) {
    return ReservaDetalle(
      idReserva: json['id_reserva'],
      idUsuario: json['id_usuario'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      fechaReserva: json['fecha_reserva'],
      horaReserva: json['hora_reserva'],
      cantidadHoras: json['cantidad_horas'],
    );
  }
}

class DetallesCubiculosPage extends StatefulWidget {
  final int idCubiculo;

  DetallesCubiculosPage({required this.idCubiculo});

  @override
  _DetallesCubiculosPageState createState() => _DetallesCubiculosPageState();
}

class _DetallesCubiculosPageState extends State<DetallesCubiculosPage> {
  late Future<List<ReservaDetalle>> detallesReserva;

  @override
  void initState() {
    super.initState();
    detallesReserva = obtenerDetallesReserva(widget.idCubiculo);
  }

  Future<List<ReservaDetalle>> obtenerDetallesReserva(int idCubiculo) async {
    final response = await http.get(Uri.parse(
        'https://fico-back.onrender.com/cubicles/getReservedCubicleDetails/$idCubiculo'));

    if (response.statusCode == 200 || response.statusCode == 201) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => ReservaDetalle.fromJson(item)).toList();
    } else {
      throw Exception('Error al obtener detalles de la reserva');
    }
  }

  String formatDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    return "${parsedDate.day}-${parsedDate.month}-${parsedDate.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalles de Reserva del Cubículo',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromRGBO(158, 17, 15, 1),
        iconTheme: IconThemeData(color: Colors.white), // Ícono de regreso en blanco
      ),
      body: FutureBuilder<List<ReservaDetalle>>(
        future: detallesReserva,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay reservas para este cubículo.'));
          } else {
            final detalles = snapshot.data!;
            return GridView.builder(
              padding: EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Número de columnas
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 4 / 3, // Relación de aspecto ajustada
              ),
              itemCount: detalles.length,
              itemBuilder: (context, index) {
                final detalle = detalles[index];
                return Card(
                  elevation: 3,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${detalle.nombre} ${detalle.apellido}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.date_range, color: Colors.black, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Fecha: ${formatDate(detalle.fechaReserva)}',
                              style: TextStyle(fontSize: 12, color: Colors.black54),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.access_time, color: Colors.black, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Hora: ${detalle.horaReserva}',
                              style: TextStyle(fontSize: 12, color: Colors.black54),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.timer, color: Colors.black, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Horas reservadas: ${detalle.cantidadHoras}',
                              style: TextStyle(fontSize: 12, color: Colors.black54),
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
      ),
    );
  }
}
