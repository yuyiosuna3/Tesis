import 'package:flutter/material.dart';                            // Librería principal de widgets de Flutter
import 'package:smart_gas/Screens/singin.dart';                    // Pantalla de inicio de sesión
import 'package:smart_gas/Screens/singup.dart';                    // Pantalla de registro
import 'package:smart_gas/widgets/custom_scaffold.dart';           // Scaffold personalizado
import 'package:smart_gas/widgets/sg_button.dart';                 // Botón personalizado SGButton

class SafeGas extends StatelessWidget {
  const SafeGas({super.key});

  @override
  Widget build(BuildContext context) {
    return  CustomScaffold(
      child: Column(
              children: [
                Flexible(                                       // Primer bloque: ocupa 8/9 partes de la pantalla
                  flex:8,
                  child: Container(
                    child: Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                           children: [
                            TextSpan(                            // Texto principal: nombre de la app
                              text: 'SAFE\nGAS',
                              style: TextStyle(
                                fontFamily: 'OneDay',            // Fuente personalizada
                                fontSize: 100.0,                 // Tamaño grande
                                fontWeight: FontWeight.w500,     // Peso medio
                              )),
                    TextSpan(                                    // Subtítulo debajo del nombre
                        text:'\n\nDetecta | Previene | Protege',
                        style: TextStyle(
                                fontFamily: 'Baskerville',
                                fontSize: 20.0,
                                fontWeight: FontWeight.w500,
                              )
                        

                    )
                          //  TextSpan()
                           ],
                        ),

                    )),
                  )),
                      const Flexible(                         // Segundo bloque: ocupa 1/9 parte de la pantalla
                        flex: 1,
                        child: Align(                         // Alineamos el contenido en la parte inferior derecha
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),    // Espacio lateral
                            child: Row(                                         // Fila con botones
                              mainAxisAlignment: MainAxisAlignment.center,      // Centrado horizontal
                              children: [
                                Expanded(                                       // Botón de inicio de sesión
                                  child: SGButton(
                                    buttonText: 'Iniciar sesión',               // Texto del botón
                                    onTap: SignInScreen(),                      // Navega a la pantalla de login
                                    color: Colors.white,                      // Fondo blanco
                                    textColor: Colors.black,                  // Texto negro
                                  ),
                                ),
                                SizedBox(width: 20),                            // Espacio entre los botones
                                Expanded(                                       // Botón de registro
                                  child: SGButton(
                                    buttonText: 'Registrarse',                  // Texto del botón
                                    onTap: SignUpScreen(),                      // Navega a la pantalla de registro
                                    color: Colors.white,                      // Fondo blanco
                                    textColor: Colors.black,                  // Texto negro
                                ),
                                ),
                          ],
                      
                      ),
                    ),
                  ),
                 ),
              ],   

      ),

    );
  }
}
