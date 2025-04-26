import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:treemate/plant/add_plant_module/plant_detail_page.dart';
import 'package:treemate/plant/plant_profile_module/plant_home_part.dart';
import 'package:treemate/plant/plant_profile_module/plant_task_part.dart';
import 'package:treemate/plant/plant_profile_module/progress_update_part.dart';
import 'package:treemate/plant/plant_profile_module/report_page.dart';
import 'package:treemate/plant/models/plant_model.dart';
import 'package:treemate/task/models/usertaskmodel.dart';

import '../../task/controllers/task_controller.dart';
import '../../plant/controllers/plant_controller.dart';

class PlantInfoPage extends StatefulWidget {
  final PlantModel plant;

  const PlantInfoPage({super.key, required this.plant});

  @override
  State<PlantInfoPage> createState() => _PlantInfoPageState();
}

class FAQItem {
  final String question;
  final String answer;
  bool isExpanded;

  FAQItem({
    required this.question,
    required this.answer,
    this.isExpanded = false,
  });
}

class _PlantInfoPageState extends State<PlantInfoPage>
    with SingleTickerProviderStateMixin {
  final PageController _imagePageController = PageController();
  late TabController _tabController;
  final TasksController _tasksController = TasksController();
  final PlantsController _plantsController = PlantsController();
  List<UserTaskModel> _tasks = [];
  bool _isLoading = true;

  final GlobalKey _plantCareKey = GlobalKey();
  final GlobalKey _characteristicsKey = GlobalKey();
  final GlobalKey _faqKey = GlobalKey();
  final Map<PlantCareSection, bool> _expandedSections = {
    PlantCareSection.waterAndMisting: false,
    PlantCareSection.siteLightAndTemperature: false,
    PlantCareSection.fertilizer: false,
    PlantCareSection.potAndSoil: false,
  };
  bool _isCharacteristicsExpanded = false;

  final List<FAQItem> _faqItems = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeFAQItems();
    _fetchTasks();
  }

  void _initializeFAQItems() {
    if (widget.plant.difficultyLevel != null) {
      _faqItems.add(FAQItem(
        question: "Is this tree/plant easy to grow?",
        answer: widget.plant.difficultyLevel!,
      ));
    }
    if (widget.plant.growthRate != null) {
      _faqItems.add(FAQItem(
        question: "How fast does this tree/plant grow?",
        answer: widget.plant.growthRate!,
      ));
    }
    if (widget.plant.siteType != null) {
      _faqItems.add(FAQItem(
        question: "Can I plant this outside?",
        answer: widget.plant.siteType!,
      ));
    }
    if (widget.plant.commonPests != null) {
      _faqItems.add(FAQItem(
        question: "What are the common pests?",
        answer: widget.plant.commonPests!,
      ));
    }
    if (widget.plant.suitableTemperature != null) {
      _faqItems.add(FAQItem(
        question: "What is the suitable temperature?",
        answer: widget.plant.suitableTemperature!,
      ));
    }
    if (widget.plant.commonProblemsOrDiseases != null) {
      _faqItems.add(FAQItem(
        question: "What are the common problems or diseases?",
        answer: widget.plant.commonProblemsOrDiseases!,
      ));
    }
  }

  Future<void> _fetchTasks() async {
    setState(() {
      _isLoading = true;
    });
    await _tasksController.ensureInitialized();
    _tasks = await _tasksController.getTaskByUserPlant(widget.plant.id);
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _removePlant() async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to remove this plant?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        await _plantsController.deleteUserPlant(widget.plant.id);
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove plant: $e'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _imagePageController.dispose();
    super.dispose();
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.grey[100],
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.plant.commonName,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            widget.plant.siteName ?? 'Site name',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
      actions: [
        PopupMenuButton(
          icon: const Icon(Icons.settings),
          color: Colors.white,
          itemBuilder: (context) => [
            PopupMenuItem(
              height: 40,
              value: 'remove',
              child: Container(
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete_outline,
                      color: Colors.red[600],
                      size: 20,
                    ),
                    Text(
                      'Remove this Plant',
                      style: TextStyle(
                        color: Colors.red[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
          onSelected: (value) {
            if (value == 'remove') {
              _removePlant();
            }
          },
        ),
      ],
    );
  }

  Widget _buildImageCarousel() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView(
            controller: _imagePageController,
            children: List.generate(
              3,
              (index) => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(widget.plant.imageUrl ?? ''),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SmoothPageIndicator(
              controller: _imagePageController,
              count: 3,
              effect: const ExpandingDotsEffect(
                dotColor: Colors.white60,
                activeDotColor: Colors.white,
                dotHeight: 8,
                dotWidth: 8,
                expansionFactor: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[100]!, width: 0),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: false,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey,
        indicatorSize: TabBarIndicatorSize.tab,
        labelPadding: const EdgeInsets.symmetric(horizontal: 24),
        indicator: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(1),
        ),
        tabs: const [
          Tab(icon: Icon(Symbols.other_houses, size: 20)),
          Tab(icon: Icon(Icons.task, size: 20)),
          Tab(icon: Icon(Symbols.autorenew, size: 20)),
          Tab(icon: Icon(Icons.info_outline, size: 20)),
        ],
      ),
    );
  }

  Widget _buildOverviewContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.5,
            children: [
              _buildInfoChip(Icons.water_drop_outlined,
                  widget.plant.waterRequirement ?? 'Unknown'),
              _buildInfoChip(
                  Icons.trending_up, widget.plant.difficultyLevel ?? 'Unknown'),
              _buildInfoChip(Icons.location_on_outlined,
                  widget.plant.habitat ?? 'Unknown'),
              _buildInfoChip(
                  Icons.warning_outlined, widget.plant.toxicity ?? 'Unknown'),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Plant description',
                  style: TextStyle(
                    fontFamily: 'Open Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF737373),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.plant.description ?? 'Description not available',
                  style: const TextStyle(
                    fontFamily: 'Open Sans',
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Container(
            key: _plantCareKey,
            child: _buildPlantCareSection(),
          ),
          const SizedBox(height: 28),
          Container(
            key: _characteristicsKey,
            child: _buildCharacteristicsSection(),
          ),
          const SizedBox(height: 28),
          Container(
            key: _faqKey,
            child: _buildFAQSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.all(8),
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFAFAFAF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Open Sans',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantCareSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Plant Care',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 14),
        _buildExpandableCareCard(
          'Water & Misting',
          PlantCareSection.waterAndMisting,
          [
            _buildCareItem(
              icon: Icons.water_drop,
              backgroundColor: const Color(0xFF53CBFF),
              title: widget.plant.waterDescription ??
                  'Water description not available',
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 0),
              child: Divider(color: Color(0xFFD9D9D9)),
            ),
            _buildCareItem(
              icon: Icons.opacity,
              backgroundColor: const Color(0xFF34CDC4),
              title: widget.plant.mistingDescription ??
                  'Misting details not available',
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildExpandableCareCard(
          'Site, light & temperature',
          PlantCareSection.siteLightAndTemperature,
          [
            _buildCareItem(
              icon: Icons.home_outlined,
              backgroundColor: const Color(0xFF42A4C2),
              title: widget.plant.siteType ?? 'Indoor, Outdoor',
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 0),
              child: Divider(color: Color(0xFFD9D9D9)),
            ),
            _buildCareItem(
              icon: Icons.wb_sunny_outlined,
              backgroundColor: const Color(0xFFFFBA53),
              title: widget.plant.lightingNeeded ??
                  'Lighting details not available',
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildExpandableCareCard(
          'Fertilizer',
          PlantCareSection.fertilizer,
          [
            _buildCareItem(
              icon: Icons.local_florist,
              backgroundColor: const Color(0xFFFA4CFE),
              title: widget.plant.fertilizerDescription ??
                  'Fertilizer details not available',
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 0),
              child: Divider(color: Color(0xFFD9D9D9)),
            ),
            _buildCareItem(
              icon: Icons.science,
              backgroundColor: const Color(0xFF797979),
              title: widget.plant.fertilizerOverview ??
                  'Fertilizer overview not available',
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildExpandableCareCard(
          'Pot and Soil',
          PlantCareSection.potAndSoil,
          [
            _buildCareItem(
              icon: Icons.update,
              backgroundColor: const Color(0xFFAFAFAF),
              title:
                  widget.plant.potOverview ?? 'Repotting details not available',
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 0),
              child: Divider(color: Color(0xFFD9D9D9)),
            ),
            _buildCareItem(
              icon: Icons.landscape,
              backgroundColor: const Color(0xFFAFAFAF),
              title: widget.plant.suitableSoil ??
                  'Suitable soil details not available',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCareItem({
    required IconData icon,
    required Color backgroundColor,
    required String title,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Open Sans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableCareCard(
      String title, PlantCareSection section, List<Widget> items) {
    final isExpanded = _expandedSections[section] ?? false;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // ADDED: new shadow
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF737373),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Open Sans',
                  ),
                ),
                const SizedBox(height: 16),
                ...items,
              ],
            ),
          ),
          if (isExpanded) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Divider(color: Color(0xFFD9D9D9)),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Care Instructions',
                    style: TextStyle(
                      fontFamily: 'Open Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.plant.specialCare ??
                        'Special care instructions not available',
                    style: const TextStyle(
                      fontFamily: 'Open Sans',
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
          InkWell(
            onTap: () {
              setState(() {
                _expandedSections[section] = !isExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFDFDFD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isExpanded ? 'Show less' : 'Learn more',
                      style: const TextStyle(
                        color: Color(0xFF727272),
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Open Sans',
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: const Color(0xFF727272),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacteristicsItem(String label, String value,
      {bool showDivider = true}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: Color(0xFFAFAFAF),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.eco_outlined, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            fontFamily: 'Open Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontFamily: 'Open Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(color: Color(0xFFD9D9D9)),
      ],
    );
  }

  Widget _buildCharacteristicsSection() {
    // Define all characteristics items
    final List<Map<String, String>> characteristics = [
      {'label': 'Plant type', 'value': widget.plant.plantType ?? 'Unknown'},
      {'label': 'Common name', 'value': widget.plant.commonName},
      {'label': 'Toxicity', 'value': widget.plant.toxicity ?? 'Unknown'},
      {
        'label': 'Common problems',
        'value': widget.plant.commonProblemsOrDiseases ?? 'Unknown'
      },
      {'label': 'Common pests', 'value': widget.plant.commonPests ?? 'Unknown'},
      {
        'label': 'Suitable temperature',
        'value': widget.plant.suitableTemperature ?? 'Unknown'
      },
      {
        'label': 'Flower',
        'value': widget.plant.bloomTime != null ? 'Yes' : 'No'
      },
      {'label': 'Bloom time', 'value': widget.plant.bloomTime ?? 'Unknown'},
      {'label': 'Mature size', 'value': widget.plant.matureSize ?? 'Unknown'},
      {'label': 'Leaf color', 'value': widget.plant.color ?? 'Unknown'},
    ];

    // Calculate items to show based on expanded state
    final itemsToShow = _isCharacteristicsExpanded
        ? characteristics
        : characteristics.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Characteristics',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              ...itemsToShow.map((item) => _buildCharacteristicsItem(
                    item['label']!,
                    item['value']!,
                    showDivider: item != itemsToShow.last,
                  )),
              InkWell(
                onTap: () {
                  setState(() {
                    _isCharacteristicsExpanded = !_isCharacteristicsExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isCharacteristicsExpanded ? 'Show less' : 'Show more',
                        style: const TextStyle(
                          color: Color(0xFF727272),
                          fontFamily: 'Open Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _isCharacteristicsExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: const Color(0xFF727272),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFAQSection() {
    return _faqItems.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'FAQ',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),
              ...List.generate(
                _faqItems.length,
                (index) => _buildFAQItem(_faqItems[index], index),
              ),
              const SizedBox(height: 28),
              _buildReportSection(),
            ],
          )
        : Container();
  }

  Widget _buildFAQItem(FAQItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                item.isExpanded = !item.isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.question,
                      style: const TextStyle(
                        fontFamily: 'Open Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    item.isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF727272),
                  ),
                ],
              ),
            ),
          ),
          if (item.isExpanded) ...[
            const Divider(
              height: 1,
              color: Color(0xFFD9D9D9),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.answer,
                    style: const TextStyle(
                      fontFamily: 'Open Sans',
                      fontSize: 14,
                      height: 1.5,
                      color: Color(0xFF737373),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReportSection() {
    return Column(
      children: [
        const Text(
          'Is the information wrong? If you find anything wrong, please help us by reporting it below.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Open Sans',
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReportPage(plant: widget.plant),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF0857D),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 53, vertical: 10),
          ),
          child: const Text(
            'Report',
            style: TextStyle(
              fontFamily: 'Open Sans',
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _fetchTasks,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            _buildImageCarousel(),
            _buildTabBar(),
            SizedBox(
              height:
                  MediaQuery.of(context).size.height * 0.6, // Adjust as needed
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        PlantSettingsWidget(plant: widget.plant, tasks: _tasks),
                        UpcomingTasksWidget(tasks: _tasks),
                        // TODO: Implement progress update widget
                        // _tasks.isEmpty
                        //     ? const EmptyProgressWidget()
                        //     : ProgressGraph(tasks: _tasks),
                        const EmptyProgressWidget(),
                        _buildOverviewContent(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
