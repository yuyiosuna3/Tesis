import 'dart:async';
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
  Timer? _timer; // Temporizador para verificar el tiempo
  DateTime? _lastUpdateTime; // Última hora de actualización del valor
  bool _isDisconnected = false; // Indica si el dispositivo está desconectado

  @override
  void initState() {
    super.initState();
    _loadUserMacAndFetchValue();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancelar el temporizador cuando se destruya el widget
    super.dispose();
  }

  /// Cargar la dirección MAC del usuario desde Firestore y configurar la referencia de Firebase Database.
  Future<void> _loadUserMacAndFetchValue() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Obtén la dirección MAC desde Firestore.
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          final data = userDoc.data();
          if (data != null && data['macAddress'] != null) {
            final String macAddress = data['macAddress'];

            // Verifica si la MAC está registrada en Realtime Database.
            final deviceRef = FirebaseDatabase.instance.ref('/devices/$macAddress');
            final deviceSnapshot = await deviceRef.get();

            if (!deviceSnapshot.exists) {
              setState(() {
                _isMacValid = false;
                _errorMessage = "La dirección MAC no está registrada en la base de datos.";
              });
              return;
            }

            // Establecer la referencia al sensor específico y escuchar cambios.
            _databaseRef = deviceRef.child('sensorData/current');
            
            // Escucha cambios en tiempo real.
            _fetchCurrentValue();
          } else {
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
        final data = event.snapshot.value as Map?;
        if (data != null) {
          setState(() {
            // Actualizar el porcentaje basado en el valor
            double currentValue =
                double.tryParse(data['value'].toString()) ?? 0.0;
            percentage = currentValue / 100;

            // Obtener fecha y hora del último valor
            String? date = data['date'];
            String? time = data['time'];
            if (date != null && time != null) {
              _lastUpdateTime = _parseDateTime(date, time);
              _isDisconnected = false; // Actualizar el estado de conexión
            }
          });

          // Reiniciar el temporizador para monitorear la conexión
          _resetTimer();
        }
      });
    }
  }

  /// Convierte la fecha y hora de la base de datos a un objeto DateTime
  DateTime? _parseDateTime(String date, String time) {
    try {
      // Combina la fecha y hora en un solo objeto
      return DateTime.parse(date.split('/').reversed.join('-') + 'T' + time);
    } catch (e) {
      return null;
    }
  }

  /// Reinicia el temporizador para verificar si se ha perdido la conexión
  void _resetTimer() {
    _timer?.cancel();
    _timer = Timer(const Duration(minutes: 1), () {
      if (_lastUpdateTime != null) {
        final now = DateTime.now();
        final difference = now.difference(_lastUpdateTime!).inMinutes;

        if (difference >= 1) {
          setState(() {
            _isDisconnected = true; // Cambiar estado a desconectado
          });
          _showConnectionWarning();
        }
      }
    });
  }

  /// Muestra un mensaje de reconexión breve.

  /// Muestra un mensaje de advertencia si se perdió la conexión
  void _showConnectionWarning() {
    showDialog(
      context: context,
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 100,
                  color: Colors.yellowAccent,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Advertencia",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "No se ha recibido un nuevo valor en más de 1 minuto. Verifica la conexión.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop(); // Cierra el diálogo
                  },
                  icon: const Icon(Icons.refresh, color: Colors.black),
                  label: const Text(
                    "Aceptar",
                    style: TextStyle(color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Muestra un mensaje de reconexión breve

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
              const Icon(
                Icons.error_outline,
                size: 100,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 20),
              const Text(
                "¡Ups! Algo salió mal",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isMacValid =
                        true; // Restablece el estado para intentar de nuevo
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
          color: Colors.white,
        ),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 20), // Ajuste para que quede sobre la gráfica
              child: Text(
                _isDisconnected ? "Desconectado" : "Conectado",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:
                      _isDisconnected ? Colors.redAccent : Colors.greenAccent,
                ),
              ),
            ),
            Stack(alignment: Alignment.center, children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: percentage,
                  strokeWidth: 35,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
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
            ]),
            const SizedBox(height: 40),
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
            Transform.scale(
              scale: 3.2,
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
            Text(
              isSwitchOn ? 'Cerrado' : 'Abierto',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
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
      backgroundColor: Colors.black,
      drawer: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            color: Color.fromARGB(
              149,
              204,
              203,
              203,
            ),
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
                    (Route<dynamic> route) => false,
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
