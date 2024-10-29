import 'package:flutter/material.dart';

class HistorialScreen extends StatelessWidget {
  const HistorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historial"),
        centerTitle: false, // Alinea el título a la izquierda
        backgroundColor: Colors.transparent,
        titleTextStyle: const TextStyle(fontSize: 20, color: Colors.black),
        titleSpacing: 0, // Reduce el espacio entre la flecha y el título
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          "Página de Historial",
          style: TextStyle(fontSize: 24, color: Colors.black),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 245, 241, 241), // Fondo gris claro
    );
  }
}
