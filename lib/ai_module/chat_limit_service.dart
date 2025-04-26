// // chat_limit_service.dart
// import 'package:shared_preferences/shared_preferences.dart';
//
// class ChatLimitService {
//   static const String _limitKey = 'chatLimit';
//   static const String _lastResetKey = 'lastReset';
//   static const int _dailyLimit = 20;
//
//   int _chatLimit = _dailyLimit; // Initialize with the daily limit
//   int get chatLimit => _chatLimit;
//
//   Future<void> init() async {
//     await _checkAndResetDailyLimit();
//     await loadChatLimit();
//   }
//
//
//   Future<int> loadChatLimit() async {
//     final prefs = await SharedPreferences.getInstance();
//     _chatLimit = prefs.getInt(_limitKey) ?? _dailyLimit;
//     return _chatLimit;
//   }
//
//
//   Future<void> _checkAndResetDailyLimit() async {
//     final prefs = await SharedPreferences.getInstance();
//     final String? lastResetString = prefs.getString(_lastResetKey);
//     final now = DateTime.now();
//     DateTime? lastReset;
//
//     if (lastResetString != null) {
//       lastReset = DateTime.tryParse(lastResetString);
//     }
//
//     if (lastReset == null || _isNewDay(lastReset, now)) {
//       _chatLimit = _dailyLimit; // Reset the limit
//       await _saveChatLimit();
//       await prefs.setString(_lastResetKey, now.toIso8601String()); // Store current time
//     }
//   }
//
//   bool _isNewDay(DateTime? lastReset, DateTime now) {
//     if (lastReset == null) return true;
//
//     return lastReset.year < now.year ||
//         lastReset.month < now.month ||
//         lastReset.day < now.day;
//
//
//   }
//
//   Future<void> decrementChatLimit() async {
//     if (_chatLimit > 0) {
//       _chatLimit--;
//       await _saveChatLimit();
//     }
//   }
//
//
//   Future<void> setChatLimit(int newLimit) async {
//     _chatLimit = newLimit;
//     await _saveChatLimit();
//   }
//   Future<void> _saveChatLimit() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setInt(_limitKey, _chatLimit);
//   }
//   Future<int> getLimit() async {
//     await loadChatLimit();
//     return _chatLimit;
//   }
// }
// chat_limit_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class ChatLimitService {
  static const String _limitKey = 'chatLimit';
  static const String _lastResetKey = 'lastReset';
  static const String _dataVerificationKey = 'dataVerificationKey';
  static const String _dailyResetVerificationKey = 'dailyResetVerificationKey';
  static const int _dailyLimit = 20;
  static const String _salt = "aVerySecretSaltValue"; // DO NOT hardcode secrets in production apps!

  int _chatLimit = _dailyLimit;
  int get chatLimit => _chatLimit;

  Future<void> init() async {
    await _checkAndResetDailyLimit();
    await loadChatLimit();
  }

  Future<int> loadChatLimit() async {
    final prefs = await SharedPreferences.getInstance();
    _chatLimit = prefs.getInt(_limitKey) ?? _dailyLimit;
    return _chatLimit;
  }

  Future<void> _checkAndResetDailyLimit() async {
    final prefs = await SharedPreferences.getInstance();
    final String? lastResetString = prefs.getString(_lastResetKey);
    final String? storedHash = prefs.getString(_dataVerificationKey);
    final String? storedDailyResetHash = prefs.getString(_dailyResetVerificationKey);


    final now = DateTime.now();
    DateTime? lastReset;

    if (lastResetString != null) {
      lastReset = DateTime.tryParse(lastResetString);
    }


    if (lastReset == null || _isNewDay(lastReset, now) || !_verifyDataIntegrity(lastResetString, storedHash, storedDailyResetHash)) {
      _chatLimit = _dailyLimit;
      await _saveChatLimit();
      final nowString = now.toIso8601String();
      await prefs.setString(_lastResetKey, nowString);
      await _storeDataIntegrity(nowString, true);
    }
    else if(storedDailyResetHash == null) {
      final nowString = now.toIso8601String();
      await _storeDataIntegrity(nowString, true);
    }
  }


  Future<void> _storeDataIntegrity(String timestamp, bool isDailyReset) async {
    final prefs = await SharedPreferences.getInstance();
    final hash = _generateHash(timestamp);
    if(isDailyReset) {
      await prefs.setString(_dailyResetVerificationKey, hash);
    } else {
      await prefs.setString(_dataVerificationKey, hash);
    }
  }

  bool _verifyDataIntegrity(String? timestamp, String? storedHash, String? storedDailyResetHash){
    if(timestamp == null || storedHash == null || storedDailyResetHash == null) return false;

    return _generateHash(timestamp) == storedHash && storedDailyResetHash == _generateHash(_getTodayString());
  }
  String _getTodayString() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).toIso8601String();
  }

  String _generateHash(String timestamp) {
    final bytes = utf8.encode('$timestamp$_salt');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  bool _isNewDay(DateTime? lastReset, DateTime now) {
    if (lastReset == null) return true;

    return lastReset.year < now.year ||
        lastReset.month < now.month ||
        lastReset.day < now.day;
  }

  Future<void> decrementChatLimit() async {
    if (_chatLimit > 0) {
      _chatLimit--;
      await _saveChatLimit();
    }
  }


  Future<void> setChatLimit(int newLimit) async {
    _chatLimit = newLimit;
    await _saveChatLimit();
  }
  Future<void> _saveChatLimit() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_limitKey, _chatLimit);
  }
  Future<int> getLimit() async {
    await loadChatLimit();
    return _chatLimit;
  }
}