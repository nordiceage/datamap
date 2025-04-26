import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:treemate/plant/Garden_pages/browse_plants.dart';
import 'package:treemate/plant/subpages/fav_plant_page.dart';
import 'package:treemate/task/subpages/task_home_page.dart';
import 'package:treemate/widgets/error_weather_widget.dart';
import '../ai_module/ai_popup_module.dart';
import '../shared_pages/saved_page.dart';
import '../theme.dart';
import '../widgets/weather_home_widget.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shimmer/shimmer.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _hasNotifications = true;
  late String _greeting;
  Map<String, dynamic>? _weatherData;
  bool _isLoadingWeather = true;
  final _scrollController = ScrollController();
  final GlobalKey<TasksPageState> _tasksPageKey = GlobalKey<TasksPageState>();

  @override
  void initState() {
    super.initState();
    _greeting = _getGreeting();
    _loadWeatherData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else if (hour < 20) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _showLocationSettingsDialog();
      if (!serviceEnabled) {
        return false;
      }
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackBar('Location permissions are denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackBar('Location permissions are permanently denied, we cannot request permissions.');
      return false;
    }
    return true;
  }


  Future<bool> _showLocationSettingsDialog() async {
    return await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Location Services Disabled'),
            content: const Text(
                'Location services are disabled. Please enable the services to use this feature.'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: const Text('Open Settings'),
                onPressed: () async {
                  await Geolocator.openLocationSettings();
                  Navigator.of(context).pop(await Geolocator.isLocationServiceEnabled());
                },
              ),
            ],
          );
        })?? false;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _loadWeatherData() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    setState(() {
      _isLoadingWeather = true;
    });
    try {
      Position position = await Geolocator.getCurrentPosition();
      final weatherData = await WeatherApiGroup.getCurrentWeather('${position.latitude},${position.longitude}');
      setState(() {
        _weatherData = weatherData;
        _isLoadingWeather = false;
      });
    } catch (e) {
      print("Error loading weather data: $e");
      setState(() {
        _isLoadingWeather = false;
        _weatherData = null;
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoadingWeather = true;
    });
    await _loadWeatherData();
    setState(() {
      _isLoadingWeather = false;
    });
    if(_tasksPageKey.currentState != null) {
      _tasksPageKey.currentState!.fetchTasks();
    }
  }

  void _toggleNotifications() {
    setState(() {
      _hasNotifications = !_hasNotifications;
    });
  }

  Widget _buildAnimatedFAB() {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => const AIPopupModule(),
        );
      },
      backgroundColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child:  Lottie.asset(
          'assets/animations/Flow82.json',
          width: 200,
          height: 200,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _buildAnimatedFAB(),
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _greeting,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Symbols.favorite, size: 24),
                    onPressed: () => _navigateToPage(context, const FavoritePlantsScreen()),
                  ),
                  IconButton(
                    icon: const Icon(Symbols.bookmark, size: 24),
                    onPressed: () => _navigateToPage(context, const SavedPage()),
                  ),
                  //todo: notification page not available yet
                  // IconButton(
                  //   icon: const Icon(Symbols.notifications, size: 24),
                  //   onPressed: () => _navigateToPage(context, NotificationsPage()),
                  // ),
                  //todo for now:
                  IconButton(
                    icon: const Icon(Symbols.notifications, size: 24),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Coming Soon!', style: TextStyle(color: Colors.white),),
                          backgroundColor: Colors.black87,
                        ),
                      );
                    },
                  ),
                ],
              )
            ],
          ),
        ),
        bottom:  PreferredSize(
          preferredSize: const Size.fromHeight(70.0),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12.0,left: 16.0, right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PlantBrowsePage(),
                  ),
                );
              },
              child: TextField(
                enabled: false,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  hintText: 'Search for plants',
                  hintStyle: Theme.of(context).textTheme.titleMedium,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(40.0)),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          child: Padding(
            padding: AppTheme.defaultPadding_sides,
            child: Column(
              children: [
                const SizedBox(height: 28),
                _isLoadingWeather
                    ? Center(
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      height: 194,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                )
                    : _weatherData != null
                    ? WeatherWidget(
                  weatherData: _weatherData!,
                  onRefresh: _loadWeatherData,
                )
                    : const ErrorWeatherWidget(),
                const SizedBox(height: 28),
                TasksPage(key: _tasksPageKey),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }


  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}