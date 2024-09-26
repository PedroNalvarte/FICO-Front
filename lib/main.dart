import 'package:flutter/material.dart';
import 'login_page.dart'; // Importa la nueva pantalla de login

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(), // Cambia para que la primera pantalla sea el login
    );
  }
}