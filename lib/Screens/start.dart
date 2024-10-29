import 'package:flutter/material.dart';
import 'package:smart_gas/Screens/historial.dart';
import 'package:smart_gas/Screens/settings.dart';
import 'package:smart_gas/screens/safe_gas.dart';

class Start extends StatelessWidget {
  const Start({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white), // Icono del menú en blanco
      ),
      body: const Center(
        child: Text(
          'Bienvenido a la página de inicio',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
      backgroundColor: Colors.black, // Fondo negro de la página de inicio
      drawer: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 245, 241, 241), // Fondo para el menú lateral
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 245, 241, 241),
                ),
                child: Center(
                  child: Text(
                    'MENÚ',
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Baskerville',
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.settings, color: Colors.black, size: 30),
                title: const Text(
                  'Configuración',
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.timeline, color: Colors.black, size: 30),
                title: const Text(
                  'Historial',
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HistorialScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.black, size: 30),
                title: const Text(
                  'Cerrar sesión',
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const SafeGas()),
                    (Route<dynamic> route) => false, // Elimina toda la pila de navegación
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
