import 'package:flutter/material.dart';
import 'package:smart_gas/Screens/safe_gas.dart';
import 'package:firebase_core/firebase_core.dart'; // Importa Firebase Core
import 'firebase_options.dart'; // Importa las opciones de configuración de Firebase
import 'package:smart_gas/Screens/settings.dart'; // Importa la pantalla de configuración (opcional)
import 'package:smart_gas/Screens/notification_service.dart';
import 'package:smart_gas/screens/start.dart';

void main() async {
  // Asegúrate de inicializar los bindings de Flutter antes de Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase con la configuración generada automáticamente
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

   // Inicializar notificaciones
  // Corre la aplicación
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Este widget es la raíz de la aplicación
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Configura la pantalla de inicio
      home: const SafeGas(), // Pantalla inicial de tu aplicación
    );
  }
}
