import 'dart:convert';

import 'package:http/http.dart' as http;

class WeatherReading {
  const WeatherReading({
    required this.temperature,
    required this.humidity,
    required this.precipitation,
    required this.weatherCode,
    required this.time,
  });

  final double temperature;
  final int humidity;
  final double precipitation;
  final int weatherCode;
  final String time;

  String get conditionLabel {
    if (precipitation > 0) return 'Rain expected';
    if (weatherCode == 0) return 'Clear sky';
    if (weatherCode <= 3) return 'Partly cloudy';
    if (weatherCode >= 45 && weatherCode <= 48) return 'Foggy';
    if (weatherCode >= 51 && weatherCode <= 67) return 'Drizzle';
    if (weatherCode >= 71 && weatherCode <= 77) return 'Snow';
    if (weatherCode >= 80 && weatherCode <= 82) return 'Rain showers';
    if (weatherCode >= 95) return 'Thunderstorm';
    return 'Mixed weather';
  }

  String get plantAdvice {
    if (precipitation > 2) {
      return 'Rain is likely. Outdoor plants may need less watering today.';
    }

    if (temperature >= 28) {
      return 'Warm day. Check tropical plants and soil moisture more often.';
    }

    if (temperature <= 8) {
      return 'Cool day. Avoid overwatering and protect sensitive plants.';
    }

    if (humidity < 35) {
      return 'Air is dry. Mist humidity-loving plants if needed.';
    }

    return 'Balanced conditions. Follow your normal care schedule.';
  }
}

class WeatherService {
  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<WeatherReading> getWeather(double latitude, double longitude) async {
    final uri = Uri.parse('https://api.open-meteo.com/v1/forecast').replace(
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current':
            'temperature_2m,relative_humidity_2m,precipitation,weather_code',
        'timezone': 'auto',
      },
    );

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Weather request failed with status ${response.statusCode}.');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Unexpected weather response format.');
    }

    final current = decoded['current'];

    if (current is! Map<String, dynamic>) {
      throw const FormatException('Missing current weather data.');
    }

    return WeatherReading(
      temperature: (current['temperature_2m'] as num).toDouble(),
      humidity: (current['relative_humidity_2m'] as num).round(),
      precipitation: (current['precipitation'] as num).toDouble(),
      weatherCode: (current['weather_code'] as num).round(),
      time: current['time']?.toString() ?? '',
    );
  }

  void close() {
    _client.close();
  }
}