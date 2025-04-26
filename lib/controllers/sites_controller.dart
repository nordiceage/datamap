// New improved for debugging
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:treemate/models/site_model.dart';

class SitesController {
  late final String apiUrl;
  bool _isInitialized = false; // To track initialization state
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Initialize apiUrl from .env file
  Future<void> init() async {
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
      print('[DEBUG] Error type: ${e.runtimeType}');
      print('[DEBUG] Full error details: ${e.toString()}');
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

  Future<List<SiteModel>> getPlantSites() async {
    print('\n=== Getting Plant Sites ===');
    await ensureInitialized();
    final response = await _retryRequest(
      () async {
        final headers = await _getHeadersWithAutoRefresh();
        return await http.get(
          Uri.parse('$apiUrl/sites/getAllSites'),
          headers: headers,
        );
      },
      retries: 2,
    );

    print('📥 Response Status Code: ${response.statusCode}');
    print('📥 Response Headers: ${response.headers}');
    print('📥 Response Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print('📦 Parsed JSON Response: $jsonResponse');

      List<dynamic> sitesJson = jsonResponse['data'] ?? [];
      print('📋 Sites Data Length: ${sitesJson.length}');

      final sites = sitesJson.map((siteJson) {
        print('🏢 Processing site: $siteJson');
        return SiteModel.fromJson(siteJson);
      }).toList();

      print('✅ Successfully retrieved ${sites.length} sites');
      return sites;
    } else {
      print('❌ Failed to fetch plant sites: ${response.statusCode}');
      var errorResponse = jsonDecode(response.body);
      print('❌ Error Message: ${errorResponse['message'] ?? response.body}');
      return [];
    }
  }

  Future<List<SiteModel>> getDefaultPlantSites() async {
    print('\n=== Getting Default Plant Sites ===');
    await ensureInitialized();
    final response = await _retryRequest(
      () async {
        final headers = await _getHeadersWithAutoRefresh();
        return await http.get(
          Uri.parse('$apiUrl/sites/getDefaultSites'),
          headers: headers,
        );
      },
      retries: 2,
    );

    print('📥 Response Status Code: ${response.statusCode}');
    print('📥 Response Headers: ${response.headers}');
    print('📥 Response Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      List<dynamic> defaultSitesJson = jsonResponse['data'] ?? [];
      print('📋 Default Sites Data Length: ${defaultSitesJson.length}');

      final sites = defaultSitesJson.map((siteJson) {
        print('🏢 Processing default site: $siteJson');
        return SiteModel.fromJson(siteJson as Map<String, dynamic>);
      }).toList();

      print('✅ Successfully retrieved ${sites.length} default sites');
      return sites;
    } else {
      print('❌ Failed to fetch default plant sites: ${response.statusCode}');
      var errorResponse = jsonDecode(response.body);
      print('❌ Error Message: ${errorResponse['message'] ?? response.body}');
      return [];
    }
  }

  Future<bool> addPlantSite(BuildContext context, String siteName,
      String siteType, File image) async {
    print('\n=== Adding Plant Site ===');
    print('Site Name: $siteName');
    print('Site Type: $siteType');
    print('Image Path: ${image.path}');

    await ensureInitialized();
    final response = await _retryRequest(
      () async {
        final headers = await _getHeadersWithAutoRefresh();
        var request = http.MultipartRequest(
            'POST', Uri.parse('$apiUrl/sites/addSiteForUser'));

        request.fields['site_name'] = siteName;
        request.fields['site_type'] = siteType;

        print('📦 Site Name: $siteName');
        print('📦 Site Type: $siteType');

        request.headers.addAll(headers);
        request.files
            .add(await http.MultipartFile.fromPath('image', image.path));

        print('📤 Sending multipart request...');
        return await http.Response.fromStream(await request.send());
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
      print('❌ Failed to add plant site: ${response.statusCode}');
      var errorResponse = jsonDecode(response.body);
      print('❌ Error Message: ${errorResponse['message'] ?? response.body}');
      return false;
    }
  }

  Future<bool> deletePlantSite(String siteId) async {
    print('\n=== Deleting Plant Site ===');
    print('Site ID: $siteId');
    await ensureInitialized();
    final response = await _retryRequest(
      () async {
        final headers = await _getHeadersWithAutoRefresh();
        return await http.delete(
          Uri.parse('$apiUrl/sites/deleteSiteForUser/$siteId'),
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
      return true;
    } else {
      print('❌ Failed to delete plant site: ${response.statusCode}');
      var errorResponse = jsonDecode(response.body);
      print('❌ Error Message: ${errorResponse['message'] ?? response.body}');
      return false;
    }
  }

  Future<List<SiteModel>> getSitesForUser() async {
    print('\n=== Getting Sites for User ===');
    await ensureInitialized();
    final response = await _retryRequest(
      () async {
        final headers = await _getHeadersWithAutoRefresh();
        return await http.get(
          Uri.parse('$apiUrl/sites/getSitesForUser'),
          headers: headers,
        );
      },
      retries: 2,
    );

    print('📥 Response Status Code: ${response.statusCode}');
    print('📥 Response Headers: ${response.headers}');
    print('📥 Response Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print('📦 Parsed JSON Response: $jsonResponse');

      List<dynamic> sitesJson = jsonResponse['data'] ?? [];
      print('📋 Sites Data Length: ${sitesJson.length}');

      final sites = sitesJson.map((siteJson) {
        print('🏢 Processing site: $siteJson');
        return SiteModel.fromJson(siteJson);
      }).toList();

      print('✅ Successfully retrieved ${sites.length} sites for user');
      return sites;
    } else {
      print('❌ Failed to fetch user-specific sites: ${response.statusCode}');
      var errorResponse = jsonDecode(response.body);
      print('❌ Error Message: ${errorResponse['message'] ?? response.body}');
      return [];
    }
  }

  Future<bool> addUserPlantToSite(String userPlantId, String? siteId) async {
    print('\n=== Adding User Plant to Site ===');
    print('User Plant ID: $userPlantId');
    print('Site ID: $siteId');

    await ensureInitialized();
    final response = await _retryRequest(
      () async {
        final headers = await _getHeadersWithAutoRefresh();
        print(headers.toString());
        var request = http.MultipartRequest(
            'PUT', Uri.parse('$apiUrl/userPlants/addSiteToUserPlant'));

        request.fields['userPlantId'] = userPlantId;
        request.fields['siteId'] = siteId??"";

        print('📦 User Plant ID: $userPlantId');
        print('📦 Site ID: $siteId');

        request.headers.addAll(headers);

        print('📤 Sending multipart request...');
        return await http.Response.fromStream(await request.send());
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
  }
}
