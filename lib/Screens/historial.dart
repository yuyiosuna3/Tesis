import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart'; // Importa la librería para conectar con Firebase Realtime Database.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  _HistorialScreenState createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  DatabaseReference? _databaseRef; // Referencia dinámica a Firebase Realtime Database.
  String _currentValue = "Cargando..."; // Inicializa el valor actual con "Cargando...".

  @override
  void initState() {
    super.initState();
    _loadUserMacAndFetchValue(); // Carga la dirección MAC y establece la referencia.
  }

  /// Cargar la dirección MAC del usuario desde Firestore y configurar la referencia de Firebase Database.
  Future<void> _loadUserMacAndFetchValue() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
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
          setState(() {
            _currentValue = "MAC no encontrada";
          });
        }
      } else {
        setState(() {
          _currentValue = "Documento de usuario no encontrado";
        });
      }
    } else {
      setState(() {
        _currentValue = "Usuario no autenticado";
      });
    }
  }

  /// Escucha los cambios en tiempo real en la referencia configurada.
  void _fetchCurrentValue() {
    if (_databaseRef != null) {
      _databaseRef!.onValue.listen((event) {
        final value = event.snapshot.value;
        setState(() {
          _currentValue = value != null ? value.toString() : "Sin datos"; // Actualiza el valor mostrado.
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historial"), // Título que aparece en la barra superior.
        centerTitle: false, // Define que el título no estará centrado.
        backgroundColor: Colors.transparent, // Hace que el fondo de la barra sea transparente.
        titleTextStyle: const TextStyle(fontSize: 20, color: Colors.black), // Estilo del título.
        titleSpacing: 0, // Espaciado entre la flecha de retroceso y el título.
        elevation: 0, // Sin sombra en la barra superior.
      ),
      body: Center(
        // Muestra el valor actual obtenido de Firebase en el centro de la pantalla.
        child: Text(
          "Valor actual: $_currentValue", // El texto incluye el valor obtenido.
          style: const TextStyle(fontSize: 24, color: Colors.black), // Estilo del texto.
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 245, 241, 241), // Color de fondo gris claro.
    );
  }
}
