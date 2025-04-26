
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;

// TODO: Create an API service class for handling backend requests
// class PlantApiService {
//   Future<List<Plant>> fetchPlants() async {
//     // Implement API call to fetch plants from the backend
//   }
//
//   Future<void> addPlant(Plant plant) async {
//     // Implement API call to add a new plant to the backend
//   }
//
//   Future<void> removePlant(String plantId) async {
//     // Implement API call to remove a plant from the backend
//   }
// }

class FavoritePlantsModel extends ChangeNotifier {
  final List<Plant> _plants = [];
  String _selectedFilter = 'All';
  bool _showMockData = false;

  // TODO: Inject the API service
  // final PlantApiService _apiService;
  // FavoritePlantsModel(this._apiService);

  final List<Plant> _mockPlants = [
    Plant(id: '1', name: 'Monstera Deliciosa', type: 'My Plants'),
    Plant(id: '2', name: 'Snake Plant', type: 'My Plants'),
    Plant(id: '3', name: 'Fiddle Leaf Fig', type: 'New Plants'),
    Plant(id: '4', name: 'Pothos', type: 'My Plants'),
    Plant(id: '5', name: 'ZZ Plant', type: 'New Plants'),
  ];

  List<Plant> get plants => _showMockData ? _mockPlants : _plants;
  String get selectedFilter => _selectedFilter;
  bool get showMockData => _showMockData;

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void toggleMockData() {
    _showMockData = !_showMockData;
    notifyListeners();
  }

  List<Plant> get filteredPlants {
    final plantsToFilter = _showMockData ? _mockPlants : _plants;
    if (_selectedFilter == 'All') return plantsToFilter;
    return plantsToFilter.where((plant) => plant.type == _selectedFilter).toList();
  }

// TODO: Implement methods to fetch plants from the backend
// Future<void> fetchPlants() async {
//   try {
//     _plants = await _apiService.fetchPlants();
//     notifyListeners();
//   } catch (e) {
//     // Handle error (e.g., show error message)
//   }
// }

// TODO: Implement method to add a plant to favorites
// Future<void> addPlant(Plant plant) async {
//   try {
//     await _apiService.addPlant(plant);
//     _plants.add(plant);
//     notifyListeners();
//   } catch (e) {
//     // Handle error
//   }
// }

// TODO: Implement method to remove a plant from favorites
// Future<void> removePlant(String plantId) async {
//   try {
//     await _apiService.removePlant(plantId);
//     _plants.removeWhere((plant) => plant.id == plantId);
//     notifyListeners();
//   } catch (e) {
//     // Handle error
//   }
// }
}

class Plant {
  final String id;
  final String name;
  final String type;

  Plant({required this.id, required this.name, required this.type});

// TODO: Add fromJson and toJson methods for serialization
// factory Plant.fromJson(Map<String, dynamic> json) {
//   return Plant(
//     id: json['id'],
//     name: json['name'],
//     type: json['type'],
//   );
// }
//
// Map<String, dynamic> toJson() {
//   return {
//     'id': id,
//     'name': name,
//     'type': type,
//   };
// }
}

class FavoritePlantsScreen extends StatelessWidget {
  const FavoritePlantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // TODO: Provide the API service when creating FavoritePlantsModel
      // create: (context) => FavoritePlantsModel(PlantApiService()),
      create: (context) => FavoritePlantsModel(),
      child: LoadingPage(
        child: Consumer<FavoritePlantsModel>(
          builder: (context, model, child) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: const Text(
                  'Favorite Plants',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                actions: [
                  Switch(
                    value: model.showMockData,
                    onChanged: (value) => model.toggleMockData(),
                  ),
                ],
              ),
              body: Column(
                children: [
                  FilterChips(),
                  Expanded(
                    child: model.filteredPlants.isEmpty
                        ? const NoFavoritePlants()
                        : FavoritePlantsList(plants: model.filteredPlants),
                  ),
                ],
              ),
              // TODO: Add a FloatingActionButton to add new plants
              // floatingActionButton: FloatingActionButton(
              //   onPressed: () {
              //     // Show dialog to add new plant
              //     // Call model.addPlant() when confirmed
              //   },
              //   child: Icon(Icons.add),
              // ),
            );
          },
        ),
      ),
    );
  }
}

class LoadingPage extends StatefulWidget {
  final Widget child;

  const LoadingPage({super.key, required this.child});

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  bool _isLoading = true;
  bool _hasInternet = true;
  bool _showRetry = false;

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
  }

  Future<void> _checkInternetConnection() async {
    setState(() {
      _isLoading = true;
      _showRetry = false;
    });
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        bool internetAvailable = await _checkActualInternetConnectivity();
        if (internetAvailable) {
          await Future.delayed(const Duration(seconds: 2));
          setState(() {
            _isLoading = false;
            _hasInternet = true;
          });
          // TODO: Fetch plants from backend when internet is available
          // Provider.of<FavoritePlantsModel>(context, listen: false).fetchPlants();
        } else {
          await Future.delayed(const Duration(seconds: 5));
          setState(() {
            _isLoading = false;
            _hasInternet = false;
            _showRetry = true;
          });
        }
      } else {
        await Future.delayed(const Duration(seconds: 5));
        setState(() {
          _isLoading = false;
          _hasInternet = false;
          _showRetry = true;
        });
      }
    } catch (e) {
      print("Error checking internet connection: $e");
      await Future.delayed(const Duration(seconds: 5));
      setState(() {
        _isLoading = false;
        _hasInternet = false;
        _showRetry = true;
      });
    }
  }

  Future<bool> _checkActualInternetConnectivity() async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com')).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: ShimmerLoadingPage(),
      );
    } else if (!_hasInternet && _showRetry) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text("No internet connection"),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _checkInternetConnection,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      "Retry",
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return widget.child;
    }
  }
}

class ShimmerLoadingPage extends StatelessWidget {
  const ShimmerLoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          AppBar(
            leading: const IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: null,
            ),
            title: Container(
              width: 100,
              height: 20,
              color: Colors.white,
            ),
            actions: [
              Container(
                width: 40,
                height: 20,
                margin: const EdgeInsets.only(right: 16),
                color: Colors.white,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: List.generate(3, (index) =>
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Container(
                      width: 80,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  )
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              padding: const EdgeInsets.all(10),
              itemCount: 6,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FilterChips extends StatelessWidget {
  final List<String> filters = ['All', 'My Plants', 'New Plants'];

  FilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritePlantsModel>(
      builder: (context, model, child) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: filters.map((filter) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: FilterChip(
                    label: Text(filter),
                    selected: model.selectedFilter == filter,
                    onSelected: (bool selected) {
                      if (selected) model.setFilter(filter);
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: Colors.green[100],
                    labelStyle: TextStyle(
                      color: model.selectedFilter == filter
                          ? Colors.green[800]
                          : Colors.black,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(
                        color: model.selectedFilter == filter
                            ? Colors.green
                            : Colors.grey,
                        width: 1.0,
                      ),
                    ),
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class NoFavoritePlants extends StatelessWidget {
  const NoFavoritePlants({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            "You don't have any favorite plants",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class FavoritePlantsList extends StatelessWidget {
  final List<Plant> plants;

  const FavoritePlantsList({super.key, required this.plants});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      padding: const EdgeInsets.all(10),
      itemCount: plants.length,
      itemBuilder: (context, index) {
        return PlantCard(plant: plants[index]);
      },
    );
  }
}

class PlantCard extends StatelessWidget {
  final Plant plant;

  const PlantCard({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: Image.network(
              'https://picsum.photos/seed/${plant.id}/300/200',
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plant.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  plant.type,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    // TODO: Add a long press gesture to remove the plant
    // return GestureDetector(
    //   onLongPress: () {
    //     // Show confirmation dialog
    //     // Call Provider.of<FavoritePlantsModel>(context, listen: false).removePlant(plant.id) when confirmed
    //   },
    //   child: Card(...),
    // );
  }
}

// TODO: Implement a dialog for adding new plants
// class AddPlantDialog extends StatefulWidget {
//   @override
//   _AddPlantDialogState createState() => _AddPlantDialogState();
// }
//
// class _AddPlantDialogState extends State<AddPlantDialog> {
//   // Implement form fields and validation
//   // Call Provider.of<FavoritePlantsModel>(context, listen: false).addPlant() when form is submitted
// }
