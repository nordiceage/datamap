import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//import 'package:material_symbols_icons/symbols.dart';
//import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:lottie/lottie.dart';

class WeatherApiGroup {
  static String baseUrl = 'https://weatherapi-com.p.rapidapi.com/';
  static Map<String, String> headers = {
    'x-rapidapi-key': 'd82dce32d1mshf79c3c1c81efd62p1c2421jsn9d046e182984',
    'x-rapidapi-host': 'weatherapi-com.p.rapidapi.com',
  };

  static Future<Map<String, dynamic>> getCurrentWeather(String location) async {
    final url = Uri.parse('${baseUrl}current.json?q=$location');
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}
class WeatherWidget extends StatefulWidget {
  final Map<String, dynamic> weatherData;
  final Future<void> Function()? onRefresh;

  const WeatherWidget({
    super.key,
    required this.weatherData,
    this.onRefresh,
  });

  @override
  _WeatherWidgetState createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  String _locationName = '';
  final bool _isUsingIpLocation = false;
  late Map<String, dynamic> _currentWeatherData;

  @override
  void initState() {
    super.initState();
    _currentWeatherData = widget.weatherData;
    // _getLocation();
    _locationName = _currentWeatherData['location']['name'];
  }

  Future<void> _refreshWeather() async {
    if (widget.onRefresh != null) {
      await widget.onRefresh!();
      // Update the current weather data after refresh
      setState(() {
        _currentWeatherData = widget.weatherData;
        _locationName = _currentWeatherData['location']['name'];
      });
    }
  }
  Widget getWeatherAnimation(String condition) {
    condition = condition.toLowerCase();

    if (condition.contains('sun') || condition.contains('clear')) {
      return Lottie.asset('assets/animations/sunny3.json');
    } else if (condition.contains('cloudy')) {
      return Lottie.asset('assets/animations/cloudy.json');
    } else if (condition.contains('rainy') || condition.contains('drizzle')) {
      return Lottie.asset('assets/animations/rainy.json');
    } else if (condition.contains('thunder') || condition.contains('lightning')) {
      return Lottie.asset('assets/animations/thunderstorm.json');
    } else if (condition.contains('snow') || condition.contains('sleet')) {
      return Lottie.asset('assets/animations/snow.json');
    } else if (condition.contains('mist') || condition.contains('fog')) {
      return Lottie.asset('assets/animations/weather_fog.json');
    } else {
      return Lottie.asset('assets/animations/default_weather.json');
    }
  }

  String getBackgroundImage(String condition, DateTime localTime) {
    // Determine if it is day or night based on local time
    bool isDay = localTime.hour >= 6 && localTime.hour < 18;

    // Normalize the condition
    condition = condition.toLowerCase();

    // Determine the image name based on the weather condition and time of day
    if (condition.contains('sun') || condition.contains('clear')) {
      return isDay ? 'assets/image/weather/clearday.jpeg' : 'assets/image/weather/clearnight.jpeg';
    } else if (condition.contains('cloud')) {
      return isDay ? 'assets/image/weather/cloudyday.jpeg' : 'assets/image/weather/cloudynight.jpeg';
    } else if (condition.contains('rain') || condition.contains('drizzle')) {
      return isDay ? 'assets/image/weather/rainyday.jpeg' : 'assets/image/weather/rainynight.jpeg';
    } else if (condition.contains('thunder') || condition.contains('lightning')) {
      return isDay ? 'assets/image/weather/thunderday.jpeg' : 'assets/image/weather/thundernight.jpeg';
    } else {
      // Default background
      return isDay ? 'assets/image/weather/clearday.jpeg' : 'assets/image/weather/clearnight.jpeg';
    }
  }



  String getWeatherDescriptionText(String condition) {
    condition = condition.toLowerCase();
    if (condition.contains('sun') || condition.contains('clear')) {
      return 'sunny';
    } else if (condition.contains('cloud')) {
      return 'cloudy';
    } else if (condition.contains('rain') || condition.contains('drizzle')) {
      return 'rainy';
    } else if (condition.contains('thunder') || condition.contains('lightning')) {
      return 'stormy';
    } else if (condition.contains('snow') || condition.contains('sleet')) {
      return 'snowing';
    } else if (condition.contains('mist') || condition.contains('fog')) {
      return 'misty';
    } else {
      return 'changing';
    }
  }


  @override
  Widget build(BuildContext context) {
    // final current = widget.weatherData['current'];
    // final location = widget.weatherData['location'];
    final current = _currentWeatherData['current'];
    final location = _currentWeatherData['location'];
    final weatherDescriptionText = getWeatherDescriptionText(current['condition']['text']);
    final currentCondition = current['condition']['text'];
    final localTime = DateTime.now(); // Use the user's local time
    final backgroundImage = getBackgroundImage(currentCondition, localTime);

    return Container(
      height: 194,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          // image: CachedNetworkImageProvider(
          //   'https://as1.ftcdn.net/v2/jpg/07/15/78/02/1000_F_715780292_mYbcn1aT0ZrgcXx9MORdenkPLP4qxElG.jpg',
          // ),
          image: AssetImage(backgroundImage),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 22),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${DateFormat('EEEE').format(DateTime.now())} | ${DateFormat('h:mm a').format(DateTime.now())}',
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${current['temp_c']}°C',
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(_isUsingIpLocation ? Icons.language : Icons.location_on, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _locationName.isNotEmpty ? _locationName : location['name'],
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Text(
                                current['condition']['text'],
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            // Icon(
                            //   getWeatherIcon(current['condition']['text']),
                            //   color: Colors.white,
                            //   size: 24,
                            // ),
                            SizedBox(
                              height: 24, // Adjust the size according to your needs
                              width: 24,
                              child: getWeatherAnimation(current['condition']['text']), // This plays the Lottie animation based on the weather condition
                            ),

                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    //'It seems ${current['condition']['text'].toLowerCase()} today',
                    'It seems $weatherDescriptionText today',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    'Humidity: ${current['humidity']}%',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}