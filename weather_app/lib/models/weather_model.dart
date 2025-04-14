class WeatherModel {
  final String icon;
  final String description;
  final String day;
  final String degree;
  final String min;
  final String max;
  final String night;
  final String humidity;

  WeatherModel({
    required this.icon,
    required this.description,
    required this.day,
    required this.degree,
    required this.min,
    required this.max,
    required this.night,
    required this.humidity,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      icon: json["icon"] ?? "",
      description: json["description"] ?? "N/A",
      day: json["day"] ?? "Unknown",
      degree: json["degree"] ?? "0",
      min: json["min"] ?? "0",
      max: json["max"] ?? "0",
      night: json["night"] ?? "0",
      humidity: json["humidity"] ?? "0",
    );
  }
}
