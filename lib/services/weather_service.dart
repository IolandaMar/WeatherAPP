import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = '25a15583ca9e0c606b06e57de52f9914';
  final String baseUrl = 'https://api.openweathermap.org/data/2.5';

  // Temps actual per ciutat
  Future<Map<String, dynamic>> fetchCurrentWeather(String city) async {
    final url = Uri.parse(
      '$baseUrl/weather?q=$city&appid=$apiKey&units=metric&lang=ca',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('No s\'ha pogut carregar el temps actual');
    }
  }

  // Temps actual per coordenades (ubicació)
  Future<Map<String, dynamic>> fetchCurrentWeatherByLocation(double lat, double lon) async {
    final url = Uri.parse(
      '$baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=ca',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error carregant dades de geolocalització');
    }
  }

  // Previsió per ciutat
  Future<List<dynamic>> fetchForecast(String city) async {
    final url = Uri.parse(
      '$baseUrl/forecast?q=$city&appid=$apiKey&units=metric&lang=ca',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['list'];
    } else {
      throw Exception('No s\'ha pogut carregar la previsió del temps');
    }
  }

  // Previsió per coordenades
  Future<List<dynamic>> fetchForecastByCoords(double lat, double lon) async {
    final url = Uri.parse(
      '$baseUrl/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=ca',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['list'];
    } else {
      throw Exception('No s\'ha pogut carregar la previsió per coordenades');
    }
  }

  Future<double> fetchUvIndex(double lat, double lon) async {
    try {
      final url = Uri.parse(
        '$baseUrl/onecall?lat=$lat&lon=$lon&exclude=minutely,hourly,daily,alerts&appid=$apiKey&units=metric',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['current']['uvi'].toDouble();
      } else {
        throw Exception('No s\'ha pogut obtenir l\'índex UV');
      }
    } catch (_) {
      // Si hi ha un error, estimem el valor UV en funció de l'hora
      final hour = DateTime.now().hour;
      if (hour < 6 || hour > 19) return 0.0;
      if (hour < 9 || hour > 17) return 1.0 + (lat + lon) % 2;
      if (hour < 11 || hour > 15) return 3.0 + (lat + lon) % 2;
      return 6.0 + (lat + lon) % 2;
    }
  }

  // Alias pel nom erroni usat abans
  Future<Map<String, dynamic>> fetchWeatherByCoords(double lat, double lon) {
    return fetchCurrentWeatherByLocation(lat, lon);
  }
}
