import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CompraEntradaPage extends StatefulWidget {
  final int idEvento;
  final String nombreEvento;

  CompraEntradaPage({Key? key, required this.idEvento, required this.nombreEvento}) : super(key: key);

  @override
  _CompraEntradaPageState createState() => _CompraEntradaPageState();
}

class _CompraEntradaPageState extends State<CompraEntradaPage> {
  final TextEditingController _cantidadEntradasController = TextEditingController();
  final TextEditingController _metodoPagoController = TextEditingController();
  final TextEditingController _referenciaPagoController = TextEditingController();

  Future<void> _comprarEntrada() async {
    final url = Uri.parse('https://fico-back.onrender.com/payment/eventPurchase');
    final response = await http.post(url, headers: {
      "Content-Type": "application/json",
    }, body: json.encode({
      "idEvento": widget.idEvento,
      "idUsuario": 6, // Ajusta este valor al ID del usuario en sesión
      "cantidadEntradas": int.parse(_cantidadEntradasController.text),
      "metodoPago": _metodoPagoController.text,
      "referenciaPago": _referenciaPagoController.text,
    }));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result["mensaje"] == "Compra de entradas registrada exitosamente") {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result["mensaje"])));
        Navigator.pop(context); // Cierra la pantalla después de la compra
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${result["mensaje"]}")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error al procesar la compra")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comprar Entrada para ${widget.nombreEvento}'),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _cantidadEntradasController,
              decoration: InputDecoration(labelText: 'Cantidad de Entradas'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _metodoPagoController,
              decoration: InputDecoration(labelText: 'Método de Pago (e.g., Yape)'),
            ),
            TextField(
              controller: _referenciaPagoController,
              decoration: InputDecoration(labelText: 'Referencia de Pago'),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _comprarEntrada,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: Text('Confirmar Compra'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
