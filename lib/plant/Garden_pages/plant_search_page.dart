import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:treemate/main_pages/models/my_garden_model.dart';
import 'package:treemate/plant/add_plant_module/plant_detail_page.dart';

class PlantSearchPage extends StatelessWidget {
  const PlantSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PlantsModel()..fetchPlantsAndCategories(), // Fetch initial data
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Search Plants'),
          backgroundColor: Colors.green,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context); // Go back to the previous page
            },
          ),
        ),
        body: Consumer<PlantsModel>(
          builder: (context, plantsModel, child) {
            return Column(
              children: [
                // Search bar at the top
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: (value) {
                      plantsModel.updateSearchQuery(value); // Update search query
                    },
                    decoration: InputDecoration(
                      hintText: 'Search plants by name',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                // Display filtered plants
                Expanded(
                  child: plantsModel.filteredPlants.isEmpty
                      ? const Center(
                    child: Text(
                      'No plants found',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                      : ListView.builder(
                    itemCount: plantsModel.filteredPlants.length,
                    itemBuilder: (context, index) {
                      final plant = plantsModel.filteredPlants[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: plant.imageUrl != null && plant.imageUrl!.isNotEmpty
                              ? NetworkImage(plant.imageUrl!)
                              : const AssetImage('assets/image/plant.png') as ImageProvider,
                        ),
                        title: Text(plant.commonName),
                        subtitle: Text(plant.scientificName),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlantDetailPage(plantId: plant.id), // Adjust accordingly
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
