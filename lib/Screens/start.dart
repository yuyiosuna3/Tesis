import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  double percentage = 0; // Valor inicial por defecto
  DatabaseReference? _databaseRef; // Referencia al Realtime Database
  bool _isMacValid = true; // Indica si la dirección MAC es válida
  String _errorMessage = ""; // Mensaje de error para el usuario

  @override
  void initState() {
    super.initState();
    _loadUserMacAndFetchValue();
  }

  /// Cargar la dirección MAC del usuario desde Firestore y configurar la referencia de Firebase Database.
  Future<void> _loadUserMacAndFetchValue() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Obtén la dirección MAC desde Firestore.
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final data = userDoc.data();
          if (data != null && data['macAddress'] != null) {
            final String macAddress = data['macAddress'];

            // Establecer la referencia dinámica en Firebase Database con la dirección MAC.
            _databaseRef = FirebaseDatabase.instance
                .ref('/devices/$macAddress/sensorData/current/value');

            // Escucha cambios en tiempo real.
            _fetchCurrentValue();
          } else {
            // Si no existe la dirección MAC, mostrar un mensaje.
            setState(() {
              _isMacValid = false;
              _errorMessage = "No se encontró la dirección MAC registrada.";
            });
          }
        } else {
          setState(() {
            _isMacValid = false;
            _errorMessage = "No se encontró el usuario en la base de datos.";
          });
        }
      } catch (e) {
        setState(() {
          _isMacValid = false;
          _errorMessage = "Error al cargar los datos del usuario: $e";
        });
      }
    } else {
      setState(() {
        _isMacValid = false;
        _errorMessage = "Usuario no autenticado.";
      });
    }
  }

  /// Escucha los cambios en tiempo real en la referencia configurada.
  void _fetchCurrentValue() {
    if (_databaseRef != null) {
      _databaseRef!.onValue.listen((event) {
        final value = event.snapshot.value;
        setState(() {
          if (value != null) {
            // Convierte el valor obtenido a un porcentaje (suponiendo que el rango es de 0 a 100)
            percentage = (double.tryParse(value.toString()) ?? 0) / 100;
          } else {
            _isMacValid = false;
            _errorMessage = "No se encontraron datos en el dispositivo.";
          }
        });
      });
    }
  }

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
    if (!_isMacValid) {
      // Muestra un mensaje de error estilizado si no se encuentra la MAC o los datos.
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
          title: const Text(
            "Error",
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícono de advertencia
              const Icon(
                Icons.error_outline,
                size: 100,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 20),

              // Mensaje principal
              Text(
                "¡Ups! Algo salió mal",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 15),

              // Descripción del error
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 30),

              // Botón para intentar de nuevo
              ElevatedButton.icon(
                onPressed: () {
                  // Recarga los datos al pulsar el botón
                  setState(() {
                    _isMacValid = true; // Restablece el estado para intentar de nuevo
                    _loadUserMacAndFetchValue();
                  });
                },
                icon: const Icon(Icons.refresh, color: Colors.black),
                label: const Text(
                  "Intentar de nuevo",
                  style: TextStyle(color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

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
                      value: percentage, // Porcentaje actualizado
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
