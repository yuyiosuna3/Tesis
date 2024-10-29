import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuración"),
        centerTitle: false, // Alinea el título a la izquierda
        backgroundColor: Colors.transparent,
        titleTextStyle: const TextStyle(fontSize: 20, color: Colors.black),
        titleSpacing: 0, // Reduce el espacio entre la flecha y el título
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          "Página de Configuración",
          style: TextStyle(fontSize: 24, color: Colors.black),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 245, 241, 241), // Fondo gris claro
    );
  }
}
