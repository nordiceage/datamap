import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:treemate/models/user_model.dart';
import 'package:treemate/providers/user_provider.dart';

class UserController {
  late final String apiUrl;
  // late final String apiKey;
  UserModel? _currentUser;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Initialize the current user from secure storage and update the provider
  Future<void> init(BuildContext context) async {
    apiUrl = '${dotenv.env['API_BASE_URL'] ?? "http://localhost:6555"}/api/v1';
    // apiKey = dotenv.env['AZURE_API_KEY'] ?? "";
    _currentUser = await loadUserDetails(context);
    if (_currentUser != null) {
      Provider.of<UserProvider>(context, listen: false).setUser(_currentUser!);
    }
  }

  // Initiates registration by sending email and mobile
  Future<bool> registerInitiate(String email, BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/register/registerInitiate'),
        headers: {
          // 'api-key': apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'login': email,
        }),
      );

      // Parse the response body to extract data
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseData.containsKey('message')) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(responseData['message'])));
          if (responseData['message'] ==
              "Verification code sent successfully") {
            return true;
          }
        } else {
          print('Unexpected response structure: ${response.body}');
        }
      } else {
        print('Failed to initiate OTP: ${response.body}');
        if (responseData.containsKey('message')) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(responseData['message'])));
        } else {
          print('Unexpected response structure: ${response.body}');
        }
      }
      return false;
    } catch (e) {
      print('Error during OTP initiation: $e');
      return false;
    }
  }

  Future<bool> resendOTP(String email, BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/register/resendOtp'),
        headers: {
          // 'api-key': apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'login': email,
        }),
      );
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(response.body)));
      if (response.statusCode == 200) return true;
    } catch (e) {
      print('Error resending OTP: $e');
      return false;
    }
    return false;
  }

  Future<bool> verifyOTP(String email, String otp, BuildContext context) async {
    print(otp);
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/register/validateVerificationOtp'),
        headers: {
          // 'api-key': apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'login': email,
          'otp': otp,
        }),
      );

      // Parse the response body to extract data
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(responseData['message'])));
      print(response.statusCode);
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print('Error verifying OTP: $e');
      return false;
    }
    return false;
  }

  // Completes the registration process using OTP and other data
  Future<bool> signUp(BuildContext context, String email, String password,
      String fullName) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/register/'),
        headers: {
          // 'api-key': apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'login': email,
          'username': fullName,
          'password': password,
          'confirmPassword': password,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(responseData['message'])));

      if (response.statusCode == 201) {
        print('User registered successfully');
        return true;
      } else {
        print('Failed to register: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error during registration: $e');
      return false;
    }
  }

  // Login method that makes a POST request and saves tokens
  Future<bool> login(
      BuildContext context, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/login/'),
        headers: <String, String>{
          // 'api-key': apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'login': email,
          'password': password,
        }),
      );
      print(response.statusCode);
      print(response.body);
      if (response.body.isNotEmpty) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(responseData['message'])));
        if (response.statusCode == 200) {
          Map<String, dynamic> data = responseData['data'];
          _currentUser = UserModel(
            accessToken: data['accessToken'],
            email: email,
            refreshToken: data['refreshToken'],
            fullName: data['user']['username'],
          );

          await _saveUserDetails(_currentUser!);
          Provider.of<UserProvider>(context, listen: false)
              .setUser(_currentUser!);
          print('User logged in successfully');
          return true;
        } else {
          print('Failed to login: ${response.body}');
        }
      } else {
        print("No response body");
      }
    } catch (e) {
      print('Error during login: $e');
    }
    return false;
  }

  Future<bool> forgotPassword(String email, BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/register/forgotPassword'),
        headers: {
          // 'api-key': apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'login': email,
        }),
      );

      // Parse the response body to extract data
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseData.containsKey('message')) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(responseData['message'])));
          if (responseData['message'] ==
              "password reset otp sent successfully") {
            return true;
          }
        } else {
          print('Unexpected response structure: ${response.body}');
        }
      } else {
        print('Failed to initiate OTP: ${response.body}');
        if (responseData.containsKey('message')) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(responseData['message'])));
        } else {
          print('Unexpected response structure: ${response.body}');
        }
      }
      return false;
    } catch (e) {
      print('Error during OTP initiation: $e');
      return false;
    }
  }

  Future<bool> verifyPasswordResetOTP(
      String email, String otp, BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/register/validatePasswordResetOtp'),
        headers: {
          // 'api-key': apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'login': email,
          'otp': otp,
        }),
      );

      // Parse the response body to extract data
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(responseData['message'])));
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print('Error verifying OTP: $e');
      return false;
    }
    return false;
  }

  Future<bool> resetPassword(
      BuildContext context, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/register/resetPassword'),
        headers: {
          // 'api-key': apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'login': email,
          'password': password,
          'confirmPassword': password,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(responseData['message'])));

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to reset: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error during resetting password: $e');
      return false;
    }
  }

  // Added refresh token for test login logout
  Future<bool> _refreshToken() async {
    try {
      String? refreshToken = await _secureStorage.read(key: 'refreshToken');
      if (refreshToken == null || refreshToken.isEmpty) {
        print('Error: Refresh token not found or is empty.');
        return false;
      }
      if (kDebugMode) {
        print('Refresh Token: $refreshToken');
      }
      final response = await http.post(
        Uri.parse('$apiUrl/auth/refresh-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        String newAccessToken = responseData['accessToken'];

        // Update access token in secure storage
        await _secureStorage.write(key: 'accessToken', value: newAccessToken);

        // Update current user's access token
        if (_currentUser != null) {
          _currentUser = UserModel(
              accessToken: newAccessToken,
              refreshToken: refreshToken,
              email: _currentUser!.email,
              fullName: _currentUser!.fullName,
              profileImage: _currentUser!.profileImage
          );
        }

        print('Access token refreshed successfully');

        if (kDebugMode) {
          print('New Access Token: $newAccessToken');
        }
        return true;
      } else {
        print('Error refreshing token: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception during token refresh: $e');
      return false;
    }
  }

  // updated updateUserDetails token for test login logout
  Future<bool> updateUserDetails(
      BuildContext context, String fullName, String? profileImage) async {
    if (!await isLoggedIn()) {
      print('Error: Access token is not available.');
      return false;
    }
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/profile'),
        headers: {
          'Authorization': 'Bearer ${_currentUser!.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': fullName,
          'profileImage': profileImage,
        }),
      );

      if (response.statusCode == 200) {
        // Update the current user details
        _currentUser = UserModel(
          email: _currentUser!.email,
          fullName: fullName,
          accessToken: _currentUser!.accessToken,
          refreshToken: _currentUser!.refreshToken,
          profileImage: profileImage,
        );

        // Save updated user details
        await _saveUserDetails(_currentUser!);
        Provider.of<UserProvider>(context, listen: false).setUser(_currentUser!);
        print('User details updated successfully');
        return true;
      } else if (response.statusCode == 401) {
        // Attempt to refresh the token
        bool tokenRefreshed = await _refreshToken();
        if (tokenRefreshed) {
          // Retry the request with the new access token
          return await updateUserDetails(context, fullName, profileImage);
        } else {
          // If token refresh fails, log out the user
          await logout(context);
          return false;
        }
      } else {
        print('Failed to update user details: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error during user details update: $e');
      return false;
    }
  }



  // // Function to update user details
  // Future<bool> updateUserDetails(
  //     BuildContext context, String fullName, String? profileImage) async {
  //   if (!await isLoggedIn()) {
  //     print('Error: Access token is not available.');
  //     return false;
  //   }

  //   try {
  //     final response = await http.put(
  //       Uri.parse('$apiUrl/profile'),
  //       headers: {
  //         // 'api-key': apiKey,
  //         'Authorization': 'Bearer ${_currentUser!.accessToken}',
  //         'Content-Type': 'application/json',
  //       },
  //       body: jsonEncode({
  //         'username': fullName,
  //         'profileImage': profileImage,
  //       }),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       // Update the current user details
  //       _currentUser = UserModel(
  //         email: _currentUser!.email,
  //         fullName: fullName,
  //         accessToken: _currentUser!.accessToken,
  //         refreshToken: _currentUser!.refreshToken,
  //         profileImage: profileImage,
  //       );
  //
  //       // Save updated user details
  //       await _saveUserDetails(_currentUser!);
  //       Provider.of<UserProvider>(context, listen: false)
  //           .setUser(_currentUser!);
  //       print('User details updated successfully');
  //       return true;
  //     } else {
  //       print('Failed to update user details: ${response.body}');
  //       return false;
  //     }
  //   } catch (e) {
  //     print('Error during user details update: $e');
  //     return false;
  //   }
  // }


  // updated deleteUser token for test login logout
  Future<bool> deleteUser(BuildContext context) async {
    if (!await isLoggedIn()) {
      print('Error: Access token is not available.');
      return false;
    }
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/register/deleteUser'),
        headers: {
          'Authorization': 'Bearer ${_currentUser!.accessToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        await _secureStorage.deleteAll();
        Provider.of<UserProvider>(context, listen: false).clearUser();
        return true;
      } else if (response.statusCode == 401) {
        // Attempt to refresh the token
        bool tokenRefreshed = await _refreshToken();
        if (tokenRefreshed) {
          // Retry the request with the new access token
          return await deleteUser(context);
        } else {
          // If token refresh fails, log out the user
          await logout(context);
          return false;
        }
      } else {
        print('Failed to delete user: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error during deleting user: $e');
      return false;
    }
  }


  // Store user details securely using Flutter Secure Storage
  Future<void> _saveUserDetails(UserModel user) async {
    await _secureStorage.write(key: 'accessToken', value: user.accessToken);
    await _secureStorage.write(key: 'refreshToken', value: user.refreshToken);
    await _secureStorage.write(key: 'email', value: user.email);
    await _secureStorage.write(key: 'fullName', value: user.fullName);
    await _secureStorage.write(key: 'profileImage', value: user.profileImage);
  }

  // Load stored user details
  Future<UserModel?> loadUserDetails(BuildContext context) async {
    String? accessToken = await _secureStorage.read(key: 'accessToken');
    String? refreshToken = await _secureStorage.read(key: 'refreshToken');
    String? email = await _secureStorage.read(key: 'email');
    String? fullName = await _secureStorage.read(key: 'fullName');
    String? profileImage = await _secureStorage.read(key: 'profileImage');

    if (accessToken != null &&
        refreshToken != null &&
        email != null &&
        fullName != null) {
      _currentUser = UserModel(
          accessToken: accessToken,
          refreshToken: refreshToken,
          email: email,
          fullName: fullName,
          profileImage: profileImage);
      print('User loaded: $_currentUser');
      Provider.of<UserProvider>(context, listen: false).setUser(_currentUser!);
      return _currentUser;
    }
    return null;
  }

  // Clear user details on logout
  Future<void> logout(BuildContext context) async {
    await _secureStorage.deleteAll(); // Clear all stored user details
    Provider.of<UserProvider>(context, listen: false).clearUser();
    print('User logged out and data cleared.');
  }

  // Check if user is already logged in by looking for stored tokens
  Future<bool> isLoggedIn() async {
    String? accessToken = await _secureStorage.read(key: 'accessToken');
    return accessToken != null;
  }

}
