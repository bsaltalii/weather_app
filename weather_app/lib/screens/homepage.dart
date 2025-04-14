import 'package:flutter/material.dart';
import 'package:weather_app/services/weatherservices.dart';
import '../models/weather_model.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  Future<String>? _locationFuture;
  List<WeatherModel> _weathers = [];
  String _city = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _locationFuture = WeatherService().getLocation();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final city = await _locationFuture!;
      final weatherData = await WeatherService().getWeatherData(city);

      setState(() {
        _weathers = weatherData;
        _city = city;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.blueGrey.shade900,
      ),
      home: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Center(
        child: Text(
          'Weekly Weather App',
          style: GoogleFonts.raleway(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      backgroundColor: Color(0xFF385170),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        _buildBackground(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCityName(),
            Expanded(child: _isLoading ? _buildLoadingIndicator() : _buildWeatherList()),
          ],
        ),
      ],
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF385170),
      ),
    );
  }

  Widget _buildCityName() {
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Center(
        child: Text(
          _city.isNotEmpty ? _city : "Loading...",
          style: GoogleFonts.raleway(
            color: Colors.white,
            fontSize: 38,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(color: Colors.white),
    );
  }

  Widget _buildWeatherList() {
    if (_weathers.isEmpty) {
      return const Center(
        child: Text(
          "Weather data not available!",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      itemCount: _weathers.length,
      itemBuilder: (context, index) {
        final weather = _weathers[index];

        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6DD5FA), Color(0xFF2980B9)],
            ),
            boxShadow: [
               BoxShadow(
                color: Colors.black45,
                blurRadius: 10,
                offset: Offset(4, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.network(weather.icon, height: 80, fit: BoxFit.cover),
              const SizedBox(height: 8),
              Text(
                weather.day,
                style: GoogleFonts.raleway(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                weather.description.toUpperCase(),
                style: GoogleFonts.raleway(
                  color: Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              _buildTemperatureRow(weather),
              const SizedBox(height: 12),
              _buildExtraInfo(weather),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTemperatureRow(WeatherModel weather) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _weatherDetail(Icons.thermostat, "${weather.degree.substring(0,2)}°C"),
        _weatherDetail(Icons.wb_sunny, "Max: ${weather.max}°C"),
        _weatherDetail(Icons.nights_stay, "Night: ${weather.night}°C"),
      ],
    );
  }

  Widget _buildExtraInfo(WeatherModel weather) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _weatherDetail(Icons.water_drop, "Humidity: ${weather.humidity}%"),
        const SizedBox(width: 20),
        _weatherDetail(Icons.ac_unit, "Min: ${weather.min}°C"),
      ],
    );
  }

  Widget _weatherDetail(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(width: 5),
        Text(
          value,
          style: GoogleFonts.raleway(color: Colors.white, fontSize: 18),
        ),
      ],
    );
  }
}
