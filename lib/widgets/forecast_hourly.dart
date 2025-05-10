import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ForecastHourly extends StatelessWidget {
  final List<dynamic> forecastData;
  final bool enCelsius;

  const ForecastHourly({
    super.key,
    required this.forecastData,
    required this.enCelsius,
  });

  double convertirTemp(double temp) =>
      enCelsius ? temp : (temp * 9 / 5) + 32;

  String formatHora(DateTime date) {
    return DateFormat.Hm().format(date); // Ex: 17:00
  }

  @override
  Widget build(BuildContext context) {
    final primerDia = forecastData
        .take(12)
        .map((entrada) => DateTime.fromMillisecondsSinceEpoch(entrada['dt'] * 1000))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.access_time, color: Colors.white70, size: 18),
            SizedBox(width: 8),
            Text(
              'Avui',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 12,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final entrada = forecastData[index];
              final date = DateTime.fromMillisecondsSinceEpoch(entrada['dt'] * 1000);
              final hora = formatHora(date);
              final temp = convertirTemp(entrada['main']['temp']).toStringAsFixed(0);
              final icon = entrada['weather'][0]['icon'];

              return Container(
                width: 70,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      hora,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Image.asset(
                      'assets/icons/$icon.png',
                      width: 32,
                      height: 32,
                    ),
                    Text(
                      '$temp°',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
