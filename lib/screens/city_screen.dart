import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weatherappfinal/services/weather_service.dart';
import 'package:weatherappfinal/models/weather_model.dart';
import 'package:weatherappfinal/widgets/city_header.dart';
import 'package:weatherappfinal/widgets/forecast_hourly.dart';
import 'package:weatherappfinal/widgets/forecast_daily.dart';
import 'package:weatherappfinal/widgets/weather_detail_grid.dart';
import 'package:weatherappfinal/screens/astronomy_screen.dart';
import 'package:weatherappfinal/widgets/widgets_animated/fade_in_on_scroll.dart';

class CityScreen extends StatefulWidget {
  final String ciutat;
  final bool enCelsius;

  const CityScreen({
    Key? key,
    required this.ciutat,
    required this.enCelsius,
  }) : super(key: key);

  @override
  State<CityScreen> createState() => _CityScreenState();
}

class _CityScreenState extends State<CityScreen> {
  final WeatherService _weatherService = WeatherService();
  Weather? _tempsActual;
  List<dynamic> _previsio = [];
  int _uvIndex = 5;
  String _nomCiutat = '';
  bool _carregant = true;

  @override
  void initState() {
    super.initState();
    _carregarDades();
  }

  Future<void> _carregarDades() async {
    try {
      if (widget.ciutat == "La meva ubicació") {
        bool serveiActiu = await Geolocator.isLocationServiceEnabled();
        LocationPermission permis = await Geolocator.checkPermission();

        if (!serveiActiu || permis == LocationPermission.denied) {
          permis = await Geolocator.requestPermission();
        }

        if (permis == LocationPermission.denied || permis == LocationPermission.deniedForever) {
          throw 'Permís de localització no concedit.';
        }

        final posicio = await Geolocator.getCurrentPosition();
        final lat = posicio.latitude;
        final lon = posicio.longitude;

        final dades = await _weatherService.fetchWeatherByCoords(lat, lon);
        final forecast = await _weatherService.fetchForecastByCoords(lat, lon);
        final uv = await _weatherService.fetchUvIndex(lat, lon);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('nomUbicacio', dades['name']);

        setState(() {
          _tempsActual = Weather.fromJson(dades);
          _previsio = forecast;
          _uvIndex = uv.round();
          _nomCiutat = dades['name'] ?? 'Ubicació actual';
          _carregant = false;
        });
      } else {
        final dades = await _weatherService.fetchCurrentWeather(widget.ciutat);
        final forecast = await _weatherService.fetchForecast(widget.ciutat);

        setState(() {
          _tempsActual = Weather.fromJson(dades);
          _previsio = forecast;
          _uvIndex = 5;
          _nomCiutat = widget.ciutat;
          _carregant = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error carregant dades: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      setState(() {
        _tempsActual = null;
        _previsio = [];
        _carregant = false;
      });
    }
  }

  String _getBackgroundImage(String icona) {
    return 'assets/images/$icona.jpeg';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _carregant
          ? const Center(child: CircularProgressIndicator())
          : _tempsActual == null
          ? const Center(child: Text('No s’han pogut carregar les dades'))
          : Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              _getBackgroundImage(_tempsActual!.icona),
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.auto_awesome, color: Colors.amberAccent),
                        tooltip: 'Astronomia',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AstronomyScreen(
                                latitude: _tempsActual!.latitud,
                                longitude: _tempsActual!.longitud,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FadeInOnScroll(
                    delay: const Duration(milliseconds: 100),
                    child: CityHeader(
                      ciutat: _nomCiutat.isNotEmpty ? _nomCiutat : widget.ciutat,
                      icona: _tempsActual!.icona,
                      temperatura: _tempsActual!.temperatura,
                      descripcio: _tempsActual!.descripcio,
                      enCelsius: widget.enCelsius,
                      tempMax: (_previsio.isNotEmpty &&
                          _previsio.first['main']?['temp_max'] != null)
                          ? _previsio.first['main']['temp_max'].toDouble()
                          : null,
                      tempMin: (_previsio.isNotEmpty &&
                          _previsio.first['main']?['temp_min'] != null)
                          ? _previsio.first['main']['temp_min'].toDouble()
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_previsio.isNotEmpty)
                    FadeInOnScroll(
                      delay: const Duration(milliseconds: 200),
                      child: ForecastHourly(
                        forecastData: _previsio,
                        enCelsius: widget.enCelsius,
                      ),
                    ),
                  const SizedBox(height: 32),
                  if (_previsio.isNotEmpty)
                    FadeInOnScroll(
                      delay: const Duration(milliseconds: 300),
                      child: ForecastDaily(
                        forecastData: _previsio,
                        enCelsius: widget.enCelsius,
                      ),
                    ),
                  const SizedBox(height: 32),
                  FadeInOnScroll(
                    delay: const Duration(milliseconds: 400),
                    child: WeatherDetailGrid(
                      ventVelocitat: _tempsActual!.ventVelocitat,
                      ventAngle: _tempsActual!.windDeg.toDouble(),
                      sensacio: _tempsActual!.sensacioTermica,
                      pressio: _tempsActual!.pressio,
                      humitat: _tempsActual!.humitat,
                      visibilitat: _tempsActual!.visibilitat,
                      uvIndex: _uvIndex,
                      enCelsius: widget.enCelsius,
                      animat: true,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
