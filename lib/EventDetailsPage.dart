import 'package:flutter/material.dart';
import 'Evento.dart';  // Asegúrate de que esta es la ruta correcta
import 'CompraEntradaPage.dart';  // Asegúrate de que esta es la ruta correcta

class EventDetailsPage extends StatelessWidget {
  final Evento evento;

  EventDetailsPage({Key? key, required this.evento}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(evento.nombreEvento),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            evento.imagen != null
                ? Image.network(evento.imagen!, height: 250, fit: BoxFit.cover)
                : Placeholder(fallbackHeight: 200, fallbackWidth: double.infinity),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Lugar: ${evento.lugar}',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Fecha: ${evento.fechaFormateada}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Hora: ${evento.hora}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Aforo: ${evento.aforo}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Costo: S/.${evento.costo.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Entradas Vendidas: ${evento.entradasVendidas}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Equipamiento Necesario: ${evento.equipoNecesario.join(', ')}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Navega a la pantalla de compra de entrada
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CompraEntradaPage(
                              idEvento: evento.idEvento,
                              nombreEvento: evento.nombreEvento,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent, // Color de fondo
                        foregroundColor: Colors.white, // Color del texto
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        textStyle: TextStyle(fontSize: 18),
                      ),
                      child: Text('Comprar Entrada'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}