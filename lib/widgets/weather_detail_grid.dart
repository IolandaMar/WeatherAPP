import 'package:flutter/material.dart';
import 'detail_tile.dart';
import 'widgets_animated/fade_in_on_scroll.dart';
import 'widgets_animated/animated_gauge_tile.dart';

class WeatherDetailGrid extends StatelessWidget {
  final double ventVelocitat;
  final double ventAngle;
  final double sensacio;
  final int pressio;
  final int humitat;
  final int visibilitat;
  final int uvIndex;
  final bool enCelsius;
  final bool animat;

  const WeatherDetailGrid({
    super.key,
    required this.ventVelocitat,
    required this.ventAngle,
    required this.sensacio,
    required this.pressio,
    required this.humitat,
    required this.visibilitat,
    required this.uvIndex,
    required this.enCelsius,
    this.animat = false,
  });

  double convertirTemp(double temp) =>
      enCelsius ? temp : (temp * 9 / 5) + 32;

  String _formatKm(int metres) {
    return '${(metres / 1000).toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      _buildTile(
        AnimatedGaugeTile(
          icona: Icons.thermostat,
          etiqueta: 'Sensació',
          unitat: '°',
          valor: convertirTemp(sensacio),
          maxValor: 50,
          color: Colors.orangeAccent,
        ),
        delay: 0,
      ),
      _buildTile(
        AnimatedGaugeTile(
          icona: Icons.speed,
          etiqueta: 'Pressió',
          unitat: 'hPa',
          valor: pressio.toDouble(),
          maxValor: 1100,
          color: Colors.cyanAccent,
        ),
        delay: 1,
      ),
      _buildTile(
        AnimatedGaugeTile(
          icona: Icons.water_drop,
          etiqueta: 'Humitat',
          unitat: '%',
          valor: humitat.toDouble(),
          maxValor: 100,
          color: Colors.blueAccent,
        ),
        delay: 2,
      ),
      _buildTile(
        AnimatedGaugeTile(
          icona: Icons.wb_sunny,
          etiqueta: 'Índex UV',
          unitat: '',
          valor: uvIndex.toDouble(),
          maxValor: 11,
          color: _colorPerUV(uvIndex),
        ),
        delay: 3,
      ),
    ];

    final visibilitatTile = _buildTile(
      DetailTile(
        icona: Icons.visibility,
        etiqueta: 'Visibilitat',
        valor: _formatKm(visibilitat),
      ),
      delay: 4,
    );

    return Column(
      children: [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          padding: const EdgeInsets.only(bottom: 8),
          childAspectRatio: 1.1,
          children: items,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SizedBox(
            width: double.infinity,
            child: visibilitatTile,
          ),
        ),
      ],
    );
  }

  Widget _buildTile(Widget tile, {required int delay}) {
    if (!animat) return tile;

    return FadeInOnScroll(
      delay: Duration(milliseconds: 120 * delay),
      child: tile,
    );
  }

  Color _colorPerUV(int uv) {
    if (uv <= 2) return Colors.greenAccent;
    if (uv <= 5) return Colors.yellowAccent;
    if (uv <= 7) return Colors.orangeAccent;
    if (uv <= 10) return Colors.redAccent;
    return Colors.purpleAccent;
  }
}
