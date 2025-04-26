// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:treemate/community/model/post_model.dart';
//
// class PostsController {
//   late final String apiUrl;
//   bool _isInitialized = false;
//   final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
//   int _currentPage = 1; // Track the current page
//   bool _hasMorePages = true;
//   List<PostModel> _cachedPosts = []; // Store cached posts
//
//   Future<void> init() async {
//     if (!_isInitialized) {
//       apiUrl = '${dotenv.env['API_BASE_URL'] ?? "http://localhost:6555"}/api/v1';
//       _isInitialized = true;
//       if (kDebugMode) {
//         print("[DEBUG] API URL initialized: $apiUrl");
//       }
//     }
//   }
//   Future<void> ensureInitialized() async {
//     if (!_isInitialized) {
//       await init();
//     }
//   }
//
//   Future<Map<String, String>> _getHeaders() async {
//     String? token = await _secureStorage.read(key: 'accessToken');
//     if (token == null || token.isEmpty) {
//       if (kDebugMode) {
//         print('Error: Authorization access token not found or is empty.');
//       }
//       throw Exception('Authorization token not found.');
//     } else {
//       if (kDebugMode) {
//         print('[DEBUG] Access Token retrieved successfully: $token');
//       }
//     }
//     return {
//       'Authorization': 'Bearer $token',
//       'Content-Type': 'application/json',
//     };
//   }
//   Future<bool> _refreshToken() async {
//     try {
//       String? refreshToken = await _secureStorage.read(key: 'refreshToken');
//       if (refreshToken == null || refreshToken.isEmpty) {
//         if (kDebugMode) {
//           print('[DEBUG] No refresh token available');
//         }
//         throw Exception('No refresh token available');
//       }
//
//       if (kDebugMode) {
//         print('[DEBUG] Attempting to refresh token with: $refreshToken');
//       }
//
//       final response = await http.post(
//         Uri.parse('$apiUrl/auth/refresh-token'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({'refreshToken': refreshToken}),
//       );
//
//       if (kDebugMode) {
//         print('[DEBUG] Refresh token response status code: ${response.statusCode}');
//         print('[DEBUG] Refresh token response body: ${response.body}');
//       }
//
//       if (response.statusCode == 200) {
//         final jsonResponse = json.decode(response.body);
//
//         if (kDebugMode) {
//           print('[DEBUG] Received new access token: ${jsonResponse['accessToken']}');
//           print('[DEBUG] Received new refresh token: ${jsonResponse['refreshToken']}');
//         }
//
//         await _secureStorage.write(key: 'accessToken', value: jsonResponse['accessToken']);
//         await _secureStorage.write(key: 'refreshToken', value: jsonResponse['refreshToken']);
//
//         if (kDebugMode) {
//           print('[DEBUG] Tokens refreshed successfully');
//         }
//         return true;
//       } else if (response.statusCode == 401 || response.statusCode == 403) {
//         // Token is invalid, force logout
//         if (kDebugMode) {
//           print('[DEBUG] Token expired or unauthorized. Clearing secure storage.');
//         }
//         await _secureStorage.deleteAll();
//         throw Exception('Token expired. Please log in again.');
//       } else {
//         if (kDebugMode) {
//           print('[DEBUG] Failed to refresh token. Status code: ${response.statusCode}');
//         }
//         throw Exception('Failed to refresh token');
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('[DEBUG] Refresh token error: $e');
//         print('[DEBUG] Error type: ${e.runtimeType}');
//         print('[DEBUG] Full error details: ${e.toString()}');
//       }
//       return false;
//     }
//   }
//
//   Future<Map<String, String>> _getHeadersWithAutoRefresh() async {
//     try {
//       return await _getHeaders();
//     } catch (e) {
//       if (kDebugMode) {
//         print('[DEBUG] Error in getting headers: $e');
//       }
//       if (e.toString().contains('Authorization token not found') ||
//           e.toString().contains('Unauthorized') ||
//           e.toString().contains('Invalid token')) {
//         try {
//           bool refreshed = await _refreshToken();
//           if (refreshed) {
//             return await _getHeaders();
//           }
//         } catch (refreshError) {
//           if (kDebugMode) {
//             print('[DEBUG] Token refresh failed: $refreshError');
//           }
//         }
//         await _secureStorage.deleteAll();
//         throw Exception('Authentication failed. Please log in again.');
//       } else {
//         rethrow;
//       }
//     }
//   }
//
//   Future<http.Response> _retryRequest(
//       Future<http.Response> Function() requestFunc,
//       {int retries = 1}
//       ) async {
//     for (int attempt = 0; attempt <= retries; attempt++) {
//       try {
//         final headers = await _getHeadersWithAutoRefresh();
//         final response = await requestFunc();
//         if (kDebugMode) {
//           print('[DEBUG] Request attempt $attempt, Status: ${response.statusCode}');
//         }
//         if (response.statusCode < 400) {
//           return response;
//         }
//         if (response.statusCode == 401 || response.statusCode == 403) {
//           if (attempt == retries) {
//             await _secureStorage.deleteAll();
//             throw Exception('Authentication failed after $retries attempts.');
//           }
//           bool refreshed = await _refreshToken();
//           if (!refreshed) {
//             await _secureStorage.deleteAll();
//             throw Exception('Failed to refresh token. Please log in again.');
//           }
//           continue;
//         }
//         return response;
//       } catch (e) {
//         if (kDebugMode) {
//           print('[DEBUG] Request attempt $attempt failed: $e');
//         }
//         if (attempt == retries) {
//           rethrow;
//         }
//       }
//     }
//     throw Exception('Unexpected error during request retry.');
//   }
//
//   Future<List<PostModel>> fetchPosts({int limit = 10}) async {
//     await ensureInitialized(); // Ensure apiUrl is initialized
//
//     try {
//       if (!_hasMorePages) {
//         if (kDebugMode) {
//           print('[DEBUG] No more posts to load');
//         }
//         return _cachedPosts; // No more posts to load
//       }
//
//       final response = await _retryRequest(
//             () async {
//           final headers = await _getHeadersWithAutoRefresh();
//           return await http.get(
//             Uri.parse('$apiUrl/posts/?page=$_currentPage&limit=$limit'),
//             headers: headers,
//           );
//         },
//         retries: 2,
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final Map<String, dynamic> jsonResponse = json.decode(response.body);
//         List<dynamic> postsJson = jsonResponse['data']['items'];
//
//         if (kDebugMode) {
//           print('[DEBUG] API Response Body: $postsJson');
//           print('[DEBUG] Fetched ${postsJson.length} posts from page $_currentPage');
//         }
//
//         if (postsJson.isEmpty) {
//           if (kDebugMode) {
//             print('[INFO] No posts were retrieved from the server.');
//           }
//           _hasMorePages = false;
//           return _cachedPosts;
//         }
//
//         final List<PostModel> newPosts = postsJson.map((post) => PostModel.fromJson(post)).toList();
//
//         // Cache the new data
//         _cachedPosts.addAll(newPosts);
//
//         // Increment page number
//         final totalPages = jsonResponse['data']['pagination']['totalPages'] as int;
//
//         if(_currentPage < totalPages ){
//           _currentPage++;
//         }else{
//           _hasMorePages = false;
//           if (kDebugMode) {
//             print('[DEBUG] Reached end of page');
//           }
//         }
//         return _cachedPosts;
//       } else {
//         if (kDebugMode) {
//           print('[ERROR] Failed to fetch posts: HTTP ${response.statusCode}, Response: ${response.body}');
//         }
//         throw Exception('Failed to load posts');
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print("[ERROR] Exception in fetchPosts: $e");
//       }
//       rethrow;
//     }
//   }
//
//   void resetPagination() {
//     _currentPage = 1;
//     _hasMorePages = true;
//     _cachedPosts.clear(); // Clear cached posts
//   }
//
//   bool hasMorePages(){
//     return _hasMorePages;
//   }
// }

//using cache and other logic to reduce the load on server

// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:treemate/community/model/post_model.dart';
//
// class PostsController {
//   late final String apiUrl;
//   bool _isInitialized = false;
//   final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
//   int _currentPage = 1; // Track the current page
//   bool _hasMorePages = true;
//   List<PostModel> _cachedPosts = []; // Store cached posts
//   final Duration _cacheInvalidationThreshold = Duration(minutes: 5); // set cache time
//
//   Future<void> init() async {
//     if (!_isInitialized) {
//       apiUrl = '${dotenv.env['API_BASE_URL'] ?? "http://localhost:6555"}/api/v1';
//       _isInitialized = true;
//       if (kDebugMode) {
//         print("[DEBUG] API URL initialized: $apiUrl");
//       }
//     }
//   }
//   Future<void> ensureInitialized() async {
//     if (!_isInitialized) {
//       await init();
//     }
//   }
//
//   Future<Map<String, String>> _getHeaders() async {
//     String? token = await _secureStorage.read(key: 'accessToken');
//     if (token == null || token.isEmpty) {
//       if (kDebugMode) {
//         print('Error: Authorization access token not found or is empty.');
//       }
//       throw Exception('Authorization token not found.');
//     } else {
//       if (kDebugMode) {
//         print('[DEBUG] Access Token retrieved successfully: $token');
//       }
//     }
//     return {
//       'Authorization': 'Bearer $token',
//       'Content-Type': 'application/json',
//     };
//   }
//   Future<bool> _refreshToken() async {
//     try {
//       String? refreshToken = await _secureStorage.read(key: 'refreshToken');
//       if (refreshToken == null || refreshToken.isEmpty) {
//         if (kDebugMode) {
//           print('[DEBUG] No refresh token available');
//         }
//         throw Exception('No refresh token available');
//       }
//
//       if (kDebugMode) {
//         print('[DEBUG] Attempting to refresh token with: $refreshToken');
//       }
//
//       final response = await http.post(
//         Uri.parse('$apiUrl/auth/refresh-token'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({'refreshToken': refreshToken}),
//       );
//
//       if (kDebugMode) {
//         print('[DEBUG] Refresh token response status code: ${response.statusCode}');
//         print('[DEBUG] Refresh token response body: ${response.body}');
//       }
//
//       if (response.statusCode == 200) {
//         final jsonResponse = json.decode(response.body);
//
//         if (kDebugMode) {
//           print('[DEBUG] Received new access token: ${jsonResponse['accessToken']}');
//           print('[DEBUG] Received new refresh token: ${jsonResponse['refreshToken']}');
//         }
//
//         await _secureStorage.write(key: 'accessToken', value: jsonResponse['accessToken']);
//         await _secureStorage.write(key: 'refreshToken', value: jsonResponse['refreshToken']);
//
//         if (kDebugMode) {
//           print('[DEBUG] Tokens refreshed successfully');
//         }
//         return true;
//       } else if (response.statusCode == 401 || response.statusCode == 403) {
//         // Token is invalid, force logout
//         if (kDebugMode) {
//           print('[DEBUG] Token expired or unauthorized. Clearing secure storage.');
//         }
//         await _secureStorage.deleteAll();
//         throw Exception('Token expired. Please log in again.');
//       } else {
//         if (kDebugMode) {
//           print('[DEBUG] Failed to refresh token. Status code: ${response.statusCode}');
//         }
//         throw Exception('Failed to refresh token');
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('[DEBUG] Refresh token error: $e');
//         print('[DEBUG] Error type: ${e.runtimeType}');
//         print('[DEBUG] Full error details: ${e.toString()}');
//       }
//       return false;
//     }
//   }
//
//   Future<Map<String, String>> _getHeadersWithAutoRefresh() async {
//     try {
//       return await _getHeaders();
//     } catch (e) {
//       if (kDebugMode) {
//         print('[DEBUG] Error in getting headers: $e');
//       }
//       if (e.toString().contains('Authorization token not found') ||
//           e.toString().contains('Unauthorized') ||
//           e.toString().contains('Invalid token')) {
//         try {
//           bool refreshed = await _refreshToken();
//           if (refreshed) {
//             return await _getHeaders();
//           }
//         } catch (refreshError) {
//           if (kDebugMode) {
//             print('[DEBUG] Token refresh failed: $refreshError');
//           }
//         }
//         await _secureStorage.deleteAll();
//         throw Exception('Authentication failed. Please log in again.');
//       } else {
//         rethrow;
//       }
//     }
//   }
//
//   Future<http.Response> _retryRequest(
//       Future<http.Response> Function() requestFunc,
//       {int retries = 1}
//       ) async {
//     for (int attempt = 0; attempt <= retries; attempt++) {
//       try {
//         final headers = await _getHeadersWithAutoRefresh();
//         final response = await requestFunc();
//         if (kDebugMode) {
//           print('[DEBUG] Request attempt $attempt, Status: ${response.statusCode}');
//         }
//         if (response.statusCode < 400) {
//           return response;
//         }
//         if (response.statusCode == 401 || response.statusCode == 403) {
//           if (attempt == retries) {
//             await _secureStorage.deleteAll();
//             throw Exception('Authentication failed after $retries attempts.');
//           }
//           bool refreshed = await _refreshToken();
//           if (!refreshed) {
//             await _secureStorage.deleteAll();
//             throw Exception('Failed to refresh token. Please log in again.');
//           }
//           continue;
//         }
//         return response;
//       } catch (e) {
//         if (kDebugMode) {
//           print('[DEBUG] Request attempt $attempt failed: $e');
//         }
//         if (attempt == retries) {
//           rethrow;
//         }
//       }
//     }
//     throw Exception('Unexpected error during request retry.');
//   }
//
//   Future<List<PostModel>> fetchPosts({int limit = 10}) async {
//     await ensureInitialized(); // Ensure apiUrl is initialized
//
//     try {
//       if (!_hasMorePages && _cachedPosts.isNotEmpty && !_isCacheExpired()) {
//         if (kDebugMode) {
//           print('[DEBUG] Returning cached posts, no more pages to load and cache not expired');
//         }
//         return _cachedPosts; // No more posts to load
//       }
//
//       final response = await _retryRequest(
//             () async {
//           final headers = await _getHeadersWithAutoRefresh();
//           return await http.get(
//             Uri.parse('$apiUrl/posts/?page=$_currentPage&limit=$limit'),
//             headers: headers,
//           );
//         },
//         retries: 2,
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final Map<String, dynamic> jsonResponse = json.decode(response.body);
//         List<dynamic> postsJson = jsonResponse['data']['items'];
//
//         if (kDebugMode) {
//           print('[DEBUG] API Response Body: $postsJson');
//           print('[DEBUG] Fetched ${postsJson.length} posts from page $_currentPage');
//         }
//
//         if (postsJson.isEmpty) {
//           if (kDebugMode) {
//             print('[INFO] No posts were retrieved from the server.');
//           }
//           _hasMorePages = false;
//           return _cachedPosts;
//         }
//
//         final List<PostModel> newPosts = postsJson.map((post) => PostModel.fromJson(post)).toList();
//
//         // Cache the new data
//         if(_currentPage == 1) {
//           _cachedPosts = newPosts; // if its first page replace existing cache
//         }else{
//           _cachedPosts.addAll(newPosts); // Cache the new data
//         }
//
//
//         // Increment page number
//         final totalPages = jsonResponse['data']['pagination']['totalPages'] as int;
//
//         if(_currentPage < totalPages ){
//           _currentPage++;
//         }else{
//           _hasMorePages = false;
//           if (kDebugMode) {
//             print('[DEBUG] Reached end of page');
//           }
//         }
//
//         // sort the post based on createdAt
//         _cachedPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
//
//         return _cachedPosts;
//       } else {
//         if (kDebugMode) {
//           print('[ERROR] Failed to fetch posts: HTTP ${response.statusCode}, Response: ${response.body}');
//         }
//         throw Exception('Failed to load posts');
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print("[ERROR] Exception in fetchPosts: $e");
//       }
//       rethrow;
//     }
//   }
//
//
//   bool _isCacheExpired() {
//     if (_cachedPosts.isEmpty) return true;
//     final cacheTime = _cachedPosts.first.createdAt;
//     return DateTime.now().difference(cacheTime) > _cacheInvalidationThreshold;
//   }
//
//
//   void resetPagination() {
//     _currentPage = 1;
//     _hasMorePages = true;
//     // _cachedPosts.clear();  // Do not clear cache when reset
//   }
//
//   bool hasMorePages(){
//     return _hasMorePages;
//   }
// }

// _seenPosts _updateSeenPosts  _seenPosts.shuffle(Random())  _onPageChange _loadMoreData _isFetching are added for multiple uses. refresh indicator is also used here.

// last working version
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:treemate/community/model/post_model.dart';
//
// class PostsController {
//   late final String apiUrl;
//   bool _isInitialized = false;
//   final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
//   int _currentPage = 1; // Track the current page
//   bool _hasMorePages = true;
//
//   final List<PostModel> _cachedPosts = []; // Store cached posts
// // Devs Conflict
// //   List<PostModel> _cachedPosts = []; // Store cached posts
// //   final Duration _cacheInvalidationThreshold = Duration(minutes: 5); // set cache time
//
//
//   Future<void> init() async {
//     if (!_isInitialized) {
//       apiUrl = '${dotenv.env['API_BASE_URL'] ?? "http://localhost:6555"}/api/v1';
//       _isInitialized = true;
//       if (kDebugMode) {
//         print("[DEBUG] API URL initialized: $apiUrl");
//       }
//     }
//   }
//   Future<void> ensureInitialized() async {
//     if (!_isInitialized) {
//       await init();
//     }
//   }
//
//   Future<Map<String, String>> _getHeaders() async {
//     String? token = await _secureStorage.read(key: 'accessToken');
//     if (token == null || token.isEmpty) {
//       if (kDebugMode) {
//         print('Error: Authorization access token not found or is empty.');
//       }
//       throw Exception('Authorization token not found.');
//     } else {
//       if (kDebugMode) {
//         print('[DEBUG] Access Token retrieved successfully: $token');
//       }
//     }
//     return {
//       'Authorization': 'Bearer $token',
//       'Content-Type': 'application/json',
//     };
//   }
//   Future<bool> _refreshToken() async {
//     try {
//       String? refreshToken = await _secureStorage.read(key: 'refreshToken');
//       if (refreshToken == null || refreshToken.isEmpty) {
//         if (kDebugMode) {
//           print('[DEBUG] No refresh token available');
//         }
//         throw Exception('No refresh token available');
//       }
//
//       if (kDebugMode) {
//         print('[DEBUG] Attempting to refresh token with: $refreshToken');
//       }
//
//       final response = await http.post(
//         Uri.parse('$apiUrl/auth/refresh-token'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({'refreshToken': refreshToken}),
//       );
//
//       if (kDebugMode) {
//         print('[DEBUG] Refresh token response status code: ${response.statusCode}');
//         print('[DEBUG] Refresh token response body: ${response.body}');
//       }
//
//       if (response.statusCode == 200) {
//         final jsonResponse = json.decode(response.body);
//
//         if (kDebugMode) {
//           print('[DEBUG] Received new access token: ${jsonResponse['accessToken']}');
//           print('[DEBUG] Received new refresh token: ${jsonResponse['refreshToken']}');
//         }
//
//         await _secureStorage.write(key: 'accessToken', value: jsonResponse['accessToken']);
//         await _secureStorage.write(key: 'refreshToken', value: jsonResponse['refreshToken']);
//
//         if (kDebugMode) {
//           print('[DEBUG] Tokens refreshed successfully');
//         }
//         return true;
//       } else if (response.statusCode == 401 || response.statusCode == 403) {
//         // Token is invalid, force logout
//         if (kDebugMode) {
//           print('[DEBUG] Token expired or unauthorized. Clearing secure storage.');
//         }
//         await _secureStorage.deleteAll();
//         throw Exception('Token expired. Please log in again.');
//       } else {
//         if (kDebugMode) {
//           print('[DEBUG] Failed to refresh token. Status code: ${response.statusCode}');
//         }
//         throw Exception('Failed to refresh token');
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('[DEBUG] Refresh token error: $e');
//         print('[DEBUG] Error type: ${e.runtimeType}');
//         print('[DEBUG] Full error details: ${e.toString()}');
//       }
//       return false;
//     }
//   }
//
//   Future<Map<String, String>> _getHeadersWithAutoRefresh() async {
//     try {
//       return await _getHeaders();
//     } catch (e) {
//       if (kDebugMode) {
//         print('[DEBUG] Error in getting headers: $e');
//       }
//       if (e.toString().contains('Authorization token not found') ||
//           e.toString().contains('Unauthorized') ||
//           e.toString().contains('Invalid token')) {
//         try {
//           bool refreshed = await _refreshToken();
//           if (refreshed) {
//             return await _getHeaders();
//           }
//         } catch (refreshError) {
//           if (kDebugMode) {
//             print('[DEBUG] Token refresh failed: $refreshError');
//           }
//         }
//         await _secureStorage.deleteAll();
//         throw Exception('Authentication failed. Please log in again.');
//       } else {
//         rethrow;
//       }
//     }
//   }
//
//   Future<http.Response> _retryRequest(
//       Future<http.Response> Function() requestFunc,
//       {int retries = 1}
//       ) async {
//     for (int attempt = 0; attempt <= retries; attempt++) {
//       try {
//         final headers = await _getHeadersWithAutoRefresh();
//         final response = await requestFunc();
//         if (kDebugMode) {
//           print('[DEBUG] Request attempt $attempt, Status: ${response.statusCode}');
//         }
//         if (response.statusCode < 400) {
//           return response;
//         }
//         if (response.statusCode == 401 || response.statusCode == 403) {
//           if (attempt == retries) {
//             await _secureStorage.deleteAll();
//             throw Exception('Authentication failed after $retries attempts.');
//           }
//           bool refreshed = await _refreshToken();
//           if (!refreshed) {
//             await _secureStorage.deleteAll();
//             throw Exception('Failed to refresh token. Please log in again.');
//           }
//           continue;
//         }
//         return response;
//       } catch (e) {
//         if (kDebugMode) {
//           print('[DEBUG] Request attempt $attempt failed: $e');
//         }
//         if (attempt == retries) {
//           rethrow;
//         }
//       }
//     }
//     throw Exception('Unexpected error during request retry.');
//   }
//
//   Future<List<PostModel>> fetchPosts({int limit = 10}) async {
//     await ensureInitialized(); // Ensure apiUrl is initialized
//
//     try {
//       if (!_hasMorePages && _cachedPosts.isNotEmpty && !_isCacheExpired()) {
//         if (kDebugMode) {
//           print('[DEBUG] Returning cached posts, no more pages to load and cache not expired');
//         }
//         return _cachedPosts; // No more posts to load
//       }
//
//       final response = await _retryRequest(
//             () async {
//           final headers = await _getHeadersWithAutoRefresh();
//           return await http.get(
//             Uri.parse('$apiUrl/posts/?page=$_currentPage&limit=$limit'),
//             headers: headers,
//           );
//         },
//         retries: 2,
//       );
//
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final Map<String, dynamic> jsonResponse = json.decode(response.body);
//         List<dynamic> postsJson = jsonResponse['data']['items'];
//
//         if (kDebugMode) {
//           print('[DEBUG] API Response Body: $postsJson');
//           print('[DEBUG] Fetched ${postsJson.length} posts from page $_currentPage');
//         }
//
//         if (postsJson.isEmpty) {
//           if (kDebugMode) {
//             print('[INFO] No posts were retrieved from the server.');
//           }
//           _hasMorePages = false;
//           return _cachedPosts;
//         }
//
//         final List<PostModel> newPosts = postsJson.map((post) => PostModel.fromJson(post)).toList();
//
//         // Cache the new data
//         if(_currentPage == 1) {
//           _cachedPosts = newPosts; // if its first page replace existing cache
//         }else{
//           _cachedPosts.addAll(newPosts); // Cache the new data
//         }
//
//         // Increment page number
//         final totalPages = jsonResponse['data']['pagination']['totalPages'] as int;
//
//         if(_currentPage < totalPages ){
//           _currentPage++;
//         }else{
//           _hasMorePages = false;
//           if (kDebugMode) {
//             print('[DEBUG] Reached end of page');
//           }
//         }
//
//         // sort the post based on createdAt
//         _cachedPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
//         return _cachedPosts;
//       } else {
//         if (kDebugMode) {
//           print('[ERROR] Failed to fetch posts: HTTP ${response.statusCode}, Response: ${response.body}');
//         }
//         throw Exception('Failed to load posts');
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print("[ERROR] Exception in fetchPosts: $e");
//       }
//       rethrow;
//     }
//   }
//
//
//   bool _isCacheExpired() {
//     if (_cachedPosts.isEmpty) return true;
//     final cacheTime = _cachedPosts.first.createdAt;
//     return DateTime.now().difference(cacheTime) > _cacheInvalidationThreshold;
//   }
//
//   void resetPagination() {
//     _currentPage = 1;
//     _hasMorePages = true;
//     // _cachedPosts.clear();  // Do not clear cache when reset
//   }
//
//   bool hasMorePages(){
//     return _hasMorePages;
//   }
// }
//new version
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:treemate/community/model/post_model.dart';

class PostsController {
  late final String apiUrl;
  bool _isInitialized = false;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  int _currentPage = 1; // Track the current page
  bool _hasMorePages = true;

  final List<PostModel> _cachedPosts = []; // Store cached posts
  final Duration _cacheInvalidationThreshold =
      const Duration(minutes: 5); // set cache time

  Future<void> init() async {
    if (!_isInitialized) {
      apiUrl =
          '${dotenv.env['API_BASE_URL'] ?? "http://localhost:6555"}/api/v1';
      _isInitialized = true;
      if (kDebugMode) {
        print("[DEBUG] API URL initialized: $apiUrl");
      }
    }
  }

  Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      await init();
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    String? token = await _secureStorage.read(key: 'accessToken');
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        print('Error: Authorization access token not found or is empty.');
      }
      throw Exception('Authorization token not found.');
    } else {
      if (kDebugMode) {
        print('[DEBUG] Access Token retrieved successfully: $token');
      }
    }
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<bool> _refreshToken() async {
    try {
      String? refreshToken = await _secureStorage.read(key: 'refreshToken');
      if (refreshToken == null || refreshToken.isEmpty) {
        if (kDebugMode) {
          print('[DEBUG] No refresh token available');
        }
        throw Exception('No refresh token available');
      }

      if (kDebugMode) {
        print('[DEBUG] Attempting to refresh token with: $refreshToken');
      }

      final response = await http.post(
        Uri.parse('$apiUrl/auth/refresh-token'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refreshToken': refreshToken}),
      );

      if (kDebugMode) {
        print(
            '[DEBUG] Refresh token response status code: ${response.statusCode}');
        print('[DEBUG] Refresh token response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (kDebugMode) {
          print(
              '[DEBUG] Received new access token: ${jsonResponse['accessToken']}');
          print(
              '[DEBUG] Received new refresh token: ${jsonResponse['refreshToken']}');
        }

        await _secureStorage.write(
            key: 'accessToken', value: jsonResponse['accessToken']);
        await _secureStorage.write(
            key: 'refreshToken', value: jsonResponse['refreshToken']);

        if (kDebugMode) {
          print('[DEBUG] Tokens refreshed successfully');
        }
        return true;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // Token is invalid, force logout
        if (kDebugMode) {
          print(
              '[DEBUG] Token expired or unauthorized. Clearing secure storage.');
        }
        await _secureStorage.deleteAll();
        throw Exception('Token expired. Please log in again.');
      } else {
        if (kDebugMode) {
          print(
              '[DEBUG] Failed to refresh token. Status code: ${response.statusCode}');
        }
        throw Exception('Failed to refresh token');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[DEBUG] Refresh token error: $e');
        print('[DEBUG] Error type: ${e.runtimeType}');
        print('[DEBUG] Full error details: ${e.toString()}');
      }
      return false;
    }
  }

  Future<Map<String, String>> _getHeadersWithAutoRefresh() async {
    try {
      return await _getHeaders();
    } catch (e) {
      if (kDebugMode) {
        print('[DEBUG] Error in getting headers: $e');
      }
      if (e.toString().contains('Authorization token not found') ||
          e.toString().contains('Unauthorized') ||
          e.toString().contains('Invalid token')) {
        try {
          bool refreshed = await _refreshToken();
          if (refreshed) {
            return await _getHeaders();
          }
        } catch (refreshError) {
          if (kDebugMode) {
            print('[DEBUG] Token refresh failed: $refreshError');
          }
        }
        await _secureStorage.deleteAll();
        throw Exception('Authentication failed. Please log in again.');
      } else {
        rethrow;
      }
    }
  }

  Future<http.Response> _retryRequest(
      Future<http.Response> Function() requestFunc,
      {int retries = 1}) async {
    for (int attempt = 0; attempt <= retries; attempt++) {
      try {
        final headers = await _getHeadersWithAutoRefresh();
        final response = await requestFunc();
        if (kDebugMode) {
          print(
              '[DEBUG] Request attempt $attempt, Status: ${response.statusCode}');
        }
        if (response.statusCode < 400) {
          return response;
        }
        if (response.statusCode == 401 || response.statusCode == 403) {
          if (attempt == retries) {
            await _secureStorage.deleteAll();
            throw Exception('Authentication failed after $retries attempts.');
          }
          bool refreshed = await _refreshToken();
          if (!refreshed) {
            await _secureStorage.deleteAll();
            throw Exception('Failed to refresh token. Please log in again.');
          }
          continue;
        }
        return response;
      } catch (e) {
        if (kDebugMode) {
          print('[DEBUG] Request attempt $attempt failed: $e');
        }
        if (attempt == retries) {
          rethrow;
        }
      }
    }
    throw Exception('Unexpected error during request retry.');
  }

  Future<List<PostModel>> fetchPosts({int limit = 10}) async {
    await ensureInitialized(); // Ensure apiUrl is initialized

    try {
      if (!_hasMorePages && _cachedPosts.isNotEmpty && !_isCacheExpired()) {
        if (kDebugMode) {
          print(
              '[DEBUG] Returning cached posts, no more pages to load and cache not expired');
        }
        return _cachedPosts; // No more posts to load
      }

      final response = await _retryRequest(
        () async {
          final headers = await _getHeadersWithAutoRefresh();
          return await http.get(
            Uri.parse('$apiUrl/posts/?page=$_currentPage&limit=$limit'),
            headers: headers,
          );
        },
        retries: 2,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        List<dynamic> postsJson = jsonResponse['data']['items'];

        if (kDebugMode) {
          print('[DEBUG] API Response Body: $postsJson');
          print(
              '[DEBUG] Fetched ${postsJson.length} posts from page $_currentPage');
        }

        if (postsJson.isEmpty) {
          if (kDebugMode) {
            print('[INFO] No posts were retrieved from the server.');
          }
          _hasMorePages = false;
          return _cachedPosts;
        }

        final List<PostModel> newPosts =
            postsJson.map((post) => PostModel.fromJson(post)).toList();

        // Cache the new data
        if (_currentPage == 1) {
          _cachedPosts.clear(); // if its first page replace existing cache
          _cachedPosts.addAll(newPosts);
        } else {
          _cachedPosts.addAll(newPosts); // Cache the new data
        }

        // Increment page number
        final totalPages =
            jsonResponse['data']['pagination']['totalPages'] as int;

        if (_currentPage < totalPages) {
          _currentPage++;
        } else {
          _hasMorePages = false;
          if (kDebugMode) {
            print('[DEBUG] Reached end of page');
          }
        }

        // sort the post based on createdAt
        _cachedPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return _cachedPosts;
      } else {
        if (kDebugMode) {
          print(
              '[ERROR] Failed to fetch posts: HTTP ${response.statusCode}, Response: ${response.body}');
        }
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      if (kDebugMode) {
        print("[ERROR] Exception in fetchPosts: $e");
      }
      rethrow;
    }
  }

  bool _isCacheExpired() {
    if (_cachedPosts.isEmpty) return true;
    final cacheTime = _cachedPosts.first.createdAt;
    return DateTime.now().difference(cacheTime) > _cacheInvalidationThreshold;
  }

  void resetPagination() {
    _currentPage = 1;
    _hasMorePages = true;
    // _cachedPosts.clear();  // Do not clear cache when reset
  }

  bool hasMorePages() {
    return _hasMorePages;
  }
}
