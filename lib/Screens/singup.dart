import 'package:flutter/material.dart';
import 'package:smart_gas/widgets/custom_scaffold.dart';
import 'package:smart_gas/screens/start.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formSignUpKey = GlobalKey<FormState>();

  // Controladores para capturar los datos ingresados
  final _macAddressController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // Función para registrar y almacenar datos en SharedPreferences
  Future<void> _register() async {
    if (_formSignUpKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('macAddress', _macAddressController.text);
      await prefs.setString('username', _usernameController.text);
      await prefs.setString('password', _passwordController.text);

      // Muestra un mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos registrados exitosamente')),
      );

      // Redirige a la pantalla de inicio `Start`
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Start()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
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
                        key: _formSignUpKey,
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
                              child: TextFormField(
                                controller: _macAddressController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor ingrese la MAC del dispositivo';
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
                            const SizedBox(height: 20),

                            // Campo de Usuario
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: TextFormField(
                                controller: _usernameController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor ingrese el usuario';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  label: const Text('Usuario'),
                                  hintText: 'Ingrese el usuario',
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
                            const SizedBox(height: 20),

                            // Campo de Contraseña
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                          
                            const SizedBox(height: 20),

                            // Botón de Registrarse
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _register,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(vertical: 15),
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
