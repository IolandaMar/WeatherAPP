import 'package:flutter/material.dart';
import 'dart:math';

class AnimatedGaugeTile extends StatefulWidget {
  final IconData icona;
  final String etiqueta;
  final String unitat;
  final double valor;
  final double maxValor;
  final Color color;

  const AnimatedGaugeTile({
    super.key,
    required this.icona,
    required this.etiqueta,
    required this.unitat,
    required this.valor,
    required this.maxValor,
    required this.color,
  });

  @override
  State<AnimatedGaugeTile> createState() => _AnimatedGaugeTileState();
}

class _AnimatedGaugeTileState extends State<AnimatedGaugeTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _angleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    final angle = (widget.valor / widget.maxValor) * pi;
    _angleAnim = Tween<double>(begin: 0.0, end: angle).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final fontSize = screenHeight < 750 ? 14.0 : 16.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        children: [
          Icon(widget.icona, color: Colors.white70, size: 20),
          const SizedBox(height: 6),
          SizedBox(
            width: 70,
            height: 38,
            child: AnimatedBuilder(
              animation: _angleAnim,
              builder: (context, _) => CustomPaint(
                painter: _SemicirclePainter(
                  percentAngle: _angleAnim.value,
                  color: widget.color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${widget.valor.toStringAsFixed(0)} ${widget.unitat}',
            style: TextStyle(color: Colors.white, fontSize: fontSize),
          ),
          Text(
            widget.etiqueta,
            style: TextStyle(color: Colors.white70, fontSize: fontSize - 2),
          ),
        ],
      ),
    );
  }
}

class _SemicirclePainter extends CustomPainter {
  final double percentAngle;
  final Color color;

  _SemicirclePainter({required this.percentAngle, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    final valuePaint = Paint()
      ..shader = SweepGradient(
        startAngle: pi,
        endAngle: pi + percentAngle,
        colors: [color.withOpacity(0.2), color],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width / 2, size.height),
        radius: size.width / 2,
      ))
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi,
      false,
      basePaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      percentAngle,
      false,
      valuePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SemicirclePainter oldDelegate) =>
      oldDelegate.percentAngle != percentAngle || oldDelegate.color != color;
}
