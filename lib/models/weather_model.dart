class Weather {
  final String ciutat;
  final double temperatura;
  final String descripcio;
  final String icona;
  final int humitat;
  final int pressio;
  final double ventVelocitat;
  final int windDeg;
  final int visibilitat;
  final double sensacioTermica;
  final DateTime sortidaSol;
  final DateTime postaSol;
  double latitud;
  double longitud;

  Weather({
    required this.ciutat,
    required this.temperatura,
    required this.descripcio,
    required this.icona,
    required this.humitat,
    required this.pressio,
    required this.ventVelocitat,
    required this.windDeg,
    required this.visibilitat,
    required this.sensacioTermica,
    required this.sortidaSol,
    required this.postaSol,
    required this.latitud,
    required this.longitud,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      ciutat: json['name'],
      temperatura: json['main']['temp'].toDouble(),
      descripcio: json['weather'][0]['description'],
      icona: json['weather'][0]['icon'],
      humitat: json['main']['humidity'],
      pressio: json['main']['pressure'],
      ventVelocitat: json['wind']['speed'].toDouble(),
      windDeg: json['wind']['deg'],
      visibilitat: json['visibility'],
      sensacioTermica: json['main']['feels_like'].toDouble(),
      sortidaSol: DateTime.fromMillisecondsSinceEpoch(json['sys']['sunrise'] * 1000),
      postaSol: DateTime.fromMillisecondsSinceEpoch(json['sys']['sunset'] * 1000),
      latitud: json['coord']['lat'].toDouble(),
      longitud: json['coord']['lon'].toDouble(),
    );
  }
}
