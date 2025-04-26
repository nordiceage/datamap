import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'chat_message.dart';

class ChatHistoryService {
  static const String _storageKey = 'chat_history';

  static Future<List<ChatMessage>> loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString(_storageKey);

    if (historyJson == null) return [];

    List<dynamic> historyList = json.decode(historyJson);
    return historyList
        .map((item) => ChatMessage.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveChatHistory(List<ChatMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = json.encode(
      messages.map((message) => message.toMap()).toList(),
    );
    await prefs.setString(_storageKey, historyJson);
  }

  static Future<void> clearChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}