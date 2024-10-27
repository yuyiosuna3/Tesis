import 'package:flutter/material.dart';
import 'package:smart_gas/Screens/singin.dart';
import 'package:smart_gas/Screens/singup.dart';
import 'package:smart_gas/widgets/custom_scaffold.dart';
import 'package:smart_gas/widgets/sg_button.dart';

class SafeGas extends StatelessWidget {
  const SafeGas({super.key});

  @override
  Widget build(BuildContext context) {
    return  CustomScaffold(
      child: Column(
              children: [
                Flexible(
                  flex:8,
                  child: Container(
                    child: Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                           children: [
                            TextSpan(
                              text: 'SAFE\nGAS',
                              style: TextStyle(
                                fontFamily: 'OneDay',
                                fontSize: 100.0,
                                fontWeight: FontWeight.w500,
                              )),
                    TextSpan(
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
                 const Flexible (
                  flex: 1,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                             padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              Expanded(
                                child: SGButton(
                                  buttonText: 'Iniciar sesión',
                                  onTap: SignInScreen(),
                                  color: Colors.white,
                                  textColor:Colors.black,
                                )
                                ),
                              SizedBox(width: 20),
                              Expanded(
                                child: SGButton(
                                  buttonText: 'Registrarse',
                                  onTap: SignUpScreen(),
                                  color: Colors.white,
                                  textColor: Colors.black,
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
