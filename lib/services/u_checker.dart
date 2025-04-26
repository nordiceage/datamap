import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


///this is a critical file do not edit
class UpdateChecker {
  static const String LAST_CHECKED_VERSION_KEY = 'last_checked_version';
  static const String VERSION_CHECK_URL = 'https://master-dipankar.github.io/treemate_version/version.json';

  static Future<bool> checkForUpdate(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version;

    try {
      String latestVersion = await fetchLatestVersion();
      await prefs.setString(LAST_CHECKED_VERSION_KEY, latestVersion);

      if (isUpdateRequired(currentVersion, latestVersion)) {
        showUpdateDialog(context);
        return false;
      }
    } catch (e) {
      print("Error checking for updates: $e");
      // If there's an error, check the last known version
      String? lastCheckedVersion = prefs.getString(LAST_CHECKED_VERSION_KEY);
      if (lastCheckedVersion != null && isUpdateRequired(currentVersion, lastCheckedVersion)) {
        showUpdateDialog(context);
        return false;
      }
    }

    return true;
  }

  static Future<String> fetchLatestVersion() async {
    final response = await http.get(Uri.parse(VERSION_CHECK_URL));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['latest_version'];
    } else {
      throw Exception('Failed to fetch latest version');
    }
  }

  static bool isUpdateRequired(String currentVersion, String latestVersion) {
    List<int> current = currentVersion.split('.').map(int.parse).toList();
    List<int> latest = latestVersion.split('.').map(int.parse).toList();

    for (int i = 0; i < current.length && i < latest.length; i++) {
      if (latest[i] > current[i]) return true;
      if (latest[i] < current[i]) return false;
    }
    return latest.length > current.length;
  }

  static void showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: const Text('Update Required'),
            content: const Text('A new version of the app is available. Please update to continue using the app.'),
            actions: <Widget>[
              TextButton(
                child: const Text('Update'),
                onPressed: () async {
                  PackageInfo packageInfo = await PackageInfo.fromPlatform();
                  final url = 'market://details?id=${packageInfo.packageName}';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url));
                  } else {
                    final playStoreUrl = 'https://play.google.com/store/apps/details?id=${packageInfo.packageName}';
                    if (await canLaunchUrl(Uri.parse(playStoreUrl))) {
                      await launchUrl(Uri.parse(playStoreUrl));
                    } else {
                      throw 'Could not launch $playStoreUrl';
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}