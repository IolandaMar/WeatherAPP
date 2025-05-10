import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppDelTemps());
}

class AppDelTemps extends StatelessWidget {
  const AppDelTemps({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App del Temps',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            fontFamily: 'SF Pro',
            color: Colors.white,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
