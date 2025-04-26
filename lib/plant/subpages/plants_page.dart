import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:treemate/plant/Garden_pages/browse_plants.dart';
import 'package:treemate/plant/controllers/plant_controller.dart';
import 'package:treemate/plant/models/user_plant_model.dart';
//import 'package:treemate/models/my_garden_model.dart';
import 'package:treemate/plant/plant_profile_module/plant_info.dart';

class PlantsPage extends StatelessWidget {
  final PlantsController plantsController =
      PlantsController(); // Initialize controller

  PlantsPage({super.key}) {
    plantsController.init(); // Initialize the API base URL
  }
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          // PlantsModel()..fetchPlantsAndCategories(), // Fetch plants on initialization
          UserPlantsModel(plantsController)
            ..fetchUserPlants(), // Fetch user's plants
      child: Scaffold(
        body: Consumer<UserPlantsModel>(
          builder: (context, UserPlantsModel, child) {
            if (UserPlantsModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return UserPlantsModel.userPlants.isEmpty
                ? _buildEmptyPlantsUI(context)
                : _buildPlantsListWithSearch(UserPlantsModel, context);
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

  Widget _buildPlantsListWithSearch(
      UserPlantsModel userPlantsM, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: _buildSearchBar(context),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("My Plants"),
            ),
          ],
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await userPlantsM.fetchUserPlants();
            },
            child: _buildPlantsList(userPlantsM),
          ),
        ),
      ],
    );
  }

  // Method to display the list of plants
  Widget _buildPlantsList(UserPlantsModel UserPlantsModel) {
    return ListView.builder(
      itemCount: UserPlantsModel.filteredPlants.length,
      itemBuilder: (context, index) {
        // double height = MediaQuery.of(context).size.height;
        // double width = MediaQuery.of(context).size.width;
        final plant = UserPlantsModel.filteredPlants[index];

        print('Plant Details:');
        print('Common Name: ${plant.commonName}');
        print('Scientific Name: ${plant.scientificName}');
        print('Image URL: ${plant.imageUrl}');

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            // leading: Container(
            //   width: width * 0.2,
            //   child: plant.imageUrl != null
            //       ? Image.network(fit: BoxFit.cover, plant.imageUrl!)
            //       : Image.asset('assets/image/plant.png'),
            // ),
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[200],
              backgroundImage: (plant.imageUrl != null &&
                      plant.imageUrl!.isNotEmpty)
                  ? NetworkImage(plant.imageUrl!)
                  : const AssetImage('assets/image/plant.png') as ImageProvider,
            ),
            title: Text(
              plant.commonName ?? 'Unknown',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              plant.scientificName ?? 'Unknown',
              style: const TextStyle(color: Colors.grey),
            ),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlantInfoPage(plant: plant),
                ),
              );
              // Trigger a refresh when returning to the PlantsPage
              UserPlantsModel.fetchUserPlants();
            },
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
              // TODO: Handle add plant button
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
