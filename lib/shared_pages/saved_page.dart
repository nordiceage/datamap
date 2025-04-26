import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
// TODO: Implement bookmark functionality
class SavedPost {
  final String id;
  final String title;
  final String type;
  final String description;
  final String imageUrl;

  SavedPost({
    required this.id,
    required this.title,
    required this.type,
    required this.description,
    required this.imageUrl
  });
}
class SavedPostsModel extends ChangeNotifier {
  final List<SavedPost> _posts = [];
  String _selectedFilter = 'All';
  bool _showMockData = false;

  final List<SavedPost> _mockPosts = [
    SavedPost(
        id: '1',
        title: 'Latest Industry Trends',
        type: 'Insights',
        description: 'Explore the cutting-edge developments shaping our industry.',
        imageUrl: 'https://picsum.photos/seed/insights/300/200'
    ),
    SavedPost(
        id: '2',
        title: 'New Product Launch',
        type: 'Products',
        description: 'Introducing our revolutionary new product line for 2024.',
        imageUrl: 'https://picsum.photos/seed/products/300/200'
    ),
    SavedPost(
        id: '3',
        title: 'Annual Conference 2024',
        type: 'Events',
        description: 'Join us for three days of networking and innovation.',
        imageUrl: 'https://picsum.photos/seed/events/300/200'
    ),
    SavedPost(
        id: '4',
        title: 'Market Analysis Report',
        type: 'Insights',
        description: 'In-depth analysis of market trends and future projections.',
        imageUrl: 'https://picsum.photos/seed/market/300/200'
    ),
    SavedPost(
        id: '5',
        title: 'Product Showcase',
        type: 'Products',
        description: 'Highlighting our top-performing products of the year.',
        imageUrl: 'https://picsum.photos/seed/showcase/300/200'
    ),
  ];

  List<SavedPost> get posts => _showMockData ? _mockPosts : _posts;
  String get selectedFilter => _selectedFilter;
  bool get showMockData => _showMockData;

  void toggleMockData() {
    _showMockData = !_showMockData;
    notifyListeners();
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  List<SavedPost> get filteredPosts {
    final postsToFilter = _showMockData ? _mockPosts : _posts;
    if (_selectedFilter == 'All') return postsToFilter;
    return postsToFilter.where((post) => post.type == _selectedFilter).toList();
  }
}

class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SavedPostsModel(),
      child: LoadingPage(
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text('Saved',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
              textAlign: TextAlign.center,
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            actions: [
              Consumer<SavedPostsModel>(
                builder: (context, model, child) {
                  return Switch(
                    value: model.showMockData,
                    onChanged: (value) => model.toggleMockData(),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              FilterChips(),
              Expanded(
                child: Consumer<SavedPostsModel>(
                  builder: (context, model, child) {
                    if (model.filteredPosts.isEmpty) {
                      return const NoSavedPosts();
                    } else {
                      return SavedPostsList(posts: model.filteredPosts);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//For loading logic
class LoadingPage extends StatefulWidget {
  final Widget child;

  const LoadingPage({super.key, required this.child});

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  bool _isLoading = true;
  bool _hasInternet = true;
  bool _showRetry = false;

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
  }

  Future<void> _checkInternetConnection() async {
    setState(() {
      _isLoading = true;
      _showRetry = false;
    });
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        // We have a network connection, but let's verify internet connectivity
        bool internetAvailable = await _checkActualInternetConnectivity();
        if (internetAvailable) {
          await Future.delayed(const Duration(seconds: 2));
          setState(() {
            _isLoading = false;
            _hasInternet = true;
          });
        } else {
          await Future.delayed(const Duration(seconds: 5));
          setState(() {
            _isLoading = false;
            _hasInternet = false;
            _showRetry = true;
          });
        }
      } else {
        await Future.delayed(const Duration(seconds: 5));
        setState(() {
          _isLoading = false;
          _hasInternet = false;
          _showRetry = true;
        });
      }
    } catch (e) {
      print("Error checking internet connection: $e");
      await Future.delayed(const Duration(seconds: 5));
      setState(() {
        _isLoading = false;
        _hasInternet = false;
        _showRetry = true;
      });
    }
  }

  Future<bool> _checkActualInternetConnectivity() async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com')).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Stack(
          children: [
            const ShimmerLoadingPage(),
            Center(
              child: Lottie.asset(
                'assets/animations/leaves_loading.json',
                width: 200,
                height: 200,
              ),
            ),
          ],
        ),
      );
    } else if (!_hasInternet && _showRetry) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text("No internet connection"),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _checkInternetConnection,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      "Retry",
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return widget.child;
    }
  }
}

class ShimmerLoadingPage extends StatelessWidget {
  const ShimmerLoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          leading: const IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: null,
          ),
          title: const Text(
            'Saved',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: const [
            Switch(
              value: false,
              onChanged: null,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Insights', 'Products', 'Events'].map((filter) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: FilterChip(
                    label: Text(filter),
                    onSelected: null,
                    backgroundColor: Colors.grey[200],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Expanded(
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              padding: const EdgeInsets.all(10),
              itemCount: 6,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
//loading logic ends
class FilterChips extends StatelessWidget {
  final List<String> filters = ['All', 'Insights', 'Products', 'Events'];

  FilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SavedPostsModel>(
      builder: (context, model, child) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: filters.map((filter) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: FilterChip(
                    label: Text(filter),
                    selected: model.selectedFilter == filter,
                    onSelected: (bool selected) {
                      if (selected) model.setFilter(filter);
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: model.selectedFilter == filter
                          ? Theme.of(context).primaryColor
                          : Colors.black,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(
                        color: model.selectedFilter == filter
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                        width: 1.0,
                      ),
                    ),
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class NoSavedPosts extends StatelessWidget {
  const NoSavedPosts({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Symbols.bookmark,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            "You haven't saved any posts",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class SavedPostsList extends StatelessWidget {
  final List<SavedPost> posts;

  const SavedPostsList({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      padding: const EdgeInsets.all(10),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return SavedPostCard(post: posts[index]);
      },
    );
  }
}

class SavedPostCard extends StatelessWidget {
  final SavedPost post;

  const SavedPostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: Image.network(
              post.imageUrl,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  post.description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  post.type,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getColorForType(post.type),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'Insights':
        return Colors.blue;
      case 'Products':
        return Colors.green;
      case 'Events':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}