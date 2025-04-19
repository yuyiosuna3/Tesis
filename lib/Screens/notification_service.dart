import 'package:flutter_local_notifications/flutter_local_notifications.dart';                            // Importa el paquete para manejar notificaciones locales

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();  // Instancia principal del plugin de notificaciones
  static final Map<String, int> _activeNotifications = {};                                                // Almacenar títulos con sus IDs
  static int _notificationIdCounter = 0;                                                                  // Contador para generar IDs únicos
  static const int _maxNotifications = 3;                                                                 // Número máximo de notificaciones simultáneas

  /// Inicializa las configuraciones de notificaciones
  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher'); // Ícono de la app
    final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);     // Inicialización combinada
    await _notificationsPlugin.initialize(initializationSettings);                                                            // Inicializar el plugin con la configuración dada
  }

  // Muestra una notificación y mantiene un máximo de 3 títulos distintos activos
  static Future<void> showNotification(String title, String body) async {
    if (_activeNotifications.containsKey(title)) {                                                      // Reutiliza el ID de la notificación existente
      // Si el título ya está en la lista, actualizar la notificación existente
      int existingId = _activeNotifications[title]!;
      await _notificationsPlugin.show(existingId, title, body, const NotificationDetails(
        android: AndroidNotificationDetails(
          'default_channel', // Canal por defecto
          'Default',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ));
    } else {
      if (_activeNotifications.length >= _maxNotifications) { // Elimina la notificación más antigua para hacer espacio
        // Remover la notificación más antigua
        String oldestTitle = _activeNotifications.keys.first; 
        int oldestId = _activeNotifications.remove(oldestTitle)!;
        await _notificationsPlugin.cancel(oldestId); // Cancela esa notificación
      }
      // Agregar nueva notificación
      _notificationIdCounter++;
      _activeNotifications[title] = _notificationIdCounter;
      // Muestra la nueva notificación
      await _notificationsPlugin.show(_notificationIdCounter, title, body, const NotificationDetails(
        android: AndroidNotificationDetails(
          'default_channel',
          'Default',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ));
    }
  }
}
