import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RadarScreen extends StatefulWidget {
  const RadarScreen({super.key});

  @override
  State<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends State<RadarScreen> {
  late final WebViewController _controller;
  String _selectedOverlay = 'wind';
  double _initialLat = 41.589;
  double _initialLon = -0.956;
  String _language = 'ca';

  final Map<String, String> _overlayOptions = {
    'wind': '🌬️ Vent',
    'rain': '🌧️ Pluja',
    'temp': '🌡️ Temperatura',
    'clouds': '☁️ Núvols',
    'waves': '🌊 Ones',
    'pressure': '🔽 Pressió',
  };

  final Map<String, String> _languageOptions = {
    'ca': 'Català',
    'es': 'Castellano',
    'en': 'English',
  };

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
    _loadRadarHtml();
  }

  void _loadRadarHtml() {
    final htmlContent = """
    <!DOCTYPE html>
    <html lang="$_language">
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          html, body {
            margin: 0;
            padding: 0;
            height: 100%;
            background-color: black;
          }
          iframe {
            border: none;
            width: 100%;
            height: 100%;
          }
        </style>
      </head>
      <body>
        <iframe
          src="https://embed.windy.com/embed.html?type=map&location=coordinates&metricRain=default&metricTemp=default&metricWind=default&zoom=6&overlay=$_selectedOverlay&product=ecmwf&level=surface&lat=$_initialLat&lon=$_initialLon&detailLat=$_initialLat&detailLon=$_initialLon&marker=true"
          allowfullscreen
        ></iframe>
      </body>
    </html>
    """;

    _controller.loadHtmlString(htmlContent);
  }

  void _resetToInitialLocation() {
    _loadRadarHtml();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.8),
        elevation: 0,
        title: Text(
          _language == 'ca'
              ? 'Radar Meteorològic'
              : _language == 'es'
              ? 'Radar Meteorológico'
              : 'Weather Radar',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _buildDropdown(
              icon: Icons.layers,
              value: _selectedOverlay,
              items: _overlayOptions,
              onChanged: (value) {
                setState(() {
                  _selectedOverlay = value!;
                  _loadRadarHtml();
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _buildDropdown(
              icon: Icons.language,
              value: _language,
              items: _languageOptions,
              onChanged: (value) {
                setState(() {
                  _language = value!;
                  _loadRadarHtml();
                });
              },
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: Colors.orangeAccent,
              onPressed: _resetToInitialLocation,
              tooltip: _language == 'ca'
                  ? 'Torna a la ubicació inicial'
                  : _language == 'es'
                  ? 'Volver a la ubicación'
                  : 'Reset View',
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required IconData icon,
    required String value,
    required Map<String, String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: Colors.grey[900],
          icon: Icon(icon, color: Colors.white),
          value: value,
          onChanged: onChanged,
          items: items.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(entry.value, style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
        ),
      ),
    );
  }
}
