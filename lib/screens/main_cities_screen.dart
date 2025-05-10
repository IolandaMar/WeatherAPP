import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/weather_service.dart';
import 'home_screen.dart';

class MainCitiesScreen extends StatefulWidget {
  const MainCitiesScreen({super.key});

  @override
  State<MainCitiesScreen> createState() => _MainCitiesScreenState();
}

class _MainCitiesScreenState extends State<MainCitiesScreen> {
  final WeatherService _weatherService = WeatherService();
  final TextEditingController _searchController = TextEditingController();
  final List<String> _ciutatsSeleccionades = [];
  String? _ciutatUbicacio;
  bool _carregant = true;

  @override
  void initState() {
    super.initState();
    _obtenirUbicacioActual();
  }

  Future<void> _obtenirUbicacioActual() async {
    try {
      final serveiActiu = await Geolocator.isLocationServiceEnabled();
      var permis = await Geolocator.checkPermission();
      if (!serveiActiu || permis == LocationPermission.denied) {
        permis = await Geolocator.requestPermission();
      }
      if (permis == LocationPermission.denied || permis == LocationPermission.deniedForever) {
        throw 'Permís de localització no concedit';
      }

      final posicio = await Geolocator.getCurrentPosition();
      final dades = await _weatherService.fetchCurrentWeatherByLocation(
        posicio.latitude,
        posicio.longitude,
      );

      setState(() {
        _ciutatUbicacio = dades['name'];
        _carregant = false;
      });
    } catch (e) {
      setState(() {
        _ciutatUbicacio = 'Ubicació desconeguda';
        _carregant = false;
      });
    }
  }

  void _afegirCiutat(String ciutat) {
    ciutat = ciutat.trim();
    if (ciutat.isEmpty ||
        _ciutatsSeleccionades.any((c) => c.toLowerCase() == ciutat.toLowerCase()) ||
        ciutat.toLowerCase() == (_ciutatUbicacio?.toLowerCase() ?? '') ||
        ciutat.toLowerCase() == 'ubicació desconeguda') {
      return;
    }

    if (_ciutatsSeleccionades.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Només pots afegir fins a 4 ciutats extra.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _ciutatsSeleccionades.add(ciutat);
      _searchController.clear();
    });
  }

  void _anarALaHome() async {
    final ciutatsFinals = <String>[
      'La meva ubicació',
      ..._ciutatsSeleccionades,
    ];

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('ciutats', ciutatsFinals);

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) =>
            HomeScreen(ciutats: ciutatsFinals),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Configura ciutats'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_carregant)
              const Center(child: CircularProgressIndicator(color: Colors.white))
            else
              Card(
                color: Colors.grey[900],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: const Icon(Icons.my_location, color: Colors.lightBlueAccent),
                  title: Text(
                    'Ubicació actual',
                    style: TextStyle(color: Colors.white.withOpacity(0.8)),
                  ),
                  subtitle: Text(
                    _ciutatUbicacio ?? '',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            TextField(
              controller: _searchController,
              onSubmitted: _afegirCiutat,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Afegeix una ciutat',
                hintStyle: const TextStyle(color: Colors.white60),
                prefixIcon: const Icon(Icons.search, color: Colors.white60),
                filled: true,
                fillColor: Colors.grey[850],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 20),
            if (_ciutatsSeleccionades.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _ciutatsSeleccionades.map((ciutat) {
                  return Chip(
                    backgroundColor: Colors.blueAccent,
                    label: Text(ciutat, style: const TextStyle(color: Colors.white)),
                    deleteIcon: const Icon(Icons.close, color: Colors.white),
                    onDeleted: () {
                      setState(() {
                        _ciutatsSeleccionades.remove(ciutat);
                      });
                    },
                  );
                }).toList(),
              ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _ciutatUbicacio != null ? _anarALaHome : null,
              icon: const Icon(Icons.arrow_forward, color: Colors.white),
              label: const Text('Continuar', style: TextStyle(fontSize: 18, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
