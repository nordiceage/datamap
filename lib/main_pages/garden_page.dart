import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:treemate/plant/Garden_pages/browse_plants.dart';
import 'package:treemate/site/site_module/add_new_site_page.dart';
import 'package:treemate/plant/subpages/plants_page.dart';
import 'package:treemate/shared_pages/saved_page.dart';
import 'package:treemate/site/subpages/sites_page.dart';
import 'package:treemate/task/add_task_module/garden_pages/user_plants_for_task.dart';
import 'package:treemate/task/subpages/tasks_page.dart';
import 'models/my_garden_model.dart';
import '../plant/subpages/fav_plant_page.dart';

class MyGardenPage extends StatefulWidget {
  const MyGardenPage({super.key});

  @override
  State<MyGardenPage> createState() => _MyGardenPageState();
}

class _MyGardenPageState extends State<MyGardenPage>
    with TickerProviderStateMixin {
  late MyGardenModel _model;

  @override
  void initState() {
    super.initState();
    _model = MyGardenModel(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _model.fetchData(); // Fetch data after the frame is rendered
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MyGardenModel>.value(
      value: _model,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          floatingActionButton: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 20, 40),
            child: FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (BuildContext context) {
                    return const BottomModalContent();
                  },
                );
              },
              backgroundColor: const Color(0xFF2B9348),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50.0),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            automaticallyImplyLeading: false,
            title: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Garden',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Consumer<MyGardenModel>(
                    builder: (context, model, child) {
                      print(
                          '[DEBUG] User Plants Length: ${model.userPlantsModel.userPlants.length}');
                      return Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            '${model.totalSites} Sites',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(
                            height: 14,
                            child: VerticalDivider(
                              thickness: 1,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            '${model.totalUserPlants} Plants',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 20, 0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FavoritePlantsScreen()),
                    );
                  },
                  child: const Icon(
                    Icons.favorite_border,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 20, 0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SavedPage()),
                    );
                  },
                  child: const Icon(
                    Icons.bookmark_border_outlined,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 20, 0),
                // todo notification page not available yet
                // child: InkWell(
                //   onTap: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //           builder: (context) => NotificationsPage()),
                //     );
                //   },
                //   child: Icon(
                //     Icons.notifications_none,
                //     color: Colors.black,
                //     size: 24,
                //   ),
                // ),
                //todo for now
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Coming Soon!',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.black87,
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.notifications_none,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ),
            ],
            centerTitle: false,
            elevation: 0,
          ),
          body: SafeArea(
            top: true,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Consumer<MyGardenModel>(
                        builder: (context, model, child) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: TabBar(
                              controller: model.tabBarController,
                              labelColor: Colors.black,
                              unselectedLabelColor: Colors.grey[600],
                              labelStyle:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              unselectedLabelStyle: const TextStyle(
                                  fontWeight: FontWeight.normal),
                              indicator: BoxDecoration(
                                color: const Color(0xFFCDE1D2),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: const Color(0xFF2B9348),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.8),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                    offset: const Offset(0, 0),
                                  ),
                                ],
                              ),
                              indicatorSize: TabBarIndicatorSize.tab,
                              indicatorPadding: EdgeInsets.zero,
                              labelPadding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              dividerColor: Colors.transparent,
                              tabs: const [
                                Tab(text: 'Tasks'),
                                Tab(text: 'Plants'),
                                Tab(text: 'Sites'),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: Consumer<MyGardenModel>(
                        builder: (context, model, child) {
                          return TabBarView(
                              controller: model.tabBarController,
                              children: [
                                const TasksPage(),
                                PlantsPage(),
                                const SitesPage()
                              ]);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BottomModalContent extends StatelessWidget {
  const BottomModalContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 250,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Add New',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CustomModalButton(
                label: 'Task',
                color: Colors.green,
                icon: 'assets/icons/task.png',
                onClick: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const TaskPlantBrowsePage()));
                },
              ),
              CustomModalButton(
                label: 'Plant',
                color: Colors.green,
                icon: 'assets/icons/plant.png',
                onClick: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const PlantBrowsePage()));
                },
              ),
              CustomModalButton(
                label: 'Site',
                color: Colors.green,
                icon: 'assets/icons/site.png',
                onClick: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddNewSitePage()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CustomModalButton extends StatelessWidget {
  final String label;
  final Color color;
  final String icon;
  final VoidCallback onClick;

  const CustomModalButton({
    super.key,
    required this.label,
    required this.color,
    required this.icon,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color.fromARGB(255, 217, 217, 217),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(11.0),
          child: Column(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: Image.asset(icon),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 16, color: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
