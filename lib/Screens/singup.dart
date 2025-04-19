import 'package:flutter/material.dart';                     // Interfaz de usuario
import 'package:smart_gas/screens/start.dart';              // Pantalla a la que se navega después del registro
import 'package:firebase_auth/firebase_auth.dart';          // Autenticación con Firebase
import 'package:cloud_firestore/cloud_firestore.dart';      // Base de datos Firestore
import 'package:smart_gas/widgets/custom_scaffold.dart';    // Scaffold personalizado para la app
import 'package:mobile_scanner/mobile_scanner.dart';        // Escáner de código QR

// Widget principal de la pantalla de registro
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

// Estado asociado a la pantalla
class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para capturar los datos ingresados
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _macAddressController = TextEditingController();

   // Función para escanear QR y obtener la dirección MAC
  void _scanQRCode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Escanear Código QR"),
        content: SizedBox(
          height: 300,
          width: 300,
          child: MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String scannedMac = barcodes.first.rawValue ?? "";
                setState(() {
                  _macAddressController.text = scannedMac;          // Muestra la MAC escaneada en el campo de texto
                });
                Navigator.pop(context);
              }
            },
          ),
        ),
      ),
    );
  }


  // Función para registrar y almacenar datos en Firebase
  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Procesar dirección MAC: convertir a mayúsculas y usar guiones bajos
        String processedMacAddress = _macAddressController.text.trim().toUpperCase().replaceAll(":", "_").replaceAll("-", "_");

         // Verificar si la dirección MAC ya está registrada
        final existingUsers = await FirebaseFirestore.instance
            .collection('users')
            .where('macAddress', isEqualTo: processedMacAddress)
            .get();

        if (existingUsers.docs.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Esta dirección MAC ya está registrada.'),
            ),
          );
          return; // Se detiene el proceso de registro
        }


        // Registra al usuario en Firebase Authentication
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Guarda información adicional en Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user?.uid)
            .set({
          'email': _emailController.text.trim(),
          'macAddress': processedMacAddress,
          'createdAt': DateTime.now(),
        });

        // Muestra un mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro exitoso')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Start()),
        );
      } catch (e) {
        // Manejo de errores específicos
        String errorMessage = 'Ocurrió un error. Inténtalo nuevamente.';

        if (e is FirebaseAuthException) {
          if (e.code == 'email-already-in-use') {
            errorMessage = 'El correo ya está en uso.';
          } else if (e.code == 'invalid-email') {
            errorMessage = 'El correo electrónico no es válido.';
          } else if (e.code == 'weak-password') {
            errorMessage = 'La contraseña es demasiado débil.';
          }
        }

        // Muestra un mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: SingleChildScrollView(           // Permite desplazar si la pantalla es pequeña
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height, // Asegura altura mínima
          ),
          child: IntrinsicHeight(
            child: Column(
              children: [
                const Expanded(
                  flex: 1,
                  child: SizedBox(height: 10),
                ),
                Expanded(
                  flex: 7,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40.0),
                        topRight: Radius.circular(40.0),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: _formKey,                      
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'SAFE GAS',
                              style: TextStyle(
                                fontFamily: 'OneDay',
                                fontSize: 70.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Campo de Dirección MAC
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                children: [
                                  // Campo de entrada de MAC
                                  Expanded(
                                    child: TextFormField(
                                      controller: _macAddressController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Por favor ingrese la MAC del dispositivo';
                                        }

                                        // Validar formato de dirección MAC
                                        final macRegExp =
                                            RegExp(r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$');
                                        if (!macRegExp.hasMatch(value.trim())) {
                                          return 'Formato de MAC incorrecto';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        label: const Text('Dirección MAC'),
                                        hintText: 'Ingrese la MAC del dispositivo',
                                        hintStyle: const TextStyle(color: Colors.black26),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(color: Colors.grey),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        labelStyle: const TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10), // Espaciado entre el campo y el botón

                                  // Botón de escáner QR
                                  IconButton(
                                    icon: const Icon(Icons.qr_code_scanner, size: 30, color: Colors.black),
                                    onPressed: _scanQRCode,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Campo de Correo Electrónico
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: TextFormField(
                                controller: _emailController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor ingrese el correo electrónico';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  label: const Text('Correo Electrónico'),
                                  hintText: 'Ingrese el correo',
                                  hintStyle:
                                      const TextStyle(color: Colors.black26),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  labelStyle:
                                      const TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Campo de Contraseña
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                obscuringCharacter: '*',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor ingrese la contraseña';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  label: const Text("Contraseña"),
                                  hintText: 'Ingrese la contraseña',
                                  hintStyle:
                                      const TextStyle(color: Colors.black26),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  labelStyle:
                                      const TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Botón de Registrarse
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _register,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    'Registrarse',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
