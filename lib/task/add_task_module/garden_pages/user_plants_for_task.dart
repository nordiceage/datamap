import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:treemate/plant/Garden_pages/browse_plants.dart';
import 'package:treemate/plant/controllers/plant_controller.dart';
import 'package:treemate/plant/models/user_plant_model.dart';
import 'package:treemate/task/add_task_module/add_update_plant_task1.dart';

class TaskPlantBrowsePage extends StatelessWidget {
  const TaskPlantBrowsePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize PlantsController
    final PlantsController plantsController = PlantsController();
    plantsController.init(); // Initialize the API base URL or other settings

    return ChangeNotifierProvider(
      create: (_) => UserPlantsModel(plantsController)
        ..fetchUserPlants(), // Fetch user's plants on initialization
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Plants'),
          backgroundColor: Colors.transparent, // No color for app bar
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back,
                color: Colors.black), // Back icon color
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Consumer<UserPlantsModel>(
          builder: (context, userPlantsModel, child) {
            if (userPlantsModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return userPlantsModel.filteredPlants.isEmpty
                ? _buildEmptyPlantsUI(context)
                : _buildPlantsListWithSearch(userPlantsModel, context);
          },
        ),
      ),
    );
  }

  // Method to build the search bar
  Widget _buildSearchBar(BuildContext context) {
    return TextField(
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
    );
  }

  // Method to display the list of plants with search functionality
  Widget _buildPlantsListWithSearch(
      UserPlantsModel userPlantsModel, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: _buildSearchBar(context),
        ),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Select a plant",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: _buildPlantsList(userPlantsModel, context)),
      ],
    );
  }

  // Method to display the list of plants
  Widget _buildPlantsList(
      UserPlantsModel userPlantsModel, BuildContext context) {
    return ListView.builder(
      itemCount: userPlantsModel.filteredPlants.length,
      itemBuilder: (context, index) {
        final plant = userPlantsModel.filteredPlants[index];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: ListTile(
              leading: CircleAvatar(
                radius: 30, // Adjust the radius as needed
                backgroundColor: Colors.grey[200],
                backgroundImage:
                    (plant.imageUrl != null && plant.imageUrl!.isNotEmpty)
                        ? NetworkImage(plant.imageUrl!)
                        : const AssetImage('assets/image/plant.png')
                            as ImageProvider, // Default image
              ),
              title: Text(
                plant.commonName ?? 'Unknown',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                plant.scientificName ?? 'Unknown',
                style: const TextStyle(color: Colors.grey),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddTaskPage(
                      plant: plant,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Method to build the empty state UI
  Widget _buildEmptyPlantsUI(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/image/emptyPlants.png',
              height: 150), // Replace with appropriate asset
          const SizedBox(height: 20),
          const Text(
            'You don’t have any plants currently.\nFirst add a plant to start tracking.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              // Navigate to the plant browse/add page
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const PlantBrowsePage()));
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              backgroundColor: Colors.green,
            ),
            child: const Text(
              'Add a Plant',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
