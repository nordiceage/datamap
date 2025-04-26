import 'package:flutter/material.dart';
import 'package:treemate/plant/controllers/plant_controller.dart';
import 'package:treemate/controllers/sites_controller.dart';
import 'package:treemate/plant/models/user_plant_model.dart';
import 'package:treemate/task/controllers/task_controller.dart';
import 'package:treemate/plant/models/plant_category_model.dart';
import 'package:treemate/models/site_model.dart';
import 'package:treemate/plant/models/plant_model.dart';

class MyGardenModel extends ChangeNotifier {
  int? selectedTab = 0;

  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;

  late TasksModel tasksModel;
  late PlantsModel plantsModel;
  late SitesModel sitesModel;
  late UserPlantsModel userPlantsModel;

  int totalPlants = 0; // To store total number of plants
  int totalSites = 0; // To store total number of sites
  int totalUserPlants = 0; // To store total number of user plants

  MyGardenModel(TickerProvider vsync) {
    tasksModel = TasksModel();
    plantsModel = PlantsModel()..fetchPlantsAndCategories();
    sitesModel = SitesModel()..fetchSites();
    userPlantsModel = UserPlantsModel(PlantsController())..fetchUserPlants();

    tabBarController = TabController(
      vsync: vsync,
      length: 3,
      initialIndex: 0,
    );

    // Add listeners to update total plants and sites when fetched
    plantsModel.addListener(() {
      totalPlants = plantsModel.plants.length;
      notifyListeners();
    });

    sitesModel.addListener(() {
      totalSites = sitesModel.sites.length;
      notifyListeners();
    });

    userPlantsModel.addListener(() {
      totalUserPlants = userPlantsModel.userPlants.length;
      print('[DEBUG] User Plants Model Listener Triggered: $totalUserPlants');
      notifyListeners();
    });
  }

  void fetchData() async {
    await plantsModel.fetchPlantsAndCategories();
    await sitesModel.fetchSites();
    await userPlantsModel.fetchUserPlants();
  }

  void setSelectedTab(int index) {
    selectedTab = index;
    notifyListeners();
  }

  @override
  void dispose() {
    tabBarController?.dispose();
    tasksModel.dispose();
    plantsModel.dispose();
    sitesModel.dispose();
    super.dispose();
  }
}

class TasksModel extends ChangeNotifier {
  List<Map<String, dynamic>> tasks = [];
  bool isLoading = false;
  final TasksController _tasksController = TasksController();

  // Fetch all tasks from the backend
  Future<void> fetchTasks() async {
    isLoading = true;
    notifyListeners();
    try {
      tasks = (await _tasksController.fetchUserTasks())
          as List<Map<String, dynamic>>;
    } catch (e) {
      tasks = [];
      // Handle errors (show a message, etc.)
    }
    isLoading = false;
    notifyListeners();
  }

  // will be added after add task logic is added
  // Add a new task
  // Future<void> addTask(String taskType, String plantId) async {
  //   try {
  //     await _tasksController.addTask(taskType, plantId);
  //     fetchTasks(); // Refresh tasks after adding a new one
  //   } catch (e) {
  //     // Handle errors (show a message, etc.)
  //   }
  // }
  // will be added after completeTask logic is added
  // Mark a task as complete
  // Future<void> completeTask(String taskId) async {
  //   try {
  //     await _tasksController.completeTask(taskId);
  //     fetchTasks(); // Refresh tasks after completing one
  //   } catch (e) {
  //     // Handle errors (show a message, etc.)
  //   }
  // }
}

class PlantsModel extends ChangeNotifier {
  List<PlantModel> _plants = [];
  List<PlantCategory> _categories = [];
  List<PlantModel> _filteredPlants = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final PlantsController _plantsController = PlantsController();

  // Getters
  List<PlantModel> get plants => _plants;
  List<PlantCategory> get categories => _categories;
  List<PlantModel> get filteredPlants => _filteredPlants;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  // Initialize API URL on model creation
  PlantsModel() {
    _plantsController.init();
  }

  // Fetch plants and categories from the backend using controller
  Future<void> fetchPlantsAndCategories({int page = 1, int limit = 10}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch plants and categories from the controller
      _plants = await _plantsController.getPlants(page: page, limit: limit);
      _categories = await _plantsController.getAllCategories();

      // Initially, filtered plants show all fetched plants
      _filteredPlants = List.from(_plants);
    } catch (e) {
      print('Error fetching plants or categories: $e');
      // Handle errors appropriately, like showing error messages in the UI
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update search query and filter plants
  void updateSearchQuery(String query) {
    _searchQuery = query;
    if (_searchQuery.isEmpty) {
      // If search query is empty, show all plants
      _filteredPlants = List.from(_plants);
    } else {
      // Filter plants by common name or scientific name
      _filteredPlants = _plants
          .where((plant) =>
              plant.commonName.toLowerCase().contains(query.toLowerCase()) ||
              plant.scientificName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }
}

class SitesModel extends ChangeNotifier {
  final SitesController _controller = SitesController();
  List<SiteModel> _sites = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<SiteModel> get sites => _sites;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  SitesModel() {
    _controller.init();
  }

  // Fetch sites from the backend
  Future<void> fetchSites() async {
    _isLoading = true;
    notifyListeners(); // Notify listeners to update UI
    try {
      _sites = await _controller
          .getDefaultPlantSites(); // Fetch sites from controller
    } catch (e) {
      print("Error fetching sites: $e");
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify listeners after loading is complete
    }
  }

  // Update search query and filter sites
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners(); // Notify listeners for UI update
  }

  // Filter sites based on search query
  List<SiteModel> get filteredSites {
    if (_searchQuery.isEmpty) return _sites; // Return all if no query
    return _sites
        .where((site) =>
            site.siteName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            site.siteType.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }
}
