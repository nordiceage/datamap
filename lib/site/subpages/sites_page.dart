import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:treemate/site/controllers/add_plant_plant_controller.dart';
import 'package:treemate/site/controllers/add_plant_sites_controller.dart';
import 'package:treemate/site/models/add_plant_plant_model.dart';
import 'package:treemate/site/models/add_plant_site_model.dart';
import 'package:treemate/site/site_module/add_new_site_page.dart';
import 'package:treemate/site/subpages/add_plant_site_page.dart';
import 'package:treemate/site/subpages/move_out_plant_site_page.dart';

class SitesPage extends StatefulWidget {
  const SitesPage({super.key});

  @override
  _SitesPageState createState() => _SitesPageState();
}

class _SitesPageState extends State<SitesPage> {
  final AddPlantSitesController _sitesController = AddPlantSitesController();
  final AddPlantPlantsController _plantsController = AddPlantPlantsController();
  Timer? _debounce;
  bool _isLoading = false;
  String _searchQuery = '';
  String selectedFilter = 'All';

  List<AddPlantSiteModel> _sites = [];
  List<AddPlantSiteModel> _filteredSites = [];
  List<AddPlantPlantModel> _allPlants = [];

  // Initialize filterOptions as an empty list; 'All' will be added dynamically
  List<String> filterOptions = ['All'];

  @override
  void initState() {
    super.initState();
    _initializeControllerAndFetchData();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _initializeControllerAndFetchData() async {
    try {
      await _sitesController.init();
      await _plantsController.init();
      await _fetchData();
    } catch (e) {
      print('Initialization error: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to initialize controllers.')),
      );
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      List<AddPlantSiteModel> sites = await _sitesController.getSitesForUser();
      List<AddPlantPlantModel> plants =
          await _plantsController.getAllUserPlants();
      setState(() {
        _sites = sites;
        _allPlants = plants;
        _updateFilterOptions(); // Update filter options based on fetched sites
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to load data. Please try again later.')),
      );
    }
  }

  /// Extracts unique site types from the fetched sites and updates filterOptions
  void _updateFilterOptions() {
    // Extract unique site types
    Set<String> uniqueSiteTypes = _sites.map((site) => site.siteType).toSet();

    // Update filterOptions, ensuring 'All' is always the first option
    setState(() {
      filterOptions = ['All', ...uniqueSiteTypes];
      // Reset selectedFilter to 'All' to include any new filters
      if (!filterOptions.contains(selectedFilter)) {
        selectedFilter = 'All';
      }
    });
  }

  void _applyFilters() {
    List<AddPlantSiteModel> tempSites = List.from(_sites);

    // Apply filter chips
    if (selectedFilter != 'All') {
      tempSites = tempSites
          .where((site) =>
              site.siteType.toLowerCase() == selectedFilter.toLowerCase())
          .toList();
    }

    // Apply search query
    if (_searchQuery.isNotEmpty) {
      tempSites = tempSites
          .where((site) =>
              site.siteName.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    setState(() {
      _filteredSites = tempSites;
    });
  }

  void _updateSearchQuery(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = query;
        _applyFilters();
      });
    });
  }

  Future<void> _deleteSite(String siteId) async {
    bool confirmDelete = await _showDeleteConfirmationDialog();
    if (!confirmDelete) return;

    setState(() {
      _isLoading = true;
    });

    try {
      bool success = await _sitesController.deletePlantSite(siteId);

      if (success) {
        await _fetchData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Site deleted successfully.')),
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete the site.')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('An error occurred while deleting the site.')),
      );
    }
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return (await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Site'),
            content: const Text('Are you sure you want to delete this site?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child:
                    const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredSites.isEmpty
              ? _buildEmptySitesUI()
              : _buildSitesList(),
    );
  }

  Widget _buildSitesList() {
    return Column(
      children: [
        _buildFilterChips(),
        _buildSearchBar(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _fetchData,
            child: ListView.builder(
              itemCount: _filteredSites.length,
              itemBuilder: (context, index) {
                final site = _filteredSites[index];
                return _buildSiteCard(site);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: filterOptions.map((label) => _buildChip(label)).toList(),
      ),
    );
  }

  Widget _buildChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: selectedFilter == label,
        selectedColor: Colors.green[100],
        onSelected: (selected) {
          setState(() {
            selectedFilter = label;
            _applyFilters();
          });
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: 'Search Sites',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
          prefixIcon: const Icon(Icons.search),
        ),
        onChanged: _updateSearchQuery,
      ),
    );
  }

  Widget _buildSiteCard(AddPlantSiteModel site) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Less rounded corners
        ),
        elevation: 4,
        child: InkWell(
          // Wrap with InkWell to make entire card clickable
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SiteDetailPage(
                    site: site,
                    sitesController: _sitesController,
                    allPlants: _allPlants,
                    refreshData: _fetchData),
              ),
            ).then((_) => _fetchData());
          },
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Site Image
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(8)),
                    child: site.siteImage != null && site.siteImage!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: site.siteImage!,
                            height: 120, // Slightly adjusted height
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const SizedBox(
                              height: 120,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 120,
                              color: Colors.grey[200],
                              child: const Icon(Icons.error,
                                  color: Colors.red, size: 40),
                            ),
                          )
                        : Image.asset(
                            'assets/image/defaultSiteImage.png',
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                  ),
                  // Site Details
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          site.siteName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          site.siteType,
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_getPlantCountForSite(site.id)} Plants',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                right: 8,
                top: 8,
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await _deleteSite(site.id);
                  },
                  tooltip: 'Delete Site',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _getPlantCountForSite(String siteId) {
    return _allPlants.where((plant) => plant.site?.id == siteId).length;
  }

  Widget _buildEmptySitesUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/image/emptySites.png', height: 150),
            const SizedBox(height: 20),
            const Text(
              'You don’t have any sites currently.\nFirst add a site to manage.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddNewSitePage()),
                );
                await _fetchData();
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                backgroundColor: Colors.green,
              ),
              child: const Text(
                'Add a Site',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SiteDetailPage extends StatelessWidget {
  final AddPlantSiteModel site;
  final AddPlantSitesController sitesController;
  final List<AddPlantPlantModel> allPlants;
  final Future<void> Function() refreshData;

  const SiteDetailPage({
    super.key,
    required this.site,
    required this.sitesController,
    required this.allPlants,
    required this.refreshData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(site.siteName),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Add Plant') {
                // Handle Add Plant
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddPlantPage(siteId: site.id)),
                ).then((_) {
                  refreshData();
                });
              } else if (value == 'Move out Plant') {
                // Handle Move out Plant
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MoveOutPlantPage(siteId: site.id)),
                ).then((_) {
                  refreshData();
                });
              } else if (value == 'Delete Site') {
                _showDeleteConfirmationDialog(context, site.id);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Add Plant',
                child: Text('Add Plant'),
              ),
              const PopupMenuItem<String>(
                value: 'Move out Plant',
                child: Text('Move out Plant'),
              ),
              const PopupMenuItem<String>(
                value: 'Delete Site',
                child: Text('Delete Site'),
              ),
            ],
          ),
        ],
      ),
      body: SiteDetailContent(
          site: site, allPlants: allPlants, refreshData: refreshData),
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, String siteId) async {
    bool confirmDelete = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Site'),
            content: const Text('Are you sure you want to delete this site?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child:
                    const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmDelete) {
      try {
        bool success = await sitesController.deletePlantSite(siteId);
        if (success) {
          Navigator.pop(context); // Go back to the previous screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Site deleted successfully.')),
          );
          refreshData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Unable to delete, Site is not empty')),
          );
        }
      } catch (e) {
        print('Error deleting site: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('An error occurred while deleting the site.')),
        );
      }
    }
  }
}

class SiteDetailContent extends StatefulWidget {
  final AddPlantSiteModel site;
  final List<AddPlantPlantModel> allPlants;
  final Future<void> Function() refreshData;

  const SiteDetailContent({
    super.key,
    required this.site,
    required this.allPlants,
    required this.refreshData,
  });

  @override
  _SiteDetailContentState createState() => _SiteDetailContentState();
}

class _SiteDetailContentState extends State<SiteDetailContent> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    List<AddPlantPlantModel> sitePlants = widget.allPlants
        .where((plant) => plant.site?.id == widget.site.id)
        .toList();
    List<AddPlantPlantModel> filteredPlants = sitePlants.where((plant) {
      return plant.plant.commonName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ??
          false ||
              plant.plant.scientificName
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase());
    }).toList();

    return RefreshIndicator(
      onRefresh: widget.refreshData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            widget.site.siteImage != null && widget.site.siteImage!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: widget.site.siteImage!,
                    height: 200,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 200,
                      color: Colors.grey[200],
                      child:
                          const Icon(Icons.error, color: Colors.red, size: 40),
                    ),
                  )
                : Image.asset(
                    'assets/image/emptysite.png',
                    height: 200,
                    fit: BoxFit.cover,
                  ),
            const SizedBox(height: 16),
            Text(
              widget.site.siteName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.site.siteType,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${sitePlants.length} Plants',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 16),
            filteredPlants.isEmpty
                ? _buildEmptyPlantsUI()
                : _buildPlantsList(filteredPlants),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search for plants in this site',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
    );
  }

  Widget _buildPlantsList(List<AddPlantPlantModel> plants) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
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
          ),
        );
      },
    );
  }

  Widget _buildEmptyPlantsUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/image/emptyPlants.png', height: 150),
          const SizedBox(height: 20),
          const Text(
            'You don’t have any plants currently.\nFirst add a plant to start tracking.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
