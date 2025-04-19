import 'package:flutter/material.dart';

class SGButton extends StatelessWidget {
  const SGButton({
    super.key,
    this.buttonText, // Texto que se mostrará dentro del botón
    this.onTap,      // Widget al que se navegará cuando se presione el botón
    this.color,      // Color de fondo del botón
    this.textColor,  // Color del texto
  });

  final String? buttonText;     // Texto del botón
  final Widget? onTap;          // Widget destino al hacer clic
  final Color? color;           // Color del botón
  final Color? textColor;       // Color del texto

  @override
  Widget build(BuildContext context) {
   return GestureDetector(      // Detecta el gesto de toque (tap)
      onTap: () {
        Navigator.push(         // Navega a la pantalla indicada
          context,
          MaterialPageRoute(    // Crea una nueva ruta con Material Design
            builder: (e) => onTap!, // Usa el widget pasado como destino
          ),
        );
      },
      child: Container(          // Contenedor visual del botón
        padding: const EdgeInsets.all(25.0), // Espaciado interno
        decoration: BoxDecoration( // Estilo del contenedor
          color: color!,            // Color del fondo (obligatorio en tiempo de ejecución)
          borderRadius: const BorderRadius.only( // Bordes redondeados en las 4 esquinas
            topLeft: Radius.circular(50),
            topRight: Radius.circular(50),
            bottomLeft: Radius.circular(50),
            bottomRight: Radius.circular(50),
          ),
        ),
        child: Text(               // Texto del botón
          buttonText!,             // Muestra el texto recibido
          textAlign: TextAlign.center, // Centra el texto dentro del botón
          style: TextStyle(
            fontSize: 15.0,              // Tamaño de letra
            fontWeight: FontWeight.bold, // Negrita
            color: textColor!,           // Color del texto
          ),
        ),
      ),
    );
  }
}