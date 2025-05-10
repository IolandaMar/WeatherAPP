import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ForecastDaily extends StatelessWidget {
  final List<dynamic> forecastData;
  final bool enCelsius;

  const ForecastDaily({
    super.key,
    required this.forecastData,
    required this.enCelsius,
  });

  double convertirTemp(double temp) =>
      enCelsius ? temp : (temp * 9 / 5) + 32;

  String getWeekdayCatalan(DateTime date) {
    const dies = ['Dg', 'Dl', 'Dt', 'Dc', 'Dj', 'Dv', 'Ds'];
    return dies[date.weekday % 7];
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, Map<String, dynamic>> diesUnics = {};
    for (var entrada in forecastData) {
      final date = DateTime.fromMillisecondsSinceEpoch(entrada['dt'] * 1000);
      final diaClau = DateFormat('yyyy-MM-dd').format(date);
      if (!diesUnics.containsKey(diaClau)) {
        diesUnics[diaClau] = entrada;
      }
    }

    final previsioDies = diesUnics.values.take(7).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.white70, size: 18),
            SizedBox(width: 8),
            Text(
              'Pròxims dies',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Column(
            children: previsioDies.map((forecast) {
              final date =
              DateTime.fromMillisecondsSinceEpoch(forecast['dt'] * 1000);
              final dia = getWeekdayCatalan(date);
              final icon = forecast['weather'][0]['icon'];
              final tempMax =
              convertirTemp(forecast['main']['temp_max']).toStringAsFixed(0);
              final tempMin =
              convertirTemp(forecast['main']['temp_min']).toStringAsFixed(0);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dia,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Image.asset(
                      'assets/icons/$icon.png',
                      width: 28,
                      height: 28,
                    ),
                    Text(
                      '$tempMax° / $tempMin°',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
