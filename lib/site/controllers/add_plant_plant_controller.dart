import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:treemate/site/models/add_plant_plant_model.dart';


class AddPlantPlantsController {
  late final String apiUrl;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  bool _isInitialized = false; // To track initialization state


  Future<void> init() async {
    if (!_isInitialized) {
      apiUrl = '${dotenv.env['API_BASE_URL'] ?? "http://localhost:6555"}/api/v1';
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
        print('[DEBUG] Refresh token response status code: ${response.statusCode}');
        print('[DEBUG] Refresh token response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (kDebugMode) {
          print('[DEBUG] Received new access token: ${jsonResponse['accessToken']}');
          print('[DEBUG] Received new refresh token: ${jsonResponse['refreshToken']}');
        }

        // Update both access and refresh tokens
        await _secureStorage.write(key: 'accessToken', value: jsonResponse['accessToken']);
        await _secureStorage.write(key: 'refreshToken', value: jsonResponse['refreshToken']);

        if (kDebugMode) {
          print('[DEBUG] Tokens refreshed successfully');
        }
        return true;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // Token is invalid, force logout
        if (kDebugMode) {
          print('[DEBUG] Token expired or unauthorized. Clearing secure storage.');
        }
        await _secureStorage.deleteAll();
        throw Exception('Token expired. Please log in again.');
      } else {
        if (kDebugMode) {
          print('[DEBUG] Failed to refresh token. Status code: ${response.statusCode}');
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
      {int retries = 1}
      ) async {
    for (int attempt = 0; attempt <= retries; attempt++) {
      try {
        // Use headers with auto-refresh
        final headers = await _getHeadersWithAutoRefresh();

        // Modify requestFunc to use these headers
        final response = await requestFunc();

        if (kDebugMode) {
          print('[DEBUG] Request attempt $attempt, Status: ${response.statusCode}');
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
  // Get all user plants
  Future<List<AddPlantPlantModel>> getAllUserPlants() async {
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
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      List<dynamic> plantsJson = jsonResponse['data'];
      if (plantsJson.isEmpty) {
        print('No user plants found.');
        return [];
      }
      return plantsJson.map((plant) => AddPlantPlantModel.fromJson(plant)).toList();
    } else {
      print('[ERROR] Failed to retrieve user plants: HTTP ${response.statusCode}, Response: ${response.body}');
      throw Exception('Failed to load user plants');
    }
  }

  // Method to add a user plant to a specific site
  Future<bool> addUserPlantToSite(String userPlantId, String? siteId) async {
    print('\n=== Adding User Plant to Site ===');
    print('User Plant ID: $userPlantId');
    print('Site ID: $siteId');
    await ensureInitialized();


    final url = '$apiUrl/userPlants/addSiteToUserPlant';
    print('🌐 Making PUT request to: $url');

    try {
      final headers = await _getHeadersWithAutoRefresh();


      final response = await _retryRequest(
            () async {
          var request = http.MultipartRequest('PUT', Uri.parse(url));
          request.headers.addAll(headers);
          request.fields['userPlantId'] = userPlantId;
          request.fields['siteId'] = siteId ?? "";


          var streamedResponse = await request.send();
          return await http.Response.fromStream(streamedResponse);
        },
        retries: 2,
      );

      print('📥 Response Status Code: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        var jsonResponse = jsonDecode(response.body);
        print('✅ Success: ${jsonResponse['message']}');
        return true;
      } else {
        print('❌ Failed to add user plant to site: ${response.statusCode}');
        var errorResponse = jsonDecode(response.body);
        print('❌ Error Message: ${errorResponse['message'] ?? response.body}');
        return false;
      }
    } catch (e, stackTrace) {
      print('❌ Exception while adding user plant to site:');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }
}