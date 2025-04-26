import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:treemate/plant/Garden_pages/plant_search_page.dart';
import 'package:treemate/main_pages/models/my_garden_model.dart';
import 'package:treemate/plant/add_plant_module/plant_detail_page.dart';

class PlantBrowsePage extends StatelessWidget {
  const PlantBrowsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PlantsModel()
        ..fetchPlantsAndCategories(), // Fetch plants and categories on initialization
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Browse Plants'),
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
        body: Consumer<PlantsModel>(
          builder: (context, plantsModel, child) {
            if (plantsModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return plantsModel.filteredPlants.isEmpty
                ? _buildEmptyPlantsUI(context)
                : _buildPlantsListWithCategories(plantsModel, context);
          },
        ),
      ),
    );
  }

  // Method to build the search bar
  // Widget _buildSearchBar(BuildContext context) {
  //   return TextField(
  //     onChanged: (value) {
  //       Provider.of<PlantsModel>(context, listen: false)
  //           .updateSearchQuery(value);
  //     },
  //     decoration: InputDecoration(
  //       hintText: 'Search for new plants',
  //       prefixIcon: const Icon(Icons.search),
  //       border: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(30),
  //       ),
  //     ),
  //   );
  // }
  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the new search page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PlantSearchPage(),
          ),
        );
      },
      child: TextField(
        enabled: false, // Disable editing here
        decoration: InputDecoration(
          hintText: 'Search for new plants',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }


  // Method to display the categories and the plant list with search functionality
  Widget _buildPlantsListWithCategories(
      PlantsModel plantsModel, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildSearchBar(context),
        ),
        _buildCategorySection(plantsModel),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("All Plants",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        Expanded(child: _buildPlantsList(plantsModel)),
      ],
    );
  }

  // Method to display the category section
  Widget _buildCategorySection(PlantsModel plantsModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text("Categories",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            height:
                120, // Adjust this value to control the height of the category section
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: plantsModel.categories.length,
              itemBuilder: (context, index) {
                final category = plantsModel.categories[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40, // Adjust the size
                        backgroundColor: Colors.grey[200],
                        backgroundImage: category.imageUrl.isNotEmpty
                            ? NetworkImage(category.imageUrl)
                            : const AssetImage(
                                    'assets/image/category_placeholder.png')
                                as ImageProvider,
                      ),
                      const SizedBox(height: 8),
                      Text(category.name, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Method to display the list of plants
  Widget _buildPlantsList(PlantsModel plantsModel) {
    return ListView.builder(
      itemCount: plantsModel.filteredPlants.length,
      itemBuilder: (context, index) {
        final plant = plantsModel.filteredPlants[index];

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
                // backgroundImage:
                //     plant.imageUrl != null && plant.imageUrl!.isNotEmpty
                backgroundImage: (plant.imageUrl != null && plant.imageUrl!.isNotEmpty)

                        ? NetworkImage(plant.imageUrl!)
                        : const AssetImage('assets/image/plant.png')
                            as ImageProvider, // Default image
              ),
              title: Text(plant.commonName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              // subtitle: Text(plant.scientificName ?? ''),
              subtitle: Text(
                plant.scientificName,
                style: const TextStyle(color: Colors.grey),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlantDetailPage(
                      plantId: plant.id,
                        //plantName: 'xxxx'
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
            'No plants available.\nTry adding a new plant!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              // TODO: Handle add plant button
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              backgroundColor: Colors.green,
            ),
            child: const Text('Add a Plant',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
