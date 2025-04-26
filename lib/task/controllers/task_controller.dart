import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:treemate/task/models/usertaskmodel.dart';

class TasksController {
  late final String apiUrl;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  bool _isInitialized = false;

  Future<void> init() async {
    if (!_isInitialized) {
      apiUrl =
          '${dotenv.env['API_BASE_URL'] ?? "http://localhost:6555"}/api/v1';
      _isInitialized = true;
      print('Initialized API URL: $apiUrl');
    }
  }

  Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      await init();
    }
  }

  Future<String?> _getAccessToken() async {
    final token = await _secureStorage.read(key: 'accessToken');
    print(token);
    print(
        'Retrieved access token: ${token?.substring(0, 20)}...'); // Shows first 20 chars for security
    return token;
  }

  Future<Map<String, String>> _getHeaders() async {
    String? token = await _secureStorage.read(key: 'accessToken');
    if (token == null || token.isEmpty) {
      print('Error: Authorization access token not found or is empty.');
      throw Exception('Authorization token not found.');
    } else {
      print('[DEBUG] Access Token retrieved successfully: $token');
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
        print('[DEBUG] No refresh token available');
        throw Exception('No refresh token available');
      }

      print('[DEBUG] Attempting to refresh token with: $refreshToken');

      final response = await http.post(
        Uri.parse('$apiUrl/auth/refresh-token'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refreshToken': refreshToken}),
      );

      print(
          '[DEBUG] Refresh token response status code: ${response.statusCode}');
      print('[DEBUG] Refresh token response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        print(
            '[DEBUG] Received new access token: ${jsonResponse['accessToken']}');
        print(
            '[DEBUG] Received new refresh token: ${jsonResponse['refreshToken']}');

        await _secureStorage.write(
            key: 'accessToken', value: jsonResponse['accessToken']);
        await _secureStorage.write(
            key: 'refreshToken', value: jsonResponse['refreshToken']);

        print('[DEBUG] Tokens refreshed successfully');
        return true;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print(
            '[DEBUG] Token expired or unauthorized. Clearing secure storage.');
        await _secureStorage.deleteAll();
        throw Exception('Token expired. Please log in again.');
      } else {
        print(
            '[DEBUG] Failed to refresh token. Status code: ${response.statusCode}');
        throw Exception('Failed to refresh token');
      }
    } catch (e) {
      print('[DEBUG] Refresh token error: $e');
      return false;
    }
  }

  Future<Map<String, String>> _getHeadersWithAutoRefresh() async {
    try {
      return await _getHeaders();
    } catch (e) {
      print('[DEBUG] Error in getting headers: $e');

      if (e.toString().contains('Authorization token not found') ||
          e.toString().contains('Unauthorized') ||
          e.toString().contains('Invalid token')) {
        try {
          bool refreshed = await _refreshToken();
          if (refreshed) {
            return await _getHeaders();
          }
        } catch (refreshError) {
          print('[DEBUG] Token refresh failed: $refreshError');
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

        print(
            '[DEBUG] Request attempt $attempt, Status: ${response.statusCode}');

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
        print('[DEBUG] Request attempt $attempt failed: $e');

        if (attempt == retries) {
          rethrow;
        }
      }
    }

    throw Exception('Unexpected error during request retry.');
  }

  // Fetch all user tasks without pagination
  Future<List<UserTaskModel>> fetchUserTasks() async {
    print('\n=== Fetching All User Tasks ===');
    await ensureInitialized();

    List<UserTaskModel> allTasks = [];
    int page = 1;
    int pageSize = 100; // Set a large page size to fetch all tasks at once

    try {
      while (true) {
        final response = await _retryRequest(
          () async {
            final headers = await _getHeadersWithAutoRefresh();
            return await http.get(
              Uri.parse('$apiUrl/userTasks/?page=$page&pageSize=$pageSize'),
              headers: headers,
            );
          },
          retries: 2,
        );

        print('📥 Response Status Code: ${response.statusCode}');
        print('📥 Response Body: ${response.body}');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          print('📦 Parsed JSON Response: $jsonResponse');

          List<dynamic> tasksJson = jsonResponse['data']['items'] ?? [];
          print('📋 Tasks Data Length: ${tasksJson.length}');

          if (tasksJson.isEmpty) {
            break; // Exit loop if no more tasks are returned
          }

          allTasks.addAll(tasksJson.map((taskJson) {
            print('📋 Processing task: $taskJson');
            return UserTaskModel.fromJson(taskJson);
          }).toList());

          page++; // Increment page for the next fetch
        } else {
          print('❌ Failed to fetch user tasks: ${response.statusCode}');
          var errorResponse = jsonDecode(response.body);
          print(
              '❌ Error Message: ${errorResponse['message'] ?? response.body}');
          break;
        }
      }
    } catch (e, stackTrace) {
      print('❌ Exception while fetching user tasks:');
      print('Error: $e');
      print('Stack trace: $stackTrace');
    }

    return allTasks;
  }

  // Future<List<UserTaskModel>> fetchUserTasks(
  //     {int page = 1, int pageSize = 10}) async {
  //   print('\n=== Fetching User Tasks ===');
  //   await ensureInitialized();

  //   try {
  //     final response = await _retryRequest(
  //       () async {
  //         final headers = await _getHeadersWithAutoRefresh();
  //         return await http.get(
  //           Uri.parse('$apiUrl/userTasks/?page=$page&pageSize=$pageSize'),
  //           headers: headers,
  //         );
  //       },
  //       retries: 2,
  //     );

  //     print('📥 Response Status Code: ${response.statusCode}');
  //     print('📥 Response Body: ${response.body}');

  //     if (response.statusCode >= 200 && response.statusCode < 300) {
  //       Map<String, dynamic> jsonResponse = jsonDecode(response.body);
  //       print('📦 Parsed JSON Response: $jsonResponse');

  //       List<dynamic> tasksJson = jsonResponse['data']['items'] ?? [];
  //       print('📋 Tasks Data Length: ${tasksJson.length}');

  //       return tasksJson.map((taskJson) {
  //         print('📋 Processing task: $taskJson');
  //         return UserTaskModel.fromJson(taskJson);
  //       }).toList();
  //     } else {
  //       print('❌ Failed to fetch user tasks: ${response.statusCode}');
  //       var errorResponse = jsonDecode(response.body);
  //       print('❌ Error Message: ${errorResponse['message'] ?? response.body}');
  //       return [];
  //     }
  //   } catch (e, stackTrace) {
  //     print('❌ Exception while fetching user tasks:');
  //     print('Error: $e');
  //     print('Stack trace: $stackTrace');
  //     return [];
  //   }
  // }

  Future<void> addUserTask(Map<String, dynamic> taskData) async {
    print("Plant ID: ${taskData['userPlantId']}");
    print('\n=== Adding User Task ===');
    print('Task Data: $taskData');

    await ensureInitialized();

    try {
      final response = await _retryRequest(
        () async {
          final headers = await _getHeadersWithAutoRefresh();
          return await http.post(
            Uri.parse('$apiUrl/userTasks/'),
            headers: headers,
            body: jsonEncode(taskData),
          );
        },
        retries: 2,
      );

      print('📥 Response Status Code: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isNotEmpty) {
          var jsonResponse = jsonDecode(response.body);
          print('✅ Success: ${jsonResponse['message']}');
        } else {
          print(
              '✅ Task added successfully, but no additional details in response.');
        }
      } else {
        print('❌ Failed to add user task: ${response.statusCode}');
        if (response.body.isNotEmpty) {
          try {
            var errorResponse = jsonDecode(response.body);
            print(
                '❌ Error Message: ${errorResponse['message'] ?? response.body}');
          } catch (e) {
            print('❌ Could not parse error response: ${response.body}');
          }
        } else {
          print('❌ No error details provided by server.');
        }
      }
    } catch (e, stackTrace) {
      print('❌ Exception while adding user task:');
      print('Error: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> addCustomTask(Map<String, dynamic> taskData) async {
    print('\n=== Adding Custom Task ===');
    print('Task Data: $taskData');

    await ensureInitialized();

    try {
      final response = await _retryRequest(
        () async {
          final headers = await _getHeadersWithAutoRefresh();
          return await http.post(
            Uri.parse('$apiUrl/userTasks/'),
            headers: headers,
            body: jsonEncode(taskData),
          );
        },
        retries: 2,
      );

      print('📥 Response Status Code: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isNotEmpty) {
          var jsonResponse = jsonDecode(response.body);
          print('✅ Success: ${jsonResponse['message']}');
        } else {
          print(
              '✅ Task added successfully, but no additional details in response.');
        }
      } else {
        print('❌ Failed to add custom task: ${response.statusCode}');
        if (response.body.isNotEmpty) {
          try {
            var errorResponse = jsonDecode(response.body);
            print(
                '❌ Error Message: ${errorResponse['message'] ?? response.body}');
          } catch (e) {
            print('❌ Could not parse error response: ${response.body}');
          }
        } else {
          print('❌ No error details provided by server.');
        }
      }
    } catch (e, stackTrace) {
      print('❌ Exception while adding custom task:');
      print('Error: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> deleteTaskForUser(String taskId) async {
    print('\n=== Deleting User Task ===');
    print('Task ID: $taskId');

    await ensureInitialized();

    try {
      final response = await _retryRequest(
        () async {
          final headers = await _getHeadersWithAutoRefresh();
          return await http.delete(
            Uri.parse('$apiUrl/userTasks/?userTaskId=$taskId'),
            headers: headers,
          );
        },
        retries: 2,
      );

      print('📥 Response Status Code: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        var jsonResponse = jsonDecode(response.body);
        print('✅ Success: ${jsonResponse['message']}');
      } else {
        print('❌ Failed to delete user task: ${response.statusCode}');
        if (response.body.isNotEmpty) {
          try {
            var errorResponse = jsonDecode(response.body);
            print(
                '❌ Error Message: ${errorResponse['message'] ?? response.body}');
          } catch (e) {
            print('❌ Could not parse error response: ${response.body}');
          }
        } else {
          print('❌ No error details provided by server.');
        }
      }
    } catch (e, stackTrace) {
      print('❌ Exception while deleting user task:');
      print('Error: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> completeTask(String taskId) async {
    print('\n=== Completing User Task ===');
    print('Task ID: $taskId');

    await ensureInitialized();

    try {
      final response = await _retryRequest(
        () async {
          final headers = await _getHeadersWithAutoRefresh();
          return await http.put(
            Uri.parse('$apiUrl/userTasks/completeTask?taskId=$taskId'),
            headers: headers,
          );
        },
        retries: 2,
      );

      print('📥 Response Status Code: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        var jsonResponse = jsonDecode(response.body);
        print('✅ Success: ${jsonResponse['message']}');
      } else {
        print('❌ Failed to complete user task: ${response.statusCode}');
        if (response.body.isNotEmpty) {
          try {
            var errorResponse = jsonDecode(response.body);
            print(
                '❌ Error Message: ${errorResponse['message'] ?? response.body}');
          } catch (e) {
            print('❌ Could not parse error response: ${response.body}');
          }
        } else {
          print('❌ No error details provided by server.');
        }
      }
    } catch (e, stackTrace) {
      print('❌ Exception while completing user task:');
      print('Error: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<List<UserTaskModel>> getTaskByUserPlant(String userPlantId) async {
    print('\n=== Fetching Tasks by User Plant ID ===');
    await ensureInitialized();

    try {
      final response = await _retryRequest(
        () async {
          final headers = await _getHeadersWithAutoRefresh();
          return await http.get(
            Uri.parse('$apiUrl/userTasks/getTaskByUserPlant?userPlantId=$userPlantId'),
            headers: headers,
          );
        },
        retries: 2,
      );

      print('📥 Response Status Code: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        print('📦 Parsed JSON Response: $jsonResponse');

        List<dynamic> tasksJson = jsonResponse['data']?? [];
        print('📋 Tasks Data Length: ${tasksJson.length}');

        return tasksJson.map((taskJson) {
          print('📋 Processing task: $taskJson');
          return UserTaskModel.fromJson(taskJson);
        }).toList();
      } else {
        print('❌ Failed to fetch tasks: ${response.statusCode}');
        var errorResponse = jsonDecode(response.body);
        print('❌ Error Message: ${errorResponse['message'] ?? response.body}');
        return [];
      }
    } catch (e, stackTrace) {
      print('❌ Exception while fetching tasks:');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }
}
