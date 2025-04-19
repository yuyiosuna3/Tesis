import 'package:flutter/material.dart';                          // Widgets de interfaz de Flutter.
import 'package:smart_gas/Screens/bluetooth_controller.dart';    // Controlador personalizado para manejar lógica Bluetooth.
import 'package:flutter_blue_plus/flutter_blue_plus.dart';       // Librería para manejar BLE (Bluetooth Low Energy).
import 'package:get/get.dart';                                   // Librería para manejo de estado con GetX.

class Bt extends StatelessWidget {
  const Bt({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,                          // Fondo oscuro para toda la pantalla.
      appBar: AppBar(                                           // Barra superior con título y estilo.
        title: const Text(
          "Conexión Bluetooth",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey[900],
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white), // Flecha blanca
      ),
      body: GetBuilder<BluetoothController>(                  // Escucha cambios desde el controlador GetX.
        init: BluetoothController(),                          // Instancia el controlador si aún no existe.
        builder: (controller) {                               // Accede a las variables y métodos del controlador.
          return Column(
            children: [
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    controller.scanDevices();                 // Al presionar, inicia el escaneo BLE.
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 108, 196, 237),
                    minimumSize: const Size(250, 50),        // Tamaño del botón.
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Buscar dispositivos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(                                        // Ocupa el espacio restante de la pantalla.
                child: StreamBuilder<List<ScanResult>>(        // Escucha la transmisión de dispositivos encontrados.
                  stream: controller.scanResults,              // Fuente de datos en vivo desde el controlador.
                  builder: (context, snapshot) {
                                        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      return ListView.builder(                 // Lista scrollable de dispositivos encontrados.
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final device = snapshot.data![index].device;
                          final deviceName = device.platformName.isNotEmpty
                              ? device.platformName            // Usa nombre real si está disponible...
                              : "Dispositivo sin nombre";      // ...sino muestra por defecto.


                          return Card(
                            color: Colors.grey[900],
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              title: Text(
                                deviceName,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                "MAC: ${device.id.id}",     // Muestra la dirección MAC del dispositivo.
                                style: const TextStyle(color: Colors.grey),
                              ),
                              trailing: TextButton(
                                onPressed: () {
                                  controller.connectToDevice(device);   // Llama al método para conectar.
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor:
                                      controller.connectedDevice == device
                                          ? Colors.greenAccent         // Si está conectado, color verde.
                                          : const Color.fromARGB(255, 108, 196, 237), // Si no, color azul.
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  controller.connectedDevice == device
                                      ? 'Conectado'                    // Texto cambia según estado.
                                      : 'Conectar',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return const Center(
                        child: Text(
                          'No se encontraron dispositivos',           // Mensaje cuando no hay nada que mostrar.
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      );
                    }
                  },
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
