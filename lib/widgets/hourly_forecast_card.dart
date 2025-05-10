import 'package:flutter/material.dart';

class HourlyForecastCard extends StatelessWidget {
  final String hour;
  final String icon;
  final double temperature;
  final bool enCelsius;

  const HourlyForecastCard({
    super.key,
    required this.hour,
    required this.icon,
    required this.temperature,
    required this.enCelsius,
  });

  double convertirTemp(double temp) =>
      enCelsius ? temp : (temp * 9 / 5) + 32;

  @override
  Widget build(BuildContext context) {
    final temp = convertirTemp(temperature).toStringAsFixed(0);

    return Container(
      width: 65,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            hour,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Image.asset(
            'assets/icons/$icon.png',
            width: 36,
            height: 36,
          ),
          const SizedBox(height: 8),
          Text(
            '$temp°',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
