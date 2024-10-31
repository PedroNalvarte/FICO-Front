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
