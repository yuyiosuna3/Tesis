import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? userEmail;
  String? userMacAddress;
  final List<TextEditingController> _phoneControllers = List.generate(5, (_) => TextEditingController());
  final List<String?> _phoneNumbers = List.filled(5, null);

  // Expresión regular para validar números de teléfono de Venezuela
  final RegExp venezuelaPhoneRegExp = RegExp(r'^(0412|0414|0416|0424|0426)\d{7}$');

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Cargar los datos del usuario desde Firebase Firestore
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email;
      });

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null) {
          setState(() {
            userMacAddress = (data['macAddress'] as String?)?.replaceAll("_", ":");
            for (int i = 0; i < 5; i++) {
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
    if (_phoneNumbers.contains(phone)) {
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
        _phoneNumbers[numberIndex] = phone;
      });
    }
  }

  // Función para eliminar un número de teléfono
  Future<void> _deletePhoneNumber(int numberIndex) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final updateData = {
        'phoneNumber${numberIndex + 1}': FieldValue.delete(),
      };

      await FirebaseFirestore.instance.collection('users').doc(userId).update(updateData);
      setState(() {
        _phoneNumbers[numberIndex] = null;
        _phoneControllers[numberIndex].clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Configuración",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              "Usuario: ${userEmail ?? 'Cargando...'}",
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 10),
            Text(
              "Dirección MAC: ${userMacAddress ?? 'Cargando...'}",
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 30),
            const Text(
              "Números de Teléfono",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
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
                            decoration: InputDecoration(
                              hintText: "Agregar número de teléfono",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.grey),
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
                            color: _phoneNumbers[index] == null ? Colors.grey : Colors.red,
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
