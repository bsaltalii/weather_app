import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/models/weather_model.dart';

class WeatherService {
  Future<String> getLocation() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception("Location service is disabled!");
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception("Location permission denied!");
        }
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        throw Exception("No location found!");
      }

      String? city = placemarks.first.locality;
      String? subAdmin = placemarks.first.subAdministrativeArea;
      String? adminArea = placemarks.first.administrativeArea;

      if (city == null || city.isEmpty) {
        city = subAdmin;
      }
      if (city == null || city.isEmpty) {
        city = adminArea;
      }
      if (city == null || city.isEmpty) {
        throw Exception("Could not determine city!");
      }

      return city;
    } catch (e) {
      return "Unknown";
    }
  }


  Future<List<WeatherModel>> getWeatherData(String city) async {
    try {
      if (city.isEmpty || city == "Unknown") {
        throw Exception("Invalid city name!");
      }

      final formattedCity = city.toLowerCase().replaceAll(" ", "%20");

      final String url =
          "https://api.collectapi.com/weather/getWeather?data.lang=tr&data.city=$formattedCity";

      const Map<String, String> headers = {
        "authorization": "apikey 3JKEoKvrkuH2p1TKhnVqBk:5nSs7mWuBtnkfVdtfKaHNF",
        "content-type": "application/json"
      };

      final dio = Dio();
      final response = await dio.get(url, options: Options(headers: headers));

      if (response.statusCode != 200 || response.data == null) {
        throw Exception("Failed to load weather data. Status code: ${response.statusCode}");
      }

      if (response.data["success"] == false) {
        throw Exception("API Error: ${response.data["message"]}");
      }

      final List<dynamic>? list = response.data["result"];

      if (list == null || list.isEmpty) {
        throw Exception("Weather data is empty or API response format changed.");
      }

      return list.map((e) => WeatherModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }
}
