import 'package:flutter/cupertino.dart';
import 'package:treemate/plant/models/plant_model.dart';
import '../controllers/plant_controller.dart'; // Import the controller

class UserPlantsModel extends ChangeNotifier {
  bool isLoading = false;
  List<PlantModel> userPlants = [];
  String? searchQuery;

  // PlantsController instance
  final PlantsController _plantsController;

  UserPlantsModel(this._plantsController);

  Future<void> fetchUserPlants() async {
    isLoading = true;
    notifyListeners();

    try {
      await _plantsController.init();
      userPlants = await _plantsController.getAllUserPlants();

      // Detailed debugging
      print('[DEBUG] Fetched Plants:');
      print('[DEBUG] Total Plants: ${userPlants.length}');

      // Debugging
      print('[DEBUG] Total Plants Fetched: ${userPlants.length}');
      for (var plant in userPlants) {
        print('[DEBUG] Plant: ${plant.commonName}, ${plant.imageUrl}');
      }
      print('[DEBUG] User Plants noted ${userPlants.length} plants');
      notifyListeners();
    } catch (e) {
      print('[ERROR] Failed to fetch plants: ${e.toString()}');
    } finally {
      isLoading = false;
      print('[DEBUG] User Plants Model notifyListeners called');
      notifyListeners();
    }
  }

  // Update search query
  void updateSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  // Filter plants based on search query
  List<PlantModel> get filteredPlants {
    if (searchQuery == null || searchQuery!.isEmpty) {
      return userPlants;
    }
    return userPlants
        .where((plant) =>
            plant.commonName
                .toLowerCase()
                .contains(searchQuery!.toLowerCase()) ||
            plant.scientificName
                .toLowerCase()
                .contains(searchQuery!.toLowerCase()))
        .toList();
  }
}
