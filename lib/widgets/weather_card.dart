import 'package:flutter/material.dart';
import 'package:weatherappfinal/screens/city_screen.dart';

class WeatherCard extends StatelessWidget {
  final String ciutat;
  final Map<String, dynamic> dades;
  final bool enCelsius;
  final String hora;
  final double tempMax;
  final double tempMin;
  final String icona;
  final double uvIndex;
  final Color uvColor;
  final bool esUbicacio;

  const WeatherCard({
    super.key,
    required this.ciutat,
    required this.dades,
    required this.enCelsius,
    required this.hora,
    required this.tempMax,
    required this.tempMin,
    required this.icona,
    required this.uvIndex,
    required this.uvColor,
    this.esUbicacio = false,
  });

  double convertirTemp(double temp) => enCelsius ? temp : (temp * 9 / 5) + 32;

  String _traduirDescripcio(String descripcio) {
    switch (descripcio.toLowerCase()) {
      case 'clear sky':
        return 'Cel net';
      case 'few clouds':
      case 'scattered clouds':
      case 'broken clouds':
        return 'Núvols dispersos';
      case 'overcast clouds':
        return 'Ennuvolat';
      case 'shower rain':
      case 'rain':
        return 'Pluja';
      case 'thunderstorm':
        return 'Tempesta';
      case 'snow':
        return 'Neu';
      case 'mist':
        return 'Boira';
      default:
        return descripcio;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double temperatura = (dades['main']['temp'] as num).toDouble();
    final String descripcio = dades['weather'][0]['description'];
    final String icona = dades['weather'][0]['icon'];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CityScreen(
              ciutat: ciutat,
              enCelsius: enCelsius,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/$icona.jpeg'),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(20),
          color: Colors.black.withOpacity(0.6),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          children: [
            Image.asset(
              'assets/icons/$icona.png',
              width: 50,
              height: 50,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if (esUbicacio)
                            const Icon(Icons.my_location, size: 18, color: Colors.white70),
                          if (esUbicacio) const SizedBox(width: 4),
                          Text(
                            ciutat,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      if (hora.isNotEmpty)
                        Text(
                          hora,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '${convertirTemp(temperatura).toStringAsFixed(0)}°',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          _traduirDescripcio(descripcio),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.wb_sunny, size: 18, color: uvColor),
                      const SizedBox(width: 4),
                      Text(
                        'UV: ${uvIndex.toStringAsFixed(1)}',
                        style: TextStyle(
                          color: uvColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'M: ${convertirTemp(tempMax).toStringAsFixed(0)}°',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'm: ${convertirTemp(tempMin).toStringAsFixed(0)}°',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
