import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final DateTime timestamp;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class NotificationsProvider extends ChangeNotifier {
  final List<NotificationModel> _notifications = [];
  String _selectedFilter = 'All';
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _pageSize = 20;

  List<NotificationModel> get notifications => _notifications;
  String get selectedFilter => _selectedFilter;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  Future<void> fetchNotifications({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _notifications.clear();
      _hasMore = true;
    }

    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Simulating API call
      await Future.delayed(const Duration(seconds: 2));
      final newNotifications = await _fetchNotificationsFromApi();

      if (newNotifications.isEmpty) {
        _hasMore = false;
      } else {
        _notifications.addAll(newNotifications);
        _currentPage++;
      }
    } catch (e) {
      // Handle error
      print('Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<NotificationModel>> _fetchNotificationsFromApi() async {
    // TODO: Implement actual API call
    // This is a mock implementation
    return List.generate(
      _pageSize,
          (index) => NotificationModel(
        id: 'notification_${_currentPage}_$index',
        title: 'Notification ${_currentPage * _pageSize + index + 1}',
        message: 'This is a sample notification message.',
        type: index % 3 == 0 ? 'My Garden' : 'Community',
        timestamp: DateTime.now().subtract(Duration(hours: index)),
      ),
    );
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  List<NotificationModel> get filteredNotifications {
    if (_selectedFilter == 'All') return _notifications;
    return _notifications.where((notification) => notification.type == _selectedFilter).toList();
  }
}

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificationsProvider(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
        ),
        body: Column(
          children: [
            FilterChips(),
            const Expanded(
              child: NotificationsList(),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterChips extends StatelessWidget {
  final List<String> filters = ['All', 'My Garden', 'Community'];

  FilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationsProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: filters.map((filter) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: FilterChip(
                    label: Text(filter),
                    selected: provider.selectedFilter == filter,
                    onSelected: (bool selected) {
                      if (selected) provider.setFilter(filter);
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: Colors.green[100],
                    labelStyle: TextStyle(
                      color: provider.selectedFilter == filter
                          ? Colors.green[800]
                          : Colors.black,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(
                        color: provider.selectedFilter == filter
                            ? Colors.green
                            : Colors.transparent,
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

class NotificationsList extends StatefulWidget {
  const NotificationsList({super.key});

  @override
  _NotificationsListState createState() => _NotificationsListState();
}

class _NotificationsListState extends State<NotificationsList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationsProvider>(context, listen: false).fetchNotifications();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      Provider.of<NotificationsProvider>(context, listen: false).fetchNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationsProvider>(
      builder: (context, provider, _) {
        if (provider.notifications.isEmpty && !provider.isLoading) {
          return const NoNotifications();
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchNotifications(refresh: true),
          child: ListView.builder(
            controller: _scrollController,
            itemCount: provider.filteredNotifications.length + 1,
            itemBuilder: (context, index) {
              if (index == provider.filteredNotifications.length) {
                return _buildLoader(provider);
              }
              return NotificationItem(notification: provider.filteredNotifications[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildLoader(NotificationsProvider provider) {
    if (!provider.isLoading) return const SizedBox.shrink();
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class NoNotifications extends StatelessWidget {
  const NoNotifications({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            "You don't have any notifications",
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

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;

  const NotificationItem({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green[100],
          child: Icon(
            notification.type == 'My Garden' ? Icons.local_florist : Icons.people,
            color: Colors.green,
          ),
        ),
        title: Text(notification.title),
        subtitle: Text(notification.message),
        trailing: Text(
          _formatTimestamp(notification.timestamp),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        onTap: () {
          // TODO: Handle notification tap
        },
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

// Implement caching for offline support
class CachedNotificationsRepository {
  static const String _cacheKey = 'cached_notifications';

  Future<void> cacheNotifications(List<NotificationModel> notifications) async {
    // TODO: Implement caching logic
    // This could use shared_preferences, Hive, or another local storage solution
  }

  Future<List<NotificationModel>> getCachedNotifications() async {
    // TODO: Implement retrieval of cached notifications
    return [];
  }
}

// Add animations for smoother user experience
class AnimatedNotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final int index;

  const AnimatedNotificationItem({super.key, required this.notification, required this.index});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: child,
          ),
        );
      },
      child: NotificationItem(notification: notification),
    );
  }
}

// Implement proper error handling and user feedback for API operations
class ErrorHandler {
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Retry',
          onPressed: () {
            // TODO: Implement retry logic
            Provider.of<NotificationsProvider>(context, listen: false).fetchNotifications(refresh: true);
          },
        ),
      ),
    );
  }
}