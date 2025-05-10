import 'package:flutter/material.dart';

class CityHeader extends StatelessWidget {
  final String ciutat;
  final String icona;
  final double temperatura;
  final String descripcio;
  final bool enCelsius;
  final double? tempMax;
  final double? tempMin;

  const CityHeader({
    super.key,
    required this.ciutat,
    required this.icona,
    required this.temperatura,
    required this.descripcio,
    required this.enCelsius,
    this.tempMax,
    this.tempMin,
  });

  double convertirTemp(double temp) =>
      enCelsius ? temp : (temp * 9 / 5) + 32;

  @override
  Widget build(BuildContext context) {
    final tempText = '${convertirTemp(temperatura).toStringAsFixed(0)}°';
    final descr = descripcio[0].toUpperCase() + descripcio.substring(1);
    final ciutatFormatejada =
        ciutat[0].toUpperCase() + ciutat.substring(1).toLowerCase();

    final tempMaxText = tempMax != null
        ? '${convertirTemp(tempMax!).toStringAsFixed(0)}°'
        : '';
    final tempMinText = tempMin != null
        ? '${convertirTemp(tempMin!).toStringAsFixed(0)}°'
        : '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          // Icona local
          Image.asset(
            'assets/icons/$icona.png',
            width: 80,
            height: 80,
          ),
          const SizedBox(height: 8),
          Text(
            ciutatFormatejada,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$tempText | $descr',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          if (tempMax != null && tempMin != null)
            Text(
              'H:$tempMaxText  L:$tempMinText',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }
}
