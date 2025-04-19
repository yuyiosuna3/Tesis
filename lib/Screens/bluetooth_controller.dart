import 'package:flutter_blue_plus/flutter_blue_plus.dart';                                // Importa la librería para manejar Bluetooth en Flutter
import 'package:get/get.dart';                                                            // Importa GetX para gestión de estado y controladores reactivos
import 'package:smart_gas/Screens/notification_service.dart';                             // Importa un servicio personalizado para mostrar notificaciones

class BluetoothController extends GetxController {                                        // Define una clase controlador que extiende GetxController para usar con GetX.
  final FlutterBluePlus flutterBlue = FlutterBluePlus();                                  // Instancia de la clase FlutterBluePlus para manejar operaciones Bluetooth.

  RxList<ScanResult> devicesList = <ScanResult>[].obs;                                    // Lista reactiva de dispositivos encontrados durante el escaneo.
  RxBool isScanning = false.obs;                                                          // Bandera reactiva que indica si se está escaneando dispositivos.
  BluetoothDevice? connectedDevice;                                                       // Dispositivo actualmente conectado
  BluetoothCharacteristic? targetCharacteristic;                                          // Característica Bluetooth sobre la cual se recibirán datos

  Future<void> scanDevices() async {                                                      // Función para comenzar el escaneo de dispositivos.
    if (isScanning.value) return;                                                         // Si ya está escaneando, no hace nada
    isScanning.value = true;                                                              // Cambia la bandera para indicar que está escaneando

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));                // Inicia el escaneo con un tiempo límite de 10 segundos
    FlutterBluePlus.scanResults.listen((results) {
      devicesList.value = results;                                                        // Actualiza la lista de dispositivos encontrados
      for (ScanResult r in results) {
        print("Dispositivo encontrado: ${r.device.platformName} - MAC: ${r.device.id}");  // Muestra cada dispositivo
      }
    });

    Future.delayed(const Duration(seconds: 10), () async {
      await stopScanning();                                                               // Detiene el escaneo luego de 10 segundos
    });
  }

  Future<void> stopScanning() async {                                                       
    if (!isScanning.value) return;                                                       // Si ya no se está escaneando, no hace nada
    await FlutterBluePlus.stopScan();                                                    // Detiene el escaneo
    isScanning.value = false;                                                            // Actualiza la bandera
  }

  /// Conectar a un dispositivo Bluetooth
  Future<void> connectToDevice(BluetoothDevice device) async {                           // Conecta al dispositivo seleccionado y busca sus servicios/características.
    try {
      await device.connect();                                                            // Intenta conectar
      connectedDevice = device;                                                          // Guarda el dispositivo conectado

      List<BluetoothService> services = await device.discoverServices();                 // Descubre servicios disponibles
      for (var service in services) {
        for (var characteristic in service.characteristics) {                           
          targetCharacteristic = characteristic;                                         // Asume que esta característica es la que se usará
          _startListening();                                                             // Comienza a escuchar datos de esa característica
        }
      }

      update();                                                                          // Actualiza el estado del controlador GetX
      print("Conectado a ${device.platformName}");                                       // Mensaje de éxito
    } catch (e) {
      print("Error al conectar: $e");                                                   // Muestra error en caso de falla
    }
  }

  /// Escuchar mensajes del Bluetooth y enviarlos a notificaciones
  void _startListening() {                                                              // Habilita notificaciones y escucha los datos entrantes del dispositivo conectado.
    targetCharacteristic?.setNotifyValue(true);                                         // Activa notificaciones
    targetCharacteristic?.value.listen((value) {
      String receivedMessage = String.fromCharCodes(value);                             // Convierte los bytes a string
      print("Mensaje recibido: $receivedMessage");                                      // Muestra el mensaje recibido

      // Mostrar notificación cuando se recibe un mensaje
      NotificationService.showNotification("Alerta Bluetooth", receivedMessage);       // Muestra una notificación usando tu servicio personalizado
    });
  }

  Future<void> disconnectDevice() async {
    if (connectedDevice == null) return;                                                // Si no hay dispositivo conectado, no hace nada
    await connectedDevice!.disconnect();                                                // Desconecta
    connectedDevice = null;                                                             // Limpia el valor
    update();                                                                           // Actualiza el estado del controlador
    print("Dispositivo desconectado.");                                                 // Muestra mensaje
  }


  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;              // Getter que expone el stream de resultados del escaneo para usarlo fácilmente desde la interfaz o widgets.
}
