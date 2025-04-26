import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:treemate/site/controllers/add_plant_plant_controller.dart';
import 'package:treemate/site/controllers/add_plant_sites_controller.dart';
import 'package:treemate/site/models/add_plant_plant_model.dart';

class AddPlantPage extends StatefulWidget {
  final String siteId;

  const AddPlantPage({super.key, required this.siteId});

  @override
  _AddPlantPageState createState() => _AddPlantPageState();
}

class _AddPlantPageState extends State<AddPlantPage> {
  final AddPlantPlantsController plantsController = AddPlantPlantsController();
  late Future<List<AddPlantPlantModel>> _plantsFuture;

  @override
  void initState() {
    super.initState();
    plantsController.init();
    _plantsFuture = plantsController.getAllUserPlants();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Plant to Site'),
      ),
      body: FutureBuilder<List<AddPlantPlantModel>>(
        future: _plantsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyPlantsUI(context);
          } else {
            List<AddPlantPlantModel> availablePlants = snapshot.data!
                .where((plant) => plant.site?.id != widget.siteId)
                .toList();
            return availablePlants.isEmpty
                ? _buildEmptyPlantsUI(context)
                : ChangeNotifierProvider(
                    create: (_) => UserPlantsModel(availablePlants, plantsController),
                    child: Consumer<UserPlantsModel>(
                      builder: (context, userPlantsModel, child) {
                        return _buildPlantsListWithSearch(userPlantsModel, context);
                      },
                    ),
                  );
          }
        },
      ),
    );
  }

  // Method to build the search bar
  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        onChanged: (value) {
          Provider.of<UserPlantsModel>(context, listen: false)
              .updateSearchQuery(value);
        },
        decoration: InputDecoration(
          hintText: 'Search for your plants',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
    );
  }

  // Method to build the list of plants with search functionality
  Widget _buildPlantsListWithSearch(
      UserPlantsModel userPlantsModel, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchBar(context),
        Expanded(child: _buildPlantsList(userPlantsModel)),
      ],
    );
  }

  // Method to build the list of plants
  Widget _buildPlantsList(UserPlantsModel userPlantsModel) {
    return ListView.builder(
      itemCount: userPlantsModel.filteredPlants.length,
      itemBuilder: (context, index) {
        final plant = userPlantsModel.filteredPlants[index];

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[200],
              backgroundImage: (plant.plant.plantImage.isNotEmpty)
                  ? NetworkImage(plant.plant.plantImage)
                  : const AssetImage('assets/image/plant.png') as ImageProvider,
            ),
            title: Text(
              plant.plant.commonName ?? 'Unknown',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              plant.plant.scientificName ?? 'Unknown',
              style: const TextStyle(color: Colors.grey),
            ),
            onTap: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final loadingSnackBar = SnackBar(
                content: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Adding "${plant.plant.commonName}" to site...',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                duration: const Duration(seconds: 10),
              );

              scaffoldMessenger.showSnackBar(loadingSnackBar);

              try {
                // Initialize SitesController
                AddPlantSitesController sitesController = AddPlantSitesController();
                await sitesController.init();

                // Make the API call
                bool success =
                await plantsController.addUserPlantToSite(plant.id, widget.siteId);

                scaffoldMessenger.hideCurrentSnackBar();

                if (success) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        'Successfully added "${plant.plant.commonName}" to site ${widget.siteId}',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        'Failed to add "${plant.plant.commonName}" to site ${widget.siteId}',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                scaffoldMessenger.hideCurrentSnackBar();
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('An error occurred: $e'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }

  // Method to display the empty state
  Widget _buildEmptyPlantsUI(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/image/emptyPlants.png', height: 150),
          const SizedBox(height: 20),
          const Text(
            'You don’t have any plants currently \nthat are not there in this site.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class UserPlantsModel extends ChangeNotifier {
  List<AddPlantPlantModel> userPlants;
  List<AddPlantPlantModel> filteredPlants;
  final AddPlantPlantsController plantsController;
  String _searchQuery = '';

  UserPlantsModel(this.userPlants,this.plantsController)
      : filteredPlants = List.from(userPlants);

  void updateSearchQuery(String query) {
    _searchQuery = query;
    _filterPlants();
    notifyListeners();
  }

  void _filterPlants() {
    if (_searchQuery.isEmpty) {
      filteredPlants = List.from(userPlants);
    } else {
      filteredPlants = userPlants
          .where((plant) =>
      (plant.plant.commonName.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (plant.plant.scientificName.toLowerCase().contains(_searchQuery.toLowerCase())?? false))
          .toList();
    }
  }
}