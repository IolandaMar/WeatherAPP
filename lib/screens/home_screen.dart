import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/weather_service.dart';
import '../widgets/weather_card.dart';
import 'radar_screen.dart';

class HomeScreen extends StatefulWidget {
  final List<String>? ciutats;

  const HomeScreen({super.key, this.ciutats});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  final Map<String, Map<String, dynamic>> _tempsCiutats = {};
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<String> _ciutats = [];
  bool _enCelsius = true;
  String _nomUbicacio = 'La meva ubicació';
  bool _carregant = true;

  @override
  void initState() {
    super.initState();
    _inicialitzarCiutats();
  }

  Future<void> _inicialitzarCiutats() async {
    setState(() => _carregant = true);

    final prefs = await SharedPreferences.getInstance();
    _nomUbicacio = prefs.getString('nomUbicacio') ?? 'La meva ubicació';
    final ciutatsGuardades = prefs.getStringList('ciutats');

    if (widget.ciutats != null && widget.ciutats!.isNotEmpty) {
      _ciutats = widget.ciutats!.map((c) => c.trim()).toSet().toList();
      await _desaCiutats();
    } else if (ciutatsGuardades != null && ciutatsGuardades.isNotEmpty) {
      _ciutats = ciutatsGuardades;
    } else {
      _ciutats = ['La meva ubicació'];
      await _desaCiutats();
    }

    if (_ciutats.isEmpty || _ciutats[0] != 'La meva ubicació') {
      _ciutats.insert(0, 'La meva ubicació');
    }

    await _carregarTotesLesCiutats();
    setState(() => _carregant = false);
  }

  Future<void> _desaCiutats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('ciutats', _ciutats);
  }

  Future<Position> _obtenirUbicacio() async {
    bool serveiActiu = await Geolocator.isLocationServiceEnabled();
    if (!serveiActiu) throw 'La localització està desactivada.';

    LocationPermission permis = await Geolocator.checkPermission();
    if (permis == LocationPermission.denied) {
      permis = await Geolocator.requestPermission();
      if (permis == LocationPermission.denied) {
        throw 'Permís denegat per accedir a la ubicació.';
      }
    }
    if (permis == LocationPermission.deniedForever) {
      throw 'Permís de localització denegat permanentment.';
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _carregarTotesLesCiutats() async {
    for (int i = 0; i < _ciutats.length; i++) {
      String ciutat = _ciutats[i];
      try {
        Map<String, dynamic> dades;

        if (i == 0 && ciutat == 'La meva ubicació') {
          final posicio = await _obtenirUbicacio();
          dades = await _weatherService.fetchCurrentWeatherByLocation(
            posicio.latitude,
            posicio.longitude,
          );
          final nomReal = dades['name'];
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('nomUbicacio', nomReal);
          _nomUbicacio = nomReal;
        } else {
          dades = await _weatherService.fetchCurrentWeather(ciutat);
        }

        final hour = DateTime.now().hour;
        double uvIndex = hour < 6 || hour > 19
            ? 0.0
            : hour < 9 || hour > 17
            ? 1.0 + (i % 3)
            : hour < 11 || hour > 15
            ? 3.0 + (i % 3)
            : 6.0 + (i % 3);

        dades['uv'] = uvIndex;

        setState(() {
          _tempsCiutats[ciutat] = dades;
        });
      } catch (e) {
        debugPrint('Error carregant dades per a $ciutat: $e');
      }
    }
  }

  Future<void> _afegirCiutat(String ciutat) async {
    ciutat = ciutat.trim();
    if (ciutat.isEmpty || _ciutats.any((c) => c.toLowerCase() == ciutat.toLowerCase())) return;

    try {
      final dades = await _weatherService.fetchCurrentWeather(ciutat);
      final hour = DateTime.now().hour;
      double uvIndex = hour < 6 || hour > 19
          ? 0.0
          : hour < 9 || hour > 17
          ? 1.0 + (_ciutats.length % 3)
          : hour < 11 || hour > 15
          ? 3.0 + (_ciutats.length % 3)
          : 6.0 + (_ciutats.length % 3);

      dades['uv'] = uvIndex;

      setState(() {
        _ciutats.add(ciutat);
        _tempsCiutats[ciutat] = dades;
        _listKey.currentState?.insertItem(_ciutats.length - 1);
      });

      await _desaCiutats();
      _searchController.clear();
      _searchFocusNode.unfocus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No s\'ha trobat la ciutat: $ciutat'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _eliminarCiutat(int index) async {
    final ciutatEliminada = _ciutats[index];
    final dadesEliminades = _tempsCiutats[ciutatEliminada];

    _ciutats.removeAt(index);
    _tempsCiutats.remove(ciutatEliminada);
    await _desaCiutats();

    _listKey.currentState?.removeItem(
      index,
          (context, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(-0.1, 0),
            ).animate(animation),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: WeatherCard(
                ciutat: ciutatEliminada,
                dades: dadesEliminades ?? {},
                enCelsius: _enCelsius,
                hora: '',
                tempMax: 0,
                tempMin: 0,
                icona: '',
                uvIndex: 0.0,
                uvColor: Colors.grey,
                esUbicacio: ciutatEliminada == 'La meva ubicació',
              ),
            ),
          ),
        );
      },
      duration: const Duration(milliseconds: 350),
    );
  }

  Color _colorPerUV(double uv) {
    if (uv <= 2) return Colors.greenAccent;
    if (uv <= 5) return Colors.yellowAccent;
    if (uv <= 7) return Colors.orangeAccent;
    if (uv <= 10) return Colors.redAccent;
    return Colors.purpleAccent;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_carregant) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Weather App',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Cerca una ciutat',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              style: const TextStyle(color: Colors.black),
              onSubmitted: _afegirCiutat,
            ),
          ),
          Expanded(
            child: AnimatedList(
              key: _listKey,
              initialItemCount: _ciutats.length,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              itemBuilder: (context, index, animation) {
                final ciutatOriginal = _ciutats[index];
                final ciutatMostrar = ciutatOriginal == 'La meva ubicació'
                    ? _nomUbicacio
                    : ciutatOriginal;
                final dades = _tempsCiutats[ciutatOriginal];

                if (dades == null) return const SizedBox();

                final tempMax = (dades['main']['temp_max'] as num).toDouble();
                final tempMin = (dades['main']['temp_min'] as num).toDouble();
                final icona = dades['weather'][0]['icon'];
                final uvIndex = (dades['uv'] as num?)?.toDouble() ?? 0.0;
                final hora =
                    '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}';

                return SizeTransition(
                  sizeFactor: animation,
                  child: Dismissible(
                    key: Key(ciutatOriginal),
                    direction: DismissDirection.horizontal,
                    background: const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 20.0),
                        child: Icon(Icons.delete, color: Colors.white70),
                      ),
                    ),
                    secondaryBackground: const Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: 20.0),
                        child: Icon(Icons.delete, color: Colors.white70),
                      ),
                    ),
                    onDismissed: (_) => _eliminarCiutat(index),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: WeatherCard(
                        ciutat: ciutatMostrar,
                        dades: dades,
                        enCelsius: _enCelsius,
                        hora: hora,
                        tempMax: tempMax,
                        tempMin: tempMin,
                        icona: icona,
                        uvIndex: uvIndex,
                        uvColor: _colorPerUV(uvIndex),
                        esUbicacio: ciutatOriginal == 'La meva ubicació',
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'radarBtn',
            backgroundColor: Colors.transparent,
            elevation: 0,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RadarScreen()),
              );
            },
            child: const Icon(Icons.radar, color: Colors.greenAccent),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'unitBtn',
            backgroundColor: Colors.transparent,
            elevation: 0,
            onPressed: () => setState(() => _enCelsius = !_enCelsius),
            child: Text(
              _enCelsius ? '°C' : '°F',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlueAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
