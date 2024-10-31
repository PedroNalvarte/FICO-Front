import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SolicitudEvento {
  final int idEvento;
  final String nombreEvento;
  final String lugar;
  final int aforo;
  final double costo;
  final String equipoNecesario;
  final String estado;
  final String fecha;

  SolicitudEvento({
    required this.idEvento,
    required this.nombreEvento,
    required this.lugar,
    required this.aforo,
    required this.costo,
    required this.equipoNecesario,
    required this.estado,
    required this.fecha,
  });

  factory SolicitudEvento.fromJson(Map<String, dynamic> json) {
    return SolicitudEvento(
      idEvento: json['id_evento'],
      nombreEvento: json['nombre_evento'],
      lugar: json['lugar'],
      aforo: json['aforo'],
      costo: double.tryParse(json['costo'].toString()) ?? 0.0,
      equipoNecesario: (json['equipo_necesario'] is List) 
          ? (json['equipo_necesario'] as List).join(', ') 
          : '',
      estado: json['estado'],
      fecha: json['date'],
    );
  }
}

class VerSolicitudesEventos extends StatefulWidget {
  @override
  _VerSolicitudesEventosState createState() => _VerSolicitudesEventosState();
}

class _VerSolicitudesEventosState extends State<VerSolicitudesEventos> {
  bool isLoading = true;
  List<SolicitudEvento> solicitudes = [];
  String? mensajeError;

  @override
  void initState() {
    super.initState();
    _obtenerSolicitudes();
  }

  Future<void> _obtenerSolicitudes() async {
    const String apiUrl = 'https://fico-back.onrender.com/events/getRequests';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          solicitudes = data.map((json) => SolicitudEvento.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          mensajeError = 'Error al obtener las solicitudes: ${response.statusCode}';
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

  Future<void> _aceptarEvento(int id) async {
  const String apiUrl = 'https://fico-back.onrender.com/events/acceptEvent';

  try {
    final response = await http.put(Uri.parse('$apiUrl/$id')); // Asegúrate de que $id sea correcto

    if (response.statusCode == 200 || response.statusCode == 201) {
      setState(() {
        final responseBody = json.decode(response.body);
        mensajeError = responseBody.containsKey('Success') 
            ? responseBody['Success'] 
            : 'Evento aceptado exitosamente';
      });
      _obtenerSolicitudes(); // Actualizar la lista después de aceptar
    } else {
      setState(() {
        mensajeError = 'Error al aceptar el evento: ${response.statusCode}';
      });
    }
  } catch (e) {
    setState(() {
      mensajeError = 'Error de conexión: $e';
    });
  }
}


  Future<void> _rechazarEvento(int id) async {
    const String apiUrl = 'https://fico-back.onrender.com/events/denyEvent';
    
    try {
      final response = await http.put(Uri.parse('$apiUrl/$id'));
      if (response.statusCode == 200 || response.statusCode == 201) {
        _obtenerSolicitudes(); // Actualizar la lista después de rechazar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Evento rechazado correctamente.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al rechazar el evento: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ver Solicitudes de Eventos'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : mensajeError != null
              ? Center(child: Text(mensajeError!))
              : solicitudes.isEmpty
                  ? Center(child: Text('No hay solicitudes en este momento'))
                  : ListView.builder(
                      itemCount: solicitudes.length,
                      itemBuilder: (context, index) {
                        final solicitud = solicitudes[index];
                        return Card(
                          margin: EdgeInsets.all(10),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Evento: ${solicitud.nombreEvento}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                Text('Lugar: ${solicitud.lugar}'),
                                Text('Aforo: ${solicitud.aforo} personas'),
                                Text('Costo: S/.${solicitud.costo.toStringAsFixed(2)}'),
                                Text('Equipo Necesario: ${solicitud.equipoNecesario}'),
                                Text('Estado: ${solicitud.estado}'),
                                Text('Fecha: ${solicitud.fecha}'),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () => _aceptarEvento(solicitud.idEvento),
                                      child: Text('Aceptar'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () => _rechazarEvento(solicitud.idEvento),
                                      child: Text('Rechazar'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
