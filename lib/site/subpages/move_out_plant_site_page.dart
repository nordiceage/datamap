import 'package:flutter/material.dart';
import 'package:treemate/site/controllers/add_plant_plant_controller.dart';
import 'package:treemate/site/models/add_plant_plant_model.dart';
import 'package:treemate/site/subpages/select_site_page.dart';

class MoveOutPlantPage extends StatefulWidget {
  final String siteId;

  const MoveOutPlantPage({super.key, required this.siteId});

  @override
  _MoveOutPlantPageState createState() => _MoveOutPlantPageState();
}

class _MoveOutPlantPageState extends State<MoveOutPlantPage> {
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
        title: const Text('Move Out Plant from Site'),
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
            List<AddPlantPlantModel> sitePlants = snapshot.data!
                .where((plant) => plant.site?.id == widget.siteId)
                .toList();
            return sitePlants.isEmpty
                ? _buildEmptyPlantsUI(context)
                : RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        _plantsFuture = plantsController.getAllUserPlants();
                      });
                    },
                    child: _buildPlantsListWithSearch(context, sitePlants),
                  );
          }
        },
      ),
    );
  }

  Widget _buildSearchBar(
      BuildContext context, ValueNotifier<String> searchQuery) {
    return TextField(
      onChanged: (value) {
        searchQuery.value = value;
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
      BuildContext context, List<AddPlantPlantModel> sitePlants) {
    ValueNotifier<String> searchQuery = ValueNotifier<String>('');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: _buildSearchBar(context, searchQuery),
        ),
        Expanded(
          child: ValueListenableBuilder<String>(
            valueListenable: searchQuery,
            builder: (context, query, child) {
              List<AddPlantPlantModel> filteredPlants =
                  sitePlants.where((plant) {
                return plant.plant.commonName
                        .toLowerCase()
                        .contains(query.toLowerCase()) ??
                    false ||
                        plant.plant.scientificName
                                .toLowerCase()
                                .contains(query.toLowerCase());
              }).toList();
              return _buildPlantsList(context, filteredPlants);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPlantsList(
      BuildContext context, List<AddPlantPlantModel> plants) {
    return ListView.builder(
      itemCount: plants.length,
      itemBuilder: (context, index) {
        final plant = plants[index];
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
              await _moveOutPlant(context, plant.id);
            },
          ),
        );
      },
    );
  }

  Future<void> _moveOutPlant(BuildContext context, String plantId) async {
    final selectedSiteId = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectSitePage(currentSiteId: widget.siteId),
      ),
    );

    if (selectedSiteId == null) {
      return; // User canceled the site selection
    }

    bool confirmMoveOut = await _showMoveOutConfirmationDialog(context);
    if (!confirmMoveOut) {
      return; // User canceled the move out
    }

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    const loadingSnackBar = SnackBar(
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Moving out plant...',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      duration: Duration(seconds: 10),
    );

    scaffoldMessenger.showSnackBar(loadingSnackBar);

    try {
      AddPlantPlantsController sitesController = AddPlantPlantsController();
      await sitesController.init();

      bool success =
          await sitesController.addUserPlantToSite(plantId, selectedSiteId);

      scaffoldMessenger.hideCurrentSnackBar();

      if (success) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Successfully moved out plant to the selected site',
            ),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _plantsFuture = plantsController.getAllUserPlants();
        });
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to move out plant to the selected site',
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
  }

  Future<bool> _showMoveOutConfirmationDialog(BuildContext context) async {
    return (await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Move Out Plant'),
            content: const Text(
                'Are you sure you want to move out this plant to the selected site?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Move Out', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        )) ??
        false;
  }

  Widget _buildEmptyPlantsUI(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/image/emptyPlants.png', height: 150),
          const SizedBox(height: 20),
          const Text(
            'No plants found in this site.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
