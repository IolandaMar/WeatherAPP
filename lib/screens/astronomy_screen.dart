import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AstronomyScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  const AstronomyScreen({Key? key, required this.latitude, required this.longitude}) : super(key: key);

  @override
  _AstronomyScreenState createState() => _AstronomyScreenState();
}

class _AstronomyScreenState extends State<AstronomyScreen> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? astronomyData;
  String? zodiacSign;
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    fetchAstronomyData();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeInAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchAstronomyData() async {
    const apiKey = 'f86dc7257fe74d62b1775e37ef36eae1';
    final url = Uri.parse(
      'https://api.ipgeolocation.io/astronomy?apiKey=$apiKey&lat=${widget.latitude}&long=${widget.longitude}',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final now = DateTime.now();
        final sign = getZodiacSign(now.month, now.day);

        setState(() {
          astronomyData = data;
          zodiacSign = sign;
          isLoading = false;
        });
      } else {
        throw Exception('Error carregant dades astronòmiques.');
      }
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  String getZodiacSign(int month, int day) {
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return '♒ Aquari';
    if ((month == 2 && day >= 19) || (month == 3 && day <= 20)) return '♓ Peixos';
    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return '♈ Àries';
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return '♉ Taure';
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return '♊ Bessons';
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return '♋ Càncer';
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return '♌ Lleó';
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return '♍ Verge';
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return '♎ Balança';
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return '♏ Escorpí';
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return '♐ Sagitari';
    return '♑ Capricorn';
  }

  String translatePhase(String phase) {
    final normalized = phase
        .toLowerCase()
        .replaceAll('-', ' ')
        .replaceAll('_', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    switch (normalized) {
      case 'new moon': return 'Lluna nova';
      case 'full moon': return 'Lluna plena';
      case 'first quarter': return 'Quart creixent';
      case 'last quarter':
      case 'third quarter': return 'Quart minvant';
      case 'waning crescent': return 'Lluna minvant';
      case 'waxing crescent': return 'Lluna creixent';
      case 'waning gibbous': return 'Gibosa minvant';
      case 'waxing gibbous': return 'Gibosa creixent';
      default: return 'Fase desconeguda';
    }
  }

  Widget buildInfoTile(String label, String value, IconData icon) {
    return Card(
      color: Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: Colors.white70),
        title: Text(label, style: const TextStyle(color: Colors.white70)),
        trailing: Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget buildMoonPhase(String rawPhase) {
    final phase = rawPhase
        .toLowerCase()
        .replaceAll('-', ' ')
        .replaceAll('_', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    final phaseSymbols = {
      'new moon': '🌑',
      'full moon': '🌕',
      'first quarter': '🌓',
      'last quarter': '🌗',
      'third quarter': '🌗',
      'waning crescent': '🌘',
      'waxing crescent': '🌒',
      'waning gibbous': '🌖',
      'waxing gibbous': '🌔',
    };

    final symbol = phaseSymbols[phase] ?? '🌑';
    final translated = translatePhase(phase);

    return Column(
      children: [
        Text(symbol, style: const TextStyle(fontSize: 64)),
        const SizedBox(height: 8),
        Text(
          translated,
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget buildZodiacInfo() {
    return Column(
      children: [
        const SizedBox(height: 12),
        const Text('Signe Zodiacal Actual', style: TextStyle(color: Colors.white70, fontSize: 16)),
        const SizedBox(height: 6),
        Text(zodiacSign ?? '', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Astronomia', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
        opacity: _fadeInAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (astronomyData != null)
                buildMoonPhase(astronomyData!['moon_phase'] ?? ''),
              const SizedBox(height: 24),
              if (astronomyData != null) ...[
                buildInfoTile('Sortida del Sol', astronomyData!['sunrise'], Icons.wb_sunny_outlined),
                buildInfoTile('Posta del Sol', astronomyData!['sunset'], Icons.nightlight_outlined),
                buildInfoTile('Altura solar', '${astronomyData!['sun_altitude']}°', Icons.trending_up),
                buildInfoTile('Altura lunar', '${astronomyData!['moon_altitude']}°', Icons.brightness_2_outlined),
              ],
              const SizedBox(height: 20),
              buildZodiacInfo(),
              const SizedBox(height: 24),
              const Text(
                'Dades proporcionades per ipgeolocation.io',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
