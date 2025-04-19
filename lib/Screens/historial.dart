import 'package:flutter/material.dart';                                     // Librería principal de Flutter para construir interfaces de usuario.
import 'package:firebase_database/firebase_database.dart';                  // Permite acceder y escuchar datos en tiempo real desde Firebase Realtime Database.
import 'package:firebase_auth/firebase_auth.dart';                          // Proporciona métodos para autenticar y obtener el usuario actual.
import 'package:cloud_firestore/cloud_firestore.dart';                      // Permite acceder a documentos almacenados en Firebase Firestore.
import 'package:fl_chart/fl_chart.dart';                                    // Librería para crear gráficos como líneas, barras y más.
import 'package:intl/intl.dart';                                            // Para formatear fechas y horas de manera personalizada.

class HistorialScreen extends StatefulWidget {                              // Define una pantalla con estado para visualizar datos históricos.
  const HistorialScreen({super.key});

  @override
  _HistorialScreenState createState() => _HistorialScreenState();           // Crea el estado asociado al widget.
}

class _HistorialScreenState extends State<HistorialScreen> {
  DatabaseReference? _databaseRef;                                          // Referencia al nodo del historial en Firebase Realtime Database.
  List<FlSpot> _gasData = [];                                               // Lista de puntos (x,y) para graficar el historial del gas.
  Map<double, String> _pointDetails = {};                                   // Mapa para mostrar detalles (fecha y hora) en cada punto de la gráfica.
  String _highestPeakMessage = "Sin registros de pico";                     // Mensaje con el valor más alto de gas detectado.
  double _highestPeakValue = 0.0;                                           // Valor numérico del pico más alto de gas.
  bool _loading = true;                                                     // Muestra el estado de carga (spinner).


  @override
  void initState() {
    super.initState();
    _loadUserMacAndFetchValue();                                            // Al iniciar la pantalla, buscar la MAC del usuario y cargar datos del historial.
  }

  Future<void> _loadUserMacAndFetchValue() async {
    final user = FirebaseAuth.instance.currentUser;                         // Obtiene el usuario actualmente autenticado.

    if (user != null) {
      final userDoc = await FirebaseFirestore.instance                      // Busca el documento del usuario en Firestore.
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        final data = userDoc.data();                                         // Extrae los datos del documento.
        if (data != null && data['macAddress'] != null) {
          final String macAddress = data['macAddress'];                      // Obtiene la dirección MAC del dispositivo.
          _databaseRef = FirebaseDatabase.instance                           // Apunta a la ruta del historial en la base de datos.
              .ref('/devices/$macAddress/sensorData/history');

          _fetchRealTimeData();                                              // Inicia la escucha en tiempo real de esos datos.
        }
      }
    }
  }


  void _fetchRealTimeData() {
    if (_databaseRef != null) {
      _databaseRef!.onValue.listen((event) {                                // Escucha los cambios en tiempo real del nodo de historial.
        final historyData = event.snapshot.value as Map<dynamic, dynamic>?;

        if (historyData != null) {
          final List<FlSpot> tempGasData = [];                              // Lista temporal para los puntos.
          final Map<double, String> tempPointDetails = {};                  // Mapa temporal para detalles del punto.
          final DateTime now = DateTime.now();                              // Fecha y hora actual.
          final DateTime todayStart =                                       // Hora 00:00 del día actual.
              DateTime(now.year, now.month, now.day, 0, 0, 0);

          historyData.forEach((key, value) {
            if (value['date'] != null &&
                value['time'] != null &&
                value['value'] != null) {
              try {
                final DateTime entryTime = DateFormat("dd/MM/yyyy HH:mm:ss")
                    .parse('${value['date']} ${value['time']}');            // Convierte la fecha y hora del registro a DateTime.

                if (entryTime.isAfter(todayStart) && entryTime.isBefore(now)) {
                  final double timeInMinutes =
                      entryTime.difference(todayStart).inMinutes.toDouble();// X = minutos desde las 00:00
                  final double gasValue =
                      double.tryParse(value['value'].toString()) ?? 0;      // Y = valor de gas

                  tempGasData.add(FlSpot(timeInMinutes, gasValue));        // Agrega el punto al gráfico.
                  tempPointDetails[timeInMinutes] =
                      '${value['date']} ${value['time']}';                 // Asocia el punto con su hora.

                  if (gasValue > _highestPeakValue) {
                    _updateHighestPeak(entryTime, gasValue);               // Actualiza el pico si es mayor.
                  }
                }
              } catch (e) {
                print('Error parsing entry: $e');                          // Captura errores de conversión.
              }
            }
          });

          tempGasData.sort((a, b) => a.x.compareTo(b.x));                  // Ordena los puntos por tiempo (eje X).

          setState(() {
            _gasData = tempGasData;
            _pointDetails = tempPointDetails;
            _loading = false;                                             // Oculta el spinner.
          });
        }
      });
    }
  }


  void _updateHighestPeak(DateTime entryTime, double gasValue) {
    final String formattedDate =
        DateFormat("dd/MM/yyyy HH:mm").format(entryTime);                   // Formatea la fecha.
    setState(() {
      _highestPeakValue = gasValue;
      _highestPeakMessage =
          "Pico más alto:\n $gasValue%\n Se registró el $formattedDate";    // Actualiza el mensaje a mostrar.
    });
  }

  // Construccion de la interfaz
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,                                     // Fondo oscuro para toda la pantalla
      appBar: AppBar(                                                      // Barra superior con título
        title: const Text("Historial", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueGrey[900],
        elevation: 0,
      ),
      body: _loading                                                      // Si está cargando, muestra un spinner; si no, muestra el contenido
          ? const Center(child: CircularProgressIndicator())              // Indicador de carga
          : Column(
              children: [
                // Mostrar el último valor en pantalla
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Estado del Gas",
                    style: const TextStyle(
                        fontSize: 25, color: Colors.white),
                  ),
                ),
                // Gráfica que ocupa la mitad de la pantalla
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,      // Gráfico de historial de gas (ocupa 50% de la pantalla)
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          verticalInterval: 240, // Mostrar cada 4 horas
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey.shade600,
                              strokeWidth: 1,
                            );
                          },
                          getDrawingVerticalLine: (value) {
                            return FlLine(
                              color: Colors.grey.shade600,
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()}%',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.white),
                                );
                              },
                              interval: 20,
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                final hours = (value / 60).floor();
                                return Text(
                                  '${hours.toString().padLeft(2, '0')}h',
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.white),
                                );
                              },
                              interval: 240, // Intervalo de 4 horas en el eje X
                            ),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Colors.grey, width: 1),
                        ),
                        // Datos a graficar
                        lineBarsData: [
                          LineChartBarData(
                            spots: _gasData,  // Lista de puntos (tiempo, gas)
                            isCurved: false, // No curvar líneas
                            color: Colors.blueGrey,
                            barWidth: 0, // Sin líneas
                            isStrokeCapRound: false,
                            belowBarData: BarAreaData(
                              show: false, // Sin áreas debajo
                            ),
                            dotData: FlDotData( // Configuración de puntos
                              show: true, // Mostrar solo puntos
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 2, // Puntos más pequeños
                                  color: Colors.blueGrey.shade700,
                                  strokeWidth: 1,
                                  strokeColor: Colors.blueGrey.shade400,
                                );
                              },
                            ),
                          ),
                        ],
                        // Escala del gráfico
                        minX: 0,
                        maxX: 1440, // Escala para 24 horas (1440 minutos)
                        minY: 0,
                        maxY: 100,
                        // Tooltips al tocar un punto
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            tooltipPadding: const EdgeInsets.all(8),
                            tooltipMargin: 10,
                            tooltipRoundedRadius: 8,
                            tooltipBorder:
                                BorderSide(color: Colors.blueGrey, width: 1),
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((spot) {
                                final x = spot.x;
                                final y = spot.y;
                                final detail =
                                    _pointDetails[x] ?? "Sin información";
                                return LineTooltipItem(
                                  'Gas: ${y.toStringAsFixed(1)}%\n$detail',
                                  const TextStyle(color: Colors.white),
                                );
                              }).toList();
                            },
                          ),
                          handleBuiltInTouches: true,
                        ),
                      ),
                    ),
                  ),
                ),
                // Mostrar pico más alto
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _highestPeakMessage,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
    );
  }
}
