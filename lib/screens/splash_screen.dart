import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'main_cities_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final Animation<double> _logoAnimation;

  late final AnimationController _textController;
  late final Animation<double> _textFade;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _logoAnimation = Tween<double>(begin: 0.80, end: 1.20).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    _textController.forward();
    _navegarSegonsConfiguracio();
  }

  Future<void> _navegarSegonsConfiguracio() async {
    await Future.delayed(const Duration(seconds: 4));
    final prefs = await SharedPreferences.getInstance();
    final ciutats = prefs.getStringList('ciutats');

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, __, ___) => (ciutats != null && ciutats.isNotEmpty)
            ? HomeScreen(ciutats: ciutats)
            : const MainCitiesScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF0D1B2A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _logoAnimation,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.08),
                      blurRadius: 30,
                      spreadRadius: 8,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.asset(
                    'assets/images/logo.gif',
                    width: size.width * 0.30,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            FadeTransition(
              opacity: _textFade,
              child: Column(
                children: const [
                  Text(
                    'WeatherAPP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.4,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Previsió precisa amb estil',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 17,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
