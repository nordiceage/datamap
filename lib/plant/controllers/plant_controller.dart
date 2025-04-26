// plant_controller.dart - Frontend Workaround for Token Refresh Issue
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:treemate/plant/models/plant_model.dart';
import '../models/plant_category_model.dart';

class PlantsController {
  late final String apiUrl;
  bool _isInitialized = false; // To track initialization state
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Initialize apiUrl from .env file
  Future<void> init() async {
    // apiUrl = '${dotenv.env['API_BASE_URL'] ?? "http://localhost:6555"}/api/v1';
    if (!_isInitialized) {
      apiUrl =
          '${dotenv.env['API_BASE_URL'] ?? "http://localhost:6555"}/api/v1';
      _isInitialized = true;
      print("[DEBUG] API URL initialized: $apiUrl");
    }
  }

  Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      await init();
    }
  }

  // Helper method to get authorization headers
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

  // new test
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

        // Update both access and refresh tokens
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

  // old working
  // Helper method to get headers with automatic token refresh and retry logic
  // Future<Map<String, String>> _getHeadersWithAutoRefresh() async {
  //   try {
  //     return await _getHeaders();
  //   } catch (e) {
  //     if (e.toString().contains('Authorization token not found')) {
  //       bool refreshed = await _refreshToken();
  //       if (refreshed) {
  //         return await _getHeaders();
  //       } else {
  //         throw Exception('Failed to refresh token. Please log in again.');
  //       }
  //     } else {
  //       rethrow;
  //     }
  //   }
  // }
  //
  // // Enhanced retry logic for API requests
  // Future<http.Response> _retryRequest(Future<http.Response> Function() requestFunc,
  //     {int retries = 1}) async {
  //   http.Response response;
  //   for (int attempt = 0; attempt <= retries; attempt++) {
  //     response = await requestFunc();
  //     if (response.statusCode != 401 || attempt == retries) {
  //       return response;
  //     }
  //     bool refreshed = await _refreshToken();
  //     if (!refreshed) {
  //       throw Exception('Failed to refresh token. Please log in again.');
  //     }
  //   }
  //   throw Exception('Unexpected error during request retry.');
  // }
  // test new
  Future<Map<String, String>> _getHeadersWithAutoRefresh() async {
    try {
      return await _getHeaders();
    } catch (e) {
      if (kDebugMode) {
        print('[DEBUG] Error in getting headers: $e');
      }

      // More comprehensive error checking
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

        // Clear tokens if refresh fails
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
        // Use headers with auto-refresh
        final headers = await _getHeadersWithAutoRefresh();

        // Modify requestFunc to use these headers
        final response = await requestFunc();

        if (kDebugMode) {
          print(
              '[DEBUG] Request attempt $attempt, Status: ${response.statusCode}');
        }

        // Successful response
        if (response.statusCode < 400) {
          return response;
        }

        // Handle specific error scenarios
        if (response.statusCode == 401 || response.statusCode == 403) {
          if (attempt == retries) {
            // Last attempt failed
            await _secureStorage.deleteAll();
            throw Exception('Authentication failed after $retries attempts.');
          }

          // Try refreshing token
          bool refreshed = await _refreshToken();
          if (!refreshed) {
            await _secureStorage.deleteAll();
            throw Exception('Failed to refresh token. Please log in again.');
          }

          // Continue to next iteration to retry
          continue;
        }

        // For other error codes, return the response
        return response;
      } catch (e) {
        if (kDebugMode) {
          print('[DEBUG] Request attempt $attempt failed: $e');
        }

        // Last attempt
        if (attempt == retries) {
          rethrow;
        }
      }
    }

    throw Exception('Unexpected error during request retry.');
  }

  // Fetch all plants with pagination support
  Future<List<PlantModel>> getPlants({int page = 1, int limit = 10}) async {
    final response = await _retryRequest(
      () async {
        final headers = await _getHeadersWithAutoRefresh();
        return await http.get(
          Uri.parse('$apiUrl/plants/?page=$page&limit=$limit'),
          headers: headers,
        );
      },
      retries: 2, // Retry up to 2 times
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      List<dynamic> plantsJson = jsonResponse['data']['items'];
      if (plantsJson.isEmpty) {
        print('[INFO] No plants were retrieved from the server.');
        return [];
      }
      return plantsJson.map((plant) => PlantModel.fromJson(plant)).toList();
    } else {
      print(
          '[ERROR] Failed to fetch plants: HTTP ${response.statusCode}, Response: ${response.body}');
      throw Exception('Failed to load plants');
    }
  }

  // Custom header for getting plant by id working
  // Future<Map<String, String>> _getHeadersForPlantById() async {
  //   String? token = await _secureStorage.read(key: 'access_token');
  //
  //   if (token == null || token.isEmpty) {
  //     print("[DEBUG] Token is empty, refreshing...");
  //     final refreshed = await _refreshToken(); // Refresh token logic
  //     if (!refreshed) {
  //       throw Exception('Token refresh failed. Please log in again.');
  //     }
  //     token = await _secureStorage.read(key: 'access_token');
  //   }
  //   print("[DEBUG] Access Token retrieved successfully for Plant by ID: $token");
  //   return {
  //     'Authorization': 'Bearer $token',
  //     'Content-Type': 'application/json',
  //   };
  // }
  //
  //
  //
  //
  // // Fetch plant details by ID
  // Future<PlantModel> getPlantById(String id) async {
  //   final response = await _retryRequest(
  //         () async {
  //       // final headers = await _getHeadersWithAutoRefresh();
  //           final headers = await _getHeadersForPlantById();// Using the custom headers here
  //       return await http.get(
  //         Uri.parse('$apiUrl/plants/$id'),
  //         headers: headers,
  //       );
  //     },
  //     retries: 2, // Retry up to 2 times
  //   );
  //   if (response.statusCode == 200) {
  //     print("[DEBUG] API Response: ${response.body}");
  //     final jsonResponse = json.decode(response.body);
  //     return PlantModel.fromJson(jsonResponse);
  //   } else {
  //     print('Error fetching plant by ID: ${response.statusCode} - ${response.body}');
  //     throw Exception('Failed to load plant details');
  //   }
  // }
  Future<Map<String, String>> _getHeadersForPlantById() async {
    await ensureInitialized(); // Ensure apiUrl is initialized

    try {
      String? token = await _secureStorage.read(
          key: 'accessToken'); // Note: Changed from 'access_token'

      if (token == null || token.isEmpty) {
        if (kDebugMode) {
          print("[DEBUG] Token is empty, attempting to refresh...");
        }

        // Attempt to refresh the token
        bool refreshed = await _refreshToken();
        if (!refreshed) {
          throw Exception('Token refresh failed. Please log in again.');
        }

        // Re-read the token after refresh
        token = await _secureStorage.read(key: 'accessToken');
      }

      if (token == null || token.isEmpty) {
        throw Exception('Unable to retrieve a valid access token');
      }

      if (kDebugMode) {
        print("[DEBUG] Access Token retrieved successfully for Plant by ID");
      }

      return {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
    } catch (e) {
      if (kDebugMode) {
        print("[ERROR] Error in getting headers for Plant by ID: $e");
      }
      rethrow;
    }
  }

  Future<PlantModel> getPlantById(String id) async {
    await ensureInitialized(); // Ensure apiUrl is initialized

    try {
      final response = await _retryRequest(
        () async {
          final headers = await _getHeadersForPlantById();
          return await http.get(
            Uri.parse('$apiUrl/plants/$id'),
            headers: headers,
          );
        },
        retries: 2, // Retry up to 2 times
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (kDebugMode) {
          print("[DEBUG] API Response for Plant by ID: ${response.body}");
        }
        final jsonResponse = json.decode(response.body);
        return PlantModel.fromJson(jsonResponse['data']);
      } else {
        if (kDebugMode) {
          print(
              'Error fetching plant by ID: ${response.statusCode} - ${response.body}');
        }
        throw Exception('Failed to load plant details');
      }
    } catch (e) {
      if (kDebugMode) {
        print("[ERROR] Exception in getPlantById: $e");
      }
      rethrow;
    }
  }

  // Fetch all plant categories
  Future<List<PlantCategory>> getAllCategories(
      {int page = 1, int limit = 10}) async {
    final response = await _retryRequest(
      () async {
        final headers = await _getHeadersWithAutoRefresh();
        return await http.get(
          Uri.parse(
              '$apiUrl/plantCategories/getAllCategories?page=$page&limit=$limit'),
          headers: headers,
        );
      },
      retries: 2, // Retry up to 2 times
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      List<dynamic> categoriesJson = jsonResponse['data']['items'];
      if (categoriesJson.isEmpty) {
        print('No categories found.');
        return [];
      }
      return categoriesJson
          .map((category) => PlantCategory.fromJson(category))
          .toList();
    } else {
      print(
          '[ERROR] Failed to fetch plant categories: HTTP ${response.statusCode}, Response: ${response.body}');
      throw Exception('Failed to load categories');
    }
  }

  // Add a new plant category
  Future<void> addPlantCategory(String name, String imagePath) async {
    final response = await _retryRequest(
      () async {
        final headers = await _getHeadersWithAutoRefresh();
        final request = http.MultipartRequest(
            'POST', Uri.parse('$apiUrl/plantCategories/addCategory'));
        request.headers.addAll(headers);
        request.fields['name'] = name;
        request.files
            .add(await http.MultipartFile.fromPath('image', imagePath));
        return await http.Response.fromStream(await request.send());
      },
      retries: 2, // Retry up to 2 times
    );

    if (response.statusCode != 200) {
      print(
          '[ERROR] Failed to add a plant category: HTTP ${response.statusCode}.');
      throw Exception('Failed to add plant category');
    }
  }

  // Update plant category image by ID
  Future<void> updatePlantCategoryImage(String id, String imagePath) async {
    final response = await _retryRequest(
      () async {
        final headers = await _getHeadersWithAutoRefresh();
        final request = http.MultipartRequest('PUT',
            Uri.parse('$apiUrl/plantCategories/updateCategoryImage/$id'));
        request.headers.addAll(headers);
        request.files
            .add(await http.MultipartFile.fromPath('image', imagePath));
        return await http.Response.fromStream(await request.send());
      },
      retries: 2, // Retry up to 2 times
    );

    if (response.statusCode != 200) {
      print(
          '[ERROR] Failed to update plant category image: HTTP ${response.statusCode}.');
      throw Exception('Failed to update plant category image');
    }
  }

  // Get all user plants
  // Future<List<PlantModel>> getAllUserPlants() async {
  //   final response = await _retryRequest(
  //         () async {
  //       final headers = await _getHeadersWithAutoRefresh();
  //       return await http.get(
  //         Uri.parse('$apiUrl/userPlants/getAllUserPlants'),
  //         headers: headers,
  //       );
  //     },
  //     retries: 2, // Retry up to 2 times
  //   );
  //   print('[DEBUG] API Response: ${response.body}');
  //   if (response.statusCode == 200) {
  //     final jsonResponse = json.decode(response.body);
  //     List<dynamic> plantsJson = jsonResponse['data'];
  //     if (plantsJson.isEmpty) {
  //       print('No user plants found.');
  //       print('No user plants found. Response: ${response.body} ');
  //       return [];
  //     }
  //     print('[DEBUG] API Response for User Plant: ${response.body}');
  //     return plantsJson.map((plant) => PlantModel.fromJson(plant)).toList();
  //   } else {
  //     print('[ERROR] Failed to retrieve user plants: HTTP ${response.statusCode}, Response: ${response.body}');
  //     throw Exception('Failed to load user plants');
  //   }
  // }
  Future<List<PlantModel>> getAllUserPlants() async {
    final response = await _retryRequest(
      () async {
        final headers = await _getHeadersWithAutoRefresh();
        return await http.get(
          Uri.parse('$apiUrl/userPlants/getAllUserPlants'),
          headers: headers,
        );
      },
      retries: 2, // Retry up to 2 times
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      List<dynamic> plantsJson = jsonResponse['data'];
      if (plantsJson.isEmpty) {
        print('No user plants found.');
        return [];
      }
      return plantsJson.map((plant) => PlantModel.fromJson(plant)).toList();
    } else {
      print(
          '[ERROR] Failed to retrieve user plants: HTTP ${response.statusCode}, Response: ${response.body}');
      throw Exception('Failed to load user plants');
    }
  }

  Future<void> deleteUserPlant(String plantId) async {
    await ensureInitialized();

    try {
      final headers = await _getHeadersWithAutoRefresh();
      final request = http.MultipartRequest(
          'DELETE', Uri.parse('$apiUrl/userPlants/deleteUserPlant'));
      request.headers.addAll(headers);
      request.fields['plantId'] = plantId;

      final response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 200) {
        print('Plant removed successfully');
      } else {
        print('Failed to remove plant: ${response.statusCode}');
        print('Response: ${response.body}');
        throw Exception('Failed to remove plant');
      }
    } catch (e) {
      print('Exception while removing plant: $e');
      rethrow;
    }
  }
}
