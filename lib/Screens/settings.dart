import 'package:flutter/material.dart';                          // UI en Flutter
import 'package:cloud_firestore/cloud_firestore.dart';           // Acceso a Firebase Firestore
import 'package:firebase_auth/firebase_auth.dart';               // Autenticación de usuarios con Firebase

class SettingsScreen extends StatefulWidget {                    
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? userEmail;                                             // Email del usuario autenticado
  String? userMacAddress;                                        // Dirección MAC del dispositivo
  final List<TextEditingController> _phoneControllers =          // Lista de controladores para los TextField
      List.generate(5, (_) => TextEditingController());
  final List<String?> _phoneNumbers = List.filled(5, null);      // Lista para almacenar los números guardados

  // Expresión regular para validar números de teléfono de Venezuela
  final RegExp venezuelaPhoneRegExp = RegExp(r'^(0412|0414|0416|0424|0426)\d{7}$');

  @override
  void initState() {
    super.initState();
    _loadUserData();                                            // Al iniciar, carga los datos del usuario
  }

  // Cargar los datos del usuario desde Firebase Firestore
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email;                                 // Guardar el correo del usuario
      });

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null) {
          setState(() {
            userMacAddress = (data['macAddress'] as String?)?.replaceAll("_", ":"); // Reemplaza _ por : para formato original
            for (int i = 0; i < 5; i++) {                                           // Llena los campos de teléfonos existentes
              _phoneNumbers[i] = data['phoneNumber${i + 1}'];
              _phoneControllers[i].text = _phoneNumbers[i] ?? '';
            }
          });
        }
      }
    }
  }

  // Función para guardar un número de teléfono
  Future<void> _savePhoneNumber(int numberIndex) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final phone = _phoneControllers[numberIndex].text.trim();

    // Validar el número de teléfono
    if (!venezuelaPhoneRegExp.hasMatch(phone)) {
      // Si no cumple con el formato, mostrar un mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un número de teléfono válido, por ejemplo: 0412XXXXXXX')),
      );
      return;
    }

    // Verificar si el número ya existe en los campos del usuario
    if (_phoneNumbers.contains(phone)) { // Evitar duplicados
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este número de teléfono ya está registrado')),
      );
      return;
    }

    // Si pasa las validaciones, guardar el número
    if (userId != null && phone.isNotEmpty) {
      final updateData = {
        'phoneNumber${numberIndex + 1}': phone,
      };

      await FirebaseFirestore.instance.collection('users').doc(userId).update(updateData);
      setState(() {
        _phoneNumbers[numberIndex] = phone; // Actualiza en la UI local
      });
    }
  }

  // Función para eliminar un número de teléfono
  Future<void> _deletePhoneNumber(int numberIndex) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final updateData = {
        'phoneNumber${numberIndex + 1}': FieldValue.delete(), // Borra el campo del documento
      };

      await FirebaseFirestore.instance.collection('users').doc(userId).update(updateData);
      setState(() {
        _phoneNumbers[numberIndex] = null;                      // Limpia el dato local
        _phoneControllers[numberIndex].clear();                 // Limpia el input
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Configuración",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey[900],
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              "Usuario: ${userEmail ?? 'Cargando...'}", 
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              "Dirección MAC: ${userMacAddress ?? 'Cargando...'}",
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 30),
            const Text(
              "Números de Teléfono",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),

            // Genera dinámicamente campos para hasta 5 números de teléfono
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _phoneControllers[index],
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Agregar número de teléfono",
                               hintStyle: TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            keyboardType: TextInputType.phone,
                            onFieldSubmitted: (value) {
                              if (value.isNotEmpty) {
                                _savePhoneNumber(index);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            _phoneNumbers[index] == null ? Icons.add : Icons.delete,
                            color: _phoneNumbers[index] == null ? Colors.white : Colors.red,
                          ),
                          onPressed: () {
                            if (_phoneNumbers[index] == null) {
                              _savePhoneNumber(index);
                            } else {
                              _deletePhoneNumber(index);
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}