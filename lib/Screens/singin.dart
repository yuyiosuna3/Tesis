import 'package:flutter/material.dart';
import 'package:smart_gas/Screens/start.dart';
import 'package:smart_gas/widgets/custom_scaffold.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formSignInKey = GlobalKey<FormState>();

  // Controladores de usuario y contraseña
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // Función para validar credenciales
  Future<void> _signIn() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedUsername = prefs.getString('username');
    String? savedPassword = prefs.getString('password');

    if (_usernameController.text == savedUsername &&
        _passwordController.text == savedPassword) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Start()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario o contraseña incorrectos')),
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
                          key: _formSignInKey,
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

                              // Campo de Usuario
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: TextFormField(
                                  controller: _usernameController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingrese su usuario';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    label: const Text('Usuario'),
                                    hintText: 'Ingrese su usuario',
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
                                      return 'Por favor ingrese su contraseña';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    label: const Text("Contraseña"),
                                    hintText: 'Ingrese su contraseña',
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

                              // Botón de Ingresar
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (_formSignInKey.currentState!.validate()) {
                                        _signIn();
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(vertical: 15),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text(
                                      'Ingresar',
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
