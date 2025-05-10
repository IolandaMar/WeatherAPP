# WeatherAPP

WeatherAPP és una aplicació mòbil desenvolupada amb Flutter que proporciona informació meteorològica precisa i detallada mitjançant una interfície moderna i intuïtiva. El projecte està dissenyat amb una estètica elegant i minimalista, mantenint una gran usabilitat i rendiment.

## Característiques

- Geolocalització automàtica per detectar la ciutat actual de l'usuari.
- Informació meteorològica completa per ciutat:
  - Temperatura actual
  - Humitat
  - Velocitat del vent
  - Índex UV
  - Pressió atmosfèrica
- Gràfiques interactives per veure la previsió horària.
- Pantalla d'astronomia amb:
  - Fase lunar (traduïda al català i amb símbols visuals)
  - Altura solar i lunar
  - Signe del zodíac actual segons la data
- Radar meteorològic interactiu integrat amb Windy.com.
- Gestió de ciutats preferides amb suport de memòria persistent (`SharedPreferences`).
- Splash screen animada amb transicions suaus.

## APIs Utilitzades

- [ipgeolocation.io](https://ipgeolocation.io): per dades astronòmiques (requereix `apiKey`)
- [Open-Meteo](https://open-meteo.com): per a la previsió meteorològica
- [Geolocator](https://pub.dev/packages/geolocator): per accedir a la ubicació GPS
- [Geocoding](https://pub.dev/packages/geocoding): per traduir coordenades a noms de ciutat

## Requisits

- Flutter SDK 3.7.2 o superior
- Android minSdkVersion 21
- Connexió a Internet

## Instal·lació

1. Clona aquest repositori:

   ```bash
   git clone https://github.com/IolandaMar/WeatherAPP.git
   cd WeatherAPP
   ```

2. Instal·la les dependències:

   ```bash
   flutter pub get
   ```

3. Executa el projecte:

   ```bash
   flutter run
   ```

4. Si cal, genera la icona de l'app:

   ```bash
   flutter pub run flutter_launcher_icons:main
   ```

5. Assegura’t d’afegir la teva clau d'API (`apiKey`) d'ipgeolocation.io al fitxer `astronomy_screen.dart`.

## Estructura del Projecte

```
lib/
├── main.dart
├── splash_screen.dart
├── home_screen.dart
├── city_detail_screen.dart
├── astronomy_screen.dart
├── radar_screen.dart
├── main_cities_screen.dart
├── widgets/
│   ├── animated_gauge_tile.dart
│   └── ...
├── utils/
│   └── constants.dart
assets/
├── images/
├── icons/
```

## Autoria

Desenvolupat per [Iolanda Martínez] (https://github.com/IolandaMar), Iman Idrissi i Joel Espinosa com a projecte de demostració de Flutter amb focus en disseny visual, arquitectura modular i integració d'APIs externes.

## Llicència

Aquest projecte és lliure per a ús educatiu i personal. Per a altres usos, consulta amb l'autora.
