import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:treemate/site/models/add_plant_site_model.dart';

class AddPlantSitesController {
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

  // Fetch all sites for user
  Future<List<AddPlantSiteModel>> getSitesForUser() async {
    final response = await _retryRequest(
          () async {
        final headers = await _getHeadersWithAutoRefresh();
        return await http.get(
          Uri.parse('$apiUrl/sites/getSitesForUser'),
          headers: headers,
        );
      },
      retries: 2, // Retry up to 2 times
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      List<dynamic> sitesJson = jsonResponse['data'];
      if (sitesJson.isEmpty) {
        print('No user sites found.');
        return [];
      }
      return sitesJson.map((site) => AddPlantSiteModel.fromJson(site)).toList();
    } else {
      print('Failed to load user sites: ${response.statusCode}');
      throw Exception('Failed to load user sites');
    }
  }
  // Delete a user's plant site not working todo:
  Future<bool> deletePlantSite(String siteId) async {
    print('\n=== Deleting Plant Site ===');
    print('Site ID: $siteId');
    await init();
    final response = await _retryRequest(
          () async {
        final headers = await _getHeadersWithAutoRefresh();
        return await http.delete(
          Uri.parse('$apiUrl/sites/deleteSiteForUser/$siteId'),
          headers: headers,
        );
      },
      retries: 2, // Retry up to 2 times
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      var jsonResponse = jsonDecode(response.body);
      print('✅ Success: ${jsonResponse['message']}');
      return true;
    } else {
      print('❌ Failed to delete plant site: ${response.statusCode}');
      var errorResponse = jsonDecode(response.body);
      print('❌ Error Message: ${errorResponse['message'] ?? response.body}');
      return false;
    }
  }


}