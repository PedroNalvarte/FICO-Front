import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class RegistrarEvento extends StatefulWidget {
  const RegistrarEvento({super.key});

  @override
  State<RegistrarEvento> createState() => _RegistrarEventoState();
}

class _RegistrarEventoState extends State<RegistrarEvento> {
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
      body: Center(
        // Aquí puedes agregar el contenido específico para registrar eventos
        child: const Text("Contenido para registrar eventos"),
      ),


      //NavigationBar
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: GNav(
            onTabChange: (index) {
              print(index);
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
              GButton(icon: Icons.computer, text: 'Equipos'),
              GButton(icon: Icons.person, text: 'Perfil'),
            ],
          ),
        ),
      ),
    );
  }
}
