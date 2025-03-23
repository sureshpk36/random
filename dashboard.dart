import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Current sensor values
  String tdsValue = "Loading...";
  String phValue = "7.2";
  String turbidityValue = "2.1 NTU";
  String temperatureValue = "23°C";
  String conductivityValue = "410 μS/cm";

  // ESP8266 IP address - replace with your actual ESP IP
  final String espIP = "192.168.4.1";

  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    // Fetch data every 2 seconds
    _updateTimer =
        Timer.periodic(const Duration(seconds: 2), (_) => fetchSensorData());
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchSensorData() async {
    try {
      final response = await http.get(Uri.parse('http://$espIP/'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          // Update the TDS value from ESP8266
          if (data.containsKey('tds')) {
            tdsValue = "${data['tds'].toStringAsFixed(1)} ppm";
          }
        });
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching data: $e");
      // Optional: Show error state in UI
    }
  }

  @override
  Widget build(BuildContext context) {
    // Overall Horizontal Padding = 16.0
    const double horizontalPadding = 16.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0B619C),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar: SizedBox height = 16
                const SizedBox(height: 16),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        // Dashboard Title: fontSize = 24, bold, color white
                        Text(
                          'Dashboard',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        // Subtitle ("UB System Overview"): fontSize = 16, white70
                        Text(
                          'UB System Overview',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon:
                          const Icon(Icons.notifications, color: Colors.white),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.settings, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // pH Card:
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Current pH Level',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF3E4A59),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // pH value: BOLD
                            Text(
                              phValue,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              height: 2,
                              color: Colors.blueGrey,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: const [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 20,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Safe Range (6.5 - 8.5)',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Color(0xFF41B06E),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Four Small Cards: TDS, Turbidity, Temperature, Conductivity
                Row(
                  children: [
                    Expanded(
                      child: _buildSmallCard(
                        icon: Icons.water_drop,
                        iconColor: const Color(0xFF369BF3),
                        title: 'TDS',
                        value: tdsValue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSmallCard(
                        icon: Icons.percent,
                        iconColor: const Color(0xFFF4C247),
                        title: 'Turbidity',
                        value: turbidityValue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildSmallCard(
                        icon: Icons.device_thermostat,
                        iconColor: const Color(0xFF369BF3),
                        title: 'Temperature',
                        value: temperatureValue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSmallCard(
                        icon: Icons.flash_on,
                        iconColor: const Color(0xFF369BF3),
                        title: 'Conductivity',
                        value: conductivityValue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 24h Monitoring Section:
                const Text(
                  '24h Monitoring',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: RealTimeChart(),
                  ),
                ),
                const SizedBox(height: 24),

                // Connection status indicator
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: tdsValue == "Loading..."
                        ? Colors.orange.withOpacity(0.7)
                        : Colors.green.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        tdsValue == "Loading..." ? Icons.wifi_off : Icons.wifi,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        tdsValue == "Loading..."
                            ? "Connecting to ESP8266..."
                            : "Connected to ESP8266 ($espIP)",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget for small cards
  Widget _buildSmallCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      // Row with Icon + Column of title and value
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title text
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                // Value text: BOLD
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold, // Confirmed bold
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RealTimeChart extends StatefulWidget {
  const RealTimeChart({Key? key}) : super(key: key);

  @override
  State<RealTimeChart> createState() => _RealTimeChartState();
}

class _RealTimeChartState extends State<RealTimeChart> {
  late List<ChartData> _phData;
  late List<ChartData> _tdsData;
  Timer? _timer;
  double _xValue = 0;

  @override
  void initState() {
    super.initState();
    _phData = [];
    _tdsData = [];
    _simulateIncomingData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Simulate incoming data every 2 seconds.
  void _simulateIncomingData() {
    final random = Random();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        _xValue += 1;
        final ph = 6.8 + random.nextDouble() * 0.5;
        final tds = 140 + random.nextDouble() * 20;
        _phData.add(ChartData(_xValue, ph));
        _tdsData.add(ChartData(_xValue, tds));

        // Keep the last 20 data points.
        if (_phData.length > 20) {
          _phData.removeAt(0);
          _tdsData.removeAt(0);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      legend: Legend(isVisible: true, position: LegendPosition.bottom),
      primaryXAxis: NumericAxis(
        labelStyle: const TextStyle(color: Colors.black54),
        axisLine: const AxisLine(color: Colors.black26),
        majorGridLines: const MajorGridLines(color: Colors.black12),
      ),
      primaryYAxis: NumericAxis(
        labelStyle: const TextStyle(color: Colors.black54),
        axisLine: const AxisLine(color: Colors.black26),
        majorGridLines: const MajorGridLines(color: Colors.black12),
      ),
      series: <LineSeries>[
        LineSeries<ChartData, double>(
          name: 'pH',
          dataSource: _phData,
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y,
          color: Colors.green,
          markerSettings: const MarkerSettings(isVisible: true),
        ),
        LineSeries<ChartData, double>(
          name: 'TDS',
          dataSource: _tdsData,
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y,
          color: Colors.blue,
          markerSettings: const MarkerSettings(isVisible: true),
        ),
      ],
    );
  }
}

class ChartData {
  final double x;
  final double y;
  ChartData(this.x, this.y);
}
