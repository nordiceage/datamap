import 'package:flutter/material.dart';
import 'package:treemate/site/controllers/add_plant_sites_controller.dart';
import 'package:treemate/site/models/add_plant_site_model.dart';

class SelectSitePage extends StatefulWidget {
  final String currentSiteId;

  const SelectSitePage({super.key, required this.currentSiteId});

  @override
  _SelectSitePageState createState() => _SelectSitePageState();
}

class _SelectSitePageState extends State<SelectSitePage> {
  final AddPlantSitesController sitesController = AddPlantSitesController();
  late Future<List<AddPlantSiteModel>> _sitesFuture;

  @override
  void initState() {
    super.initState();
    sitesController.init();
    _sitesFuture = sitesController.getSitesForUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Site'),
      ),
      body: FutureBuilder<List<AddPlantSiteModel>>(
        future: _sitesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No sites available.'));
          } else {
            List<AddPlantSiteModel> availableSites = snapshot.data!
                .where((site) => site.id != widget.currentSiteId)
                .toList();
            return ListView.builder(
              itemCount: availableSites.length,
              itemBuilder: (context, index) {
                final site = availableSites[index];
                return ListTile(
                  title: Text(site.siteName),
                  subtitle: Text(site.siteType),
                  onTap: () {
                    Navigator.pop(context, site.id);
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
