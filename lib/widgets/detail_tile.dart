import 'package:flutter/material.dart';

class DetailTile extends StatefulWidget {
  final IconData icona;
  final String etiqueta;
  final String valor;
  final int delayIndex;

  const DetailTile({
    super.key,
    required this.icona,
    required this.etiqueta,
    required this.valor,
    this.delayIndex = 0,
  });

  @override
  State<DetailTile> createState() => _DetailTileState();
}

class _DetailTileState extends State<DetailTile> with SingleTickerProviderStateMixin {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 150 * widget.delayIndex), () {
      if (mounted) {
        setState(() {
          _visible = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final fontSize = screenHeight < 750 ? 14.0 : 16.0;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: _visible ? 1.0 : 0.0,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.2),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icona, color: Colors.white70, size: 24),
              const SizedBox(height: 8),
              Text(
                widget.valor,
                style: TextStyle(color: Colors.white, fontSize: fontSize),
              ),
              Text(
                widget.etiqueta,
                style: TextStyle(color: Colors.white70, fontSize: fontSize - 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
