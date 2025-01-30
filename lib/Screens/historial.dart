import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // Para manejar formatos de fecha y hora

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  _HistorialScreenState createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  DatabaseReference? _databaseRef;
  List<FlSpot> _gasData = [];
  Map<double, String> _pointDetails = {};
  String _lastValue = "Cargando..."; // Variable para mostrar el último valor
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserMacAndFetchValue();
  }

  Future<void> _loadUserMacAndFetchValue() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null && data['macAddress'] != null) {
          final String macAddress = data['macAddress'];
          _databaseRef = FirebaseDatabase.instance
              .ref('/devices/$macAddress/sensorData/history');

          _fetchRealTimeData();
        }
      }
    }
  }

  void _fetchRealTimeData() {
    if (_databaseRef != null) {
      _databaseRef!.onValue.listen((event) {
        final historyData = event.snapshot.value as Map<dynamic, dynamic>?;

        if (historyData != null) {
          final List<FlSpot> tempGasData = [];
          final Map<double, String> tempPointDetails = {};
          final DateTime now = DateTime.now();
          final DateTime todayStart =
              DateTime(now.year, now.month, now.day, 0, 0, 0); // 00:00 de hoy

          String lastValue = "No disponible";

          historyData.forEach((key, value) {
            if (value['date'] != null &&
                value['time'] != null &&
                value['value'] != null) {
              try {
                final DateTime entryTime = DateFormat("dd/MM/yyyy HH:mm:ss")
                    .parse('${value['date']} ${value['time']}');

                if (entryTime.isAfter(todayStart) && entryTime.isBefore(now)) {
                  final double timeInMinutes =
                      entryTime.difference(todayStart).inMinutes.toDouble();
                  final double gasValue =
                      double.tryParse(value['value'].toString()) ?? 0;

                  tempGasData.add(FlSpot(timeInMinutes, gasValue));
                  tempPointDetails[timeInMinutes] =
                      '${value['date']} ${value['time']}';
                }

                // Actualizar el último valor si es más reciente
                if (entryTime.isBefore(now)) {
                  lastValue = value['value'].toString();
                }
              } catch (e) {
                print('Error parsing entry: $e');
              }
            }
          });

          tempGasData
              .sort((a, b) => a.x.compareTo(b.x)); // Ordenar puntos por tiempo

          setState(() {
            _gasData = tempGasData;
            _pointDetails = tempPointDetails;
            _lastValue = lastValue;
            _loading = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historial", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Mostrar el último valor en pantalla
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Historial del Gas",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                // Gráfica que ocupa la mitad de la pantalla
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
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
                              color: Colors.grey.shade300,
                              strokeWidth: 1,
                            );
                          },
                          getDrawingVerticalLine: (value) {
                            return FlLine(
                              color: Colors.grey.shade300,
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
                                      fontSize: 12, color: Colors.black),
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
                                if (hours % 4 == 0) {
                                  return Text(
                                    '${hours.toString().padLeft(2, '0')}h',
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.black),
                                  );
                                }
                                return const SizedBox
                                    .shrink(); // Ocultar etiquetas intermedias
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
                        lineBarsData: [
                          LineChartBarData(
                            spots: _gasData,
                            isCurved: false, // No curvar líneas
                            color: Colors.blueGrey,
                            barWidth: 0, // Sin líneas
                            isStrokeCapRound: false,
                            belowBarData: BarAreaData(
                              show: false, // Sin áreas debajo
                            ),
                            dotData: FlDotData(
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
                        minX: 0,
                        maxX: 1440, // Escala para 24 horas (1440 minutos)
                        minY: 0,
                        maxY: 100,
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
                if (_gasData.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No hay datos disponibles en las últimas 24 horas.',
                      style: TextStyle(fontSize: 16, color: Colors.redAccent),
                    ),
                  ),
              ],
            ),
    );
  }
}
