import 'package:flutter/material.dart';

class ForecastList extends StatelessWidget {
  final List<dynamic> forecastData;

  const ForecastList({Key? key, required this.forecastData}) : super(key: key);

  String getWeekdayFromTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return ['Dg', 'Dl', 'Dt', 'Dc', 'Dj', 'Dv', 'Ds'][date.weekday % 7];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: forecastData.map((forecast) {
        final weekday = getWeekdayFromTimestamp(forecast['dt']);
        final tempMax = forecast['main']['temp_max'].toDouble().toStringAsFixed(0);
        final tempMin = forecast['main']['temp_min'].toDouble().toStringAsFixed(0);
        final icon = forecast['weather'][0]['icon'];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                weekday,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Image.network(
                'http://openweathermap.org/img/wn/$icon@2x.png',
                width: 40,
                height: 40,
              ),
              Row(
                children: [
                  Text(
                    '$tempMax° ',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '/ $tempMin°',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
