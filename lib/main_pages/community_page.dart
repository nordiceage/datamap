
// import 'package:flutter/material.dart';
// import 'package:flutter/gestures.dart';
// import 'package:treemate/community/model/post_model.dart';
// import 'dart:async';
// import 'dart:io';
// import '../community/loader/community_page_loader.dart';
// import '../shared_pages/saved_page.dart';
// import '../community/controllers/posts_controller.dart';
// import 'package:lottie/lottie.dart';
//
// class CommunityPage extends StatefulWidget {
//   const CommunityPage({Key? key}) : super(key: key);
//
//   @override
//   _CommunityPageState createState() => _CommunityPageState();
// }
//
// class _CommunityPageState extends State<CommunityPage> {
//   bool _isLoading = true;
//   List<PostModel> _displayedPosts = [];
//   late PageController _pageController;
//   String _selectedFilter = 'All';
//   bool _isAppBarVisible = true;
//   bool _hasInternetConnection = true;
//   final PostsController _postsController = PostsController();
//   Timer? _backgroundRefreshTimer;
//   final Duration _backgroundRefreshInterval = Duration(seconds: 10);
//   bool _isRefreshing = false;
//
//   final Map<String, Color> filterColors = {
//     'All': Colors.black,
//     'Insights': Colors.blue,
//     'Product': Colors.orange,
//   };
//
//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController(viewportFraction: 1.0);
//     _pageController.addListener(_onPageChange);
//     _checkInternetAndLoadData();
//     _startBackgroundRefresh();
//   }
//
//   @override
//   void dispose() {
//     _pageController.removeListener(_onPageChange);
//     _pageController.dispose();
//     _backgroundRefreshTimer?.cancel();
//     super.dispose();
//   }
//
//   void _onPageChange() {
//     if (_pageController.page == _pageController.page?.round() && _postsController.hasMorePages() ) {
//       _checkInternetAndLoadData();
//     }
//   }
//
//   void _startBackgroundRefresh() {
//     _backgroundRefreshTimer = Timer.periodic(_backgroundRefreshInterval, (timer) {
//       if (!_isRefreshing &&  _postsController.hasMorePages()) {
//         _fetchNewPostsInBackground();
//       }
//     });
//   }
//
//   Future<void> _fetchNewPostsInBackground() async{
//     setState(() {
//       _isRefreshing = true;
//     });
//     try{
//       final List<PostModel> fetchedPosts = await _postsController.fetchPosts();
//       if (fetchedPosts.isNotEmpty && mounted) {
//         setState(() {
//           _displayedPosts = fetchedPosts;
//         });
//       }
//     }catch (e){
//       if (mounted) {
//         // Handle Error
//         print('Error fetching new post: $e');
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isRefreshing = false;
//         });
//       }
//     }
//   }
//
//   Future<void> _checkInternetAndLoadData() async {
//     bool hasInternet = await _checkInternetConnection();
//
//     setState(() {
//       _hasInternetConnection = hasInternet;
//       if (hasInternet && _displayedPosts.isEmpty) {
//         _loadData();
//       } else if(hasInternet){
//         _loadMoreData();
//       }
//       else {
//         _isLoading = false;
//       }
//     });
//   }
//
//   Future<bool> _checkInternetConnection() async {
//     try {
//       final result = await InternetAddress.lookup('example.com');
//       return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
//     } on SocketException catch (_) {
//       return false;
//     }
//   }
//
//
//   Future<void> _loadData() async {
//     setState(() {
//       _isLoading = true;
//     });
//     try{
//       _postsController.resetPagination();
//       final List<PostModel> fetchedPosts = await _postsController.fetchPosts();
//       if (mounted) {
//         setState(() {
//           _displayedPosts = fetchedPosts;
//           _isLoading = false;
//         });
//       }
//     }catch(e){
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }
//
//   Future<void> _loadMoreData() async {
//     if(!_postsController.hasMorePages() || _isLoading) return;
//     setState(() {
//       _isLoading = true;
//     });
//     try{
//       final List<PostModel> fetchedPosts = await _postsController.fetchPosts();
//       if (mounted) {
//         setState(() {
//           _displayedPosts = fetchedPosts;
//           _isLoading = false;
//         });
//       }
//     }catch(e){
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }
//
//   void _handleVerticalDragEnd(DragEndDetails details) {
//     if (details.primaryVelocity! > 0) {
//       // Swiped down
//       _checkInternetAndLoadData();
//     } else if (details.primaryVelocity! < 0) {
//       // Swiped up
//       _checkInternetAndLoadData();
//     }
//   }
//
//   void _toggleAppBarVisibility() {
//     setState(() {
//       _isAppBarVisible = !_isAppBarVisible;
//     });
//   }
//
//   void _handleVerticalDragUpdate(DragUpdateDetails details) {
//     if (details.delta.dy > 0 && _isAppBarVisible) {
//       // Swiping down, hide the app bar
//       setState(() {
//         _isAppBarVisible = false;
//       });
//     } else if (details.delta.dy < 0 && !_isAppBarVisible) {
//       // Swiping up, show the app bar
//       setState(() {
//         _isAppBarVisible = true;
//       });
//     }
//   }
//
//   void _showFilterPopup() {
//     showModalBottomSheet(
//       context: context,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (BuildContext context) {
//         return Container(
//           padding: EdgeInsets.all(16),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Text(
//                 'Filter',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 16),
//               _buildFilterOption('All'),
//               SizedBox(height: 10),
//               _buildFilterOption('Insights'),
//               SizedBox(height: 10),
//               _buildFilterOption('Product'),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildFilterOption(String filter) {
//     return InkWell(
//       onTap: () {
//         Navigator.of(context).pop();
//         if (filter != _selectedFilter) {
//           setState(() {
//             _selectedFilter = filter;
//           });
//           _fetchFilteredPosts(filter);
//         }
//       },
//       child: Container(
//         padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
//         decoration: BoxDecoration(
//           color: _selectedFilter == filter ? Colors.green.withOpacity(0.1) : Colors.transparent,
//           borderRadius: BorderRadius.circular(30),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 20,
//               height: 20,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: filterColors[filter],
//               ),
//             ),
//             SizedBox(width: 10),
//             Text(filter),
//           ],
//         ),
//       ),
//     );
//   }
//
//
//   void _fetchFilteredPosts(String filter) {
//     if (filter == "All") {
//       _loadData();
//     } else {
//       setState(() {
//         List<PostModel> filteredPosts = _displayedPosts
//             .where((post) => post.postType == filter.toUpperCase())
//             .toList();
//         if (filteredPosts.isEmpty) {
//           _showNoPostsMessage();
//         } else {
//           _displayedPosts = filteredPosts;
//           _pageController.jumpToPage(0);
//         }
//       });
//     }
//   }
//
//   Future<void> _showNoPostsMessage() async {
//     setState(() {
//       _displayedPosts = []; // Set displayed posts to empty
//     });
//
//     await showGeneralDialog(
//       context: context,
//       barrierDismissible: true,
//       barrierLabel: 'No Posts Available',
//       transitionDuration: Duration(milliseconds: 200),
//       pageBuilder: (context, animation, secondaryAnimation){
//         return  Stack(
//           children: [
//             Container(
//               color: Colors.black, // Set the background color to black
//             ),
//             Center(
//               child: SizedBox(
//                   width: MediaQuery.of(context).size.width,
//                   height: MediaQuery.of(context).size.height * 0.6,
//                   child: Lottie.asset(
//                       'assets/animations/comming_soon2.json',
//                       fit: BoxFit.contain
//                   )
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return ShimmerCommunityPage(
//         onLoadComplete: () {
//           setState(() {
//             _isLoading = false;
//           });
//         },
//       );
//     } else if (!_hasInternetConnection) {
//       return ShimmerCommunityPage(
//         onLoadComplete: _checkInternetAndLoadData,
//       );
//     } else {
//       return Scaffold(
//         extendBodyBehindAppBar: true,
//         appBar: _isAppBarVisible
//             ? AppBar(
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           title: Text(
//             'Community',
//             style: TextStyle(
//               fontFamily: 'Poppins',
//               fontSize: 24,
//               fontWeight: FontWeight.w700,
//               color: Colors.white,
//               shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
//             ),
//           ),
//           actions: [
//             Padding(
//               padding: EdgeInsets.only(right: 8),
//               child: IconButton(
//                 icon: Container(
//                   width: 20,
//                   height: 24,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: filterColors[_selectedFilter],
//                   ),
//                 ),
//                 onPressed: _showFilterPopup,
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.only(right: 16),
//               child: IconButton(
//                 icon: Hero(
//                   tag: 'bookmarkHero',
//                   child: Icon(Icons.bookmark_border, size: 24, color: Colors.white),
//                 ),
//                 onPressed: () {
//                   Navigator.of(context).push(
//                     PageRouteBuilder(
//                       pageBuilder: (context, animation, secondaryAnimation) => SavedPage(),
//                       transitionsBuilder: (context, animation, secondaryAnimation, child) {
//                         var begin = Offset(1.0, 0.0);
//                         var end = Offset.zero;
//                         var curve = Curves.easeInOut;
//                         var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
//                         return SlideTransition(
//                           position: animation.drive(tween),
//                           child: child,
//                         );
//                       },
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         )
//             : null,
//         body: GestureDetector(
//           onTap: _toggleAppBarVisibility,
//           onVerticalDragUpdate: _handleVerticalDragUpdate,
//           onVerticalDragEnd: _handleVerticalDragEnd,
//           child: PageView.builder(
//             controller: _pageController,
//             scrollDirection: Axis.vertical,
//             itemCount: _displayedPosts.length,
//             itemBuilder: (context, index) => _buildPostItem(context, _displayedPosts[index]),
//           ),
//         ),
//       );
//     }
//   }
//
//   Widget _buildPostItem(BuildContext context, PostModel postItem) {
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         Image.network(
//           postItem.imageUrl,
//           fit: BoxFit.cover,
//         ),
//         Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [
//                 Colors.black.withOpacity(0.7),
//                 Colors.transparent,
//                 Colors.transparent,
//                 Colors.black.withOpacity(0.7),
//               ],
//               stops: [0.0, 0.2, 0.8, 1.0],
//             ),
//           ),
//         ),
//         Positioned(
//           left: 20,
//           right: 20,
//           bottom: 20,
//           child: ExpandablePostContent(
//             title: postItem.title,
//             details: postItem.description,
//           ),
//         ),
//         Positioned(
//           right: 20,
//           bottom: 250,
//           child: Column(
//             children: [
//               _buildActionButton(Icons.favorite_border, () {
//                 // TODO: Implement like functionality
//                 print('Like button pressed');
//               }),
//               SizedBox(height: 10),
//               _buildActionButton(Icons.bookmark_border, () {
//                 // TODO: Implement save functionality
//                 print('Save button pressed');
//               }),
//               SizedBox(height: 10),
//               _buildActionButton(Icons.share, () {
//                 // TODO: Implement share functionality
//                 print('Share button pressed');
//               }),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildActionButton(IconData icon, VoidCallback onPressed) {
//     return Container(
//       width: 50,
//       height: 50,
//       decoration: BoxDecoration(
//         color: Colors.black.withOpacity(0.6),
//         shape: BoxShape.circle,
//       ),
//       child: IconButton(
//         icon: Icon(
//           icon,
//           color: Colors.white,
//           size: 28,
//         ),
//         onPressed: onPressed,
//       ),
//     );
//   }
// }
// class ExpandablePostContent extends StatefulWidget {
//   final String title;
//   final String details;
//
//   const ExpandablePostContent({
//     Key? key,
//     required this.title,
//     required this.details,
//   }) : super(key: key);
//
//   @override
//   _ExpandablePostContentState createState() => _ExpandablePostContentState();
// }
//
// class _ExpandablePostContentState extends State<ExpandablePostContent>
//     with SingleTickerProviderStateMixin {
//   bool _expanded = false;
//   late AnimationController _animationController;
//   late Animation<double> _animation;
//
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 300),
//     );
//     _animation = CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.fastOutSlowIn,
//     );
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   void _toggleExpanded() {
//     setState(() {
//       _expanded = !_expanded;
//       if (_expanded) {
//         _animationController.forward();
//       } else {
//         _animationController.reverse();
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: _toggleExpanded,
//       child: AnimatedBuilder(
//         animation: _animation,
//         builder: (context, child) {
//           return Container(
//             constraints: BoxConstraints(
//               minHeight: 120,
//               maxHeight: _expanded
//                   ? MediaQuery.of(context).size.height * 0.6
//                   : 120,
//             ),
//             decoration: BoxDecoration(
//               color: Colors.black.withOpacity(0.6),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: SingleChildScrollView(
//               physics: _expanded
//                   ? AlwaysScrollableScrollPhysics()
//                   : NeverScrollableScrollPhysics(),
//               child: Padding(
//                 padding: EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       widget.title,
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       widget.details,
//                       maxLines: _expanded ? null : 2,
//                       overflow: _expanded ? null : TextOverflow.ellipsis,
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 14,
//                         shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
//                       ),
//                     ),
//                     SizedBox(height: 12),
//                     Align(
//                       alignment: Alignment.bottomLeft,
//                       child: Text(
//                         _expanded ? 'Tap to collapse' : 'Tap to expand',
//                         style: TextStyle(
//                           color: Colors.blueAccent,
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:treemate/community/model/post_model.dart';
import 'dart:async';
import 'dart:io';
import '../community/loader/community_page_loader.dart';
import '../shared_pages/saved_page.dart';
import '../community/controllers/posts_controller.dart';
import 'package:lottie/lottie.dart';
import 'dart:math';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  bool _isLoading = true;
  List<PostModel> _displayedPosts = [];
  late PageController _pageController;
  String _selectedFilter = 'All';
  bool _isAppBarVisible = true;
  bool _hasInternetConnection = true;
  final PostsController _postsController = PostsController();
  Timer? _backgroundRefreshTimer;
  final Duration _backgroundRefreshInterval = Duration(seconds: 10);
  bool _isRefreshing = false;
  bool _isFetching = false;
  List<PostModel> _seenPosts = []; // New variable to hold previous posts

  final Map<String, Color> filterColors = {
    'All': Colors.black,
    'Insights': Colors.blue,
    'Product': Colors.orange,
  };

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
    _pageController.addListener(_onPageChange);
    _checkInternetAndLoadData();
    _startBackgroundRefresh();
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChange);
    _pageController.dispose();
    _backgroundRefreshTimer?.cancel();
    super.dispose();
  }

  void _onPageChange() {
    if (_pageController.page == _pageController.page?.round() &&
        _postsController.hasMorePages() &&
        !_isFetching ) {
      _checkInternetAndLoadData();
    }
  }

  void _startBackgroundRefresh() {
    _backgroundRefreshTimer = Timer.periodic(_backgroundRefreshInterval, (timer) {
      if (!_isRefreshing &&  _postsController.hasMorePages()) {
        _fetchNewPostsInBackground();
      }
    });
  }

  Future<void> _fetchNewPostsInBackground() async{
    setState(() {
      _isRefreshing = true;
    });
    try{
      final List<PostModel> fetchedPosts = await _postsController.fetchPosts();
      if (fetchedPosts.isNotEmpty && mounted) {
        setState(() {
          _displayedPosts = fetchedPosts;
          _updateSeenPosts(fetchedPosts);
        });
      }
    }catch (e){
      if (mounted) {
        // Handle Error
        print('Error fetching new post: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  Future<void> _checkInternetAndLoadData() async {
    bool hasInternet = await _checkInternetConnection();

    setState(() {
      _hasInternetConnection = hasInternet;
      if (hasInternet && _displayedPosts.isEmpty) {
        _loadData();
      } else if(hasInternet){
        _loadMoreData();
      }
      else {
        _isLoading = false;
      }
    });
  }

  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  void _updateSeenPosts(List<PostModel> newPosts) {
    for (final post in newPosts) {
      if (!_seenPosts.any((seenPost) => seenPost.id == post.id)) {
        _seenPosts.add(post);
      }
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _isFetching = true;
    });
    try{
      _postsController.resetPagination();
      final List<PostModel> fetchedPosts = await _postsController.fetchPosts();
      if (mounted) {
        setState(() {
          _displayedPosts = fetchedPosts;
          _isLoading = false;
          _isFetching = false;
          _updateSeenPosts(fetchedPosts);
        });
      }
    }catch(e){
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isFetching = false;
        });
      }
    }
  }


  Future<void> _loadMoreData() async {
    if(!_postsController.hasMorePages() || _isLoading || _isFetching) return;
    setState(() {
      _isLoading = true;
      _isFetching = true;
    });
    try{
      final List<PostModel> fetchedPosts = await _postsController.fetchPosts();
      if (mounted) {
        setState(() {
          _displayedPosts = fetchedPosts;
          _updateSeenPosts(fetchedPosts);
          _isLoading = false;
          _isFetching = false;
          if(fetchedPosts.isEmpty && _seenPosts.isNotEmpty){
            _showShuffledSeenPosts();
          }
        });
      }
    }catch(e){
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isFetching = false;
        });
      }
    }
  }

  void _showShuffledSeenPosts() {
    _seenPosts.shuffle(Random());
    setState(() {
      _displayedPosts = _seenPosts;
    });
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    if (details.primaryVelocity! > 0) {
      // Swiped down
      _checkInternetAndLoadData();
    } else if (details.primaryVelocity! < 0) {
      // Swiped up
      _checkInternetAndLoadData();
    }
  }

  void _toggleAppBarVisibility() {
    setState(() {
      _isAppBarVisible = !_isAppBarVisible;
    });
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    if (details.delta.dy > 0 && _isAppBarVisible) {
      // Swiping down, hide the app bar
      setState(() {
        _isAppBarVisible = false;
      });
    } else if (details.delta.dy < 0 && !_isAppBarVisible) {
      // Swiping up, show the app bar
      setState(() {
        _isAppBarVisible = true;
      });
    }
  }

  void _showFilterPopup() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Filter',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              _buildFilterOption('All'),
              const SizedBox(height: 10),
              _buildFilterOption('Insights'),
              const SizedBox(height: 10),
              _buildFilterOption('Product'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String filter) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        if (filter != _selectedFilter) {
          setState(() {
            _selectedFilter = filter;
          });
          _fetchFilteredPosts(filter);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: _selectedFilter == filter ? Colors.green.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filterColors[filter],
              ),
            ),
            const SizedBox(width: 10),
            Text(filter),
          ],
        ),
      ),
    );
  }

  void _fetchFilteredPosts(String filter) {
    if (filter == "All") {
      _loadData();
    } else {
      setState(() {
        List<PostModel> filteredPosts = _displayedPosts
            .where((post) => post.postType == filter.toUpperCase())
            .toList();
        if (filteredPosts.isEmpty) {
          _showNoPostsMessage();
        } else {
          _displayedPosts = filteredPosts;
          _pageController.jumpToPage(0);
        }
      });
    }
  }

  Future<void> _showNoPostsMessage() async {
    setState(() {
      _displayedPosts = []; // Set displayed posts to empty
    });

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'No Posts Available',
      transitionDuration: Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation){
        return  Stack(
          children: [
            Container(
              color: Colors.black, // Set the background color to black
            ),
            Center(
              child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Lottie.asset(
                      'assets/animations/comming_soon2.json',
                      fit: BoxFit.contain
                  )
              ),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return ShimmerCommunityPage(
        onLoadComplete: () {
          setState(() {
            _isLoading = false;
          });
        },
      );
    } else if (!_hasInternetConnection) {
      return ShimmerCommunityPage(
        onLoadComplete: _checkInternetAndLoadData,
      );
    } else {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: _isAppBarVisible
            ? AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Community',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: Container(
                  width: 20,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filterColors[_selectedFilter],
                  ),
                ),
                onPressed: _showFilterPopup,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: IconButton(
                icon: const Hero(
                  tag: 'bookmarkHero',
                  child: Icon(Icons.bookmark_border, size: 24, color: Colors.white),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => const SavedPage(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        var begin = const Offset(1.0, 0.0);
                        var end = Offset.zero;
                        var curve = Curves.easeInOut;
                        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        )
            : null,
        body: RefreshIndicator(
          onRefresh: () async{
            _postsController.resetPagination();
            await _loadData();
          },
          child: GestureDetector(
            onTap: _toggleAppBarVisibility,
            onVerticalDragUpdate: _handleVerticalDragUpdate,
            onVerticalDragEnd: _handleVerticalDragEnd,
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: _displayedPosts.length,
              itemBuilder: (context, index) => _buildPostItem(context, _displayedPosts[index]),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildPostItem(BuildContext context, PostModel postItem) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          postItem.imageUrl,
          fit: BoxFit.cover,
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.transparent,
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
              stops: const [0.0, 0.2, 0.8, 1.0],
            ),
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 20,
          child: ExpandablePostContent(
            title: postItem.title,
            details: postItem.description,
          ),
        ),
        Positioned(
          right: 20,
          bottom: 250,
          child: Column(
            children: [
              _buildActionButton(Icons.favorite_border, () {
                // TODO: Implement like functionality
                print('Like button pressed');
              }),
              const SizedBox(height: 10),
              _buildActionButton(Icons.bookmark_border, () {
                // TODO: Implement save functionality
                print('Save button pressed');
              }),
              const SizedBox(height: 10),
              _buildActionButton(Icons.share, () {
                // TODO: Implement share functionality
                print('Share button pressed');
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
class ExpandablePostContent extends StatefulWidget {
  final String title;
  final String details;

  const ExpandablePostContent({
    super.key,
    required this.title,
    required this.details,
  });

  @override
  _ExpandablePostContentState createState() => _ExpandablePostContentState();
}

class _ExpandablePostContentState extends State<ExpandablePostContent>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleExpanded,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            constraints: BoxConstraints(
              minHeight: 120,
              maxHeight: _expanded
                  ? MediaQuery.of(context).size.height * 0.6
                  : 120,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SingleChildScrollView(
              physics: _expanded
                  ? const AlwaysScrollableScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.details,
                      maxLines: _expanded ? null : 2,
                      overflow: _expanded ? null : TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        _expanded ? 'Tap to collapse' : 'Tap to expand',
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
