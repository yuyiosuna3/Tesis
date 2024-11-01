import 'package:flutter/material.dart';
import 'package:smart_gas/screens/historial.dart';
import 'package:smart_gas/screens/settings.dart';
import 'package:smart_gas/screens/safe_gas.dart';

class Start extends StatefulWidget {
  const Start({Key? key}) : super(key: key);

  @override
  _StartState createState() => _StartState();
}

class _StartState extends State<Start> {
  bool isSwitchOn = false; // Estado inicial del switch
  double  percentage = 0.80;

  Color getColor(double percentage) {
    if (percentage <= 0.2) {
      return Colors.greenAccent;
    } else if (percentage <= 0.4) {
      return Colors.yellow;
    } else if (percentage <= 0.6) {
      return Colors.deepOrangeAccent;
    } else {
      return Colors.redAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color progressColor = getColor(percentage);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(
            color: Colors.white), // Icono del menú en blanco
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gráfica circular en la parte superior, simulando el logo
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                      value: percentage, // Porcentaje estático (10%)
                      strokeWidth: 35,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor)),
                ),
                Text(
                  '${(percentage * 100).toInt()}%',
                  style: const TextStyle(
                    fontFamily: 'DSDigital',
                    fontSize: 65,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Texto para el porcentaje de gas
            const Text(
              textAlign: TextAlign.center,
              'Nivel de Gas\nen el Ambiente',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 60),

            // Switch grande en el centro
            Transform.scale(
              scale: 3.2, // Escala el tamaño del switch
              child: Switch(
                value: isSwitchOn,
                onChanged: (value) {
                  setState(() {
                    isSwitchOn = value;
                  });
                },
                activeColor: Colors.redAccent,
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 45),

            // Texto de estado (Conectado/Desconectado)
            Text(
              isSwitchOn ? 'Cerrado' : 'Abierto',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            // Descripción adicional del estado
            Text(
              isSwitchOn
                  ? 'La válvula de gas está cerrada.'
                  : 'La válvula de gas está abierta.',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.black, // Fondo negro de la página de inicio
      drawer: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            color: Color.fromARGB(
                149, 204, 203, 203), // Fondo para el menú lateral
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Color.fromARGB(149, 204, 203, 203),
                ),
                child: Center(
                  child: Text(
                    'MENÚ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading:
                    const Icon(Icons.settings, color: Colors.black, size: 30),
                title: const Text(
                  'Configuración',
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsScreen()),
                  );
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.timeline, color: Colors.black, size: 30),
                title: const Text(
                  'Historial',
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HistorialScreen()),
                  );
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.logout, color: Colors.black, size: 30),
                title: const Text(
                  'Cerrar sesión',
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const SafeGas()),
                    (Route<dynamic> route) =>
                        false, // Elimina toda la pila de navegación
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
