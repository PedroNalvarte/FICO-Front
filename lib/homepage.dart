import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: GNav(
            onTabChange: (index) {
              print(index);
            },
            backgroundColor: const Color(0xFF0B77BD),
            color: Colors.white,
            activeColor: const Color(0xFF0B77BD),
            tabBackgroundColor: Colors.white,
            gap: 12,
            padding: const EdgeInsets.all(22),
            tabs: const [
              GButton(
                icon: Icons.calendar_today,
                text: 'Eventos',
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.all(10),
              ),
              GButton(
                icon: Icons.tab,
                text: 'Reservas',
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.all(10),
              ),
              GButton(
                icon: Icons.computer,
                text: 'Equipos',
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.all(10),
              ),
              GButton(
                icon: Icons.person,
                text: 'Perfil',
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.all(10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
