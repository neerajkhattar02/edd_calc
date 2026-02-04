import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalDataLoader {
  static Future<List<Map<String, dynamic>>> loadStates() async {
    final String jsonString = await rootBundle.loadString('assets/states.json');
    return List<Map<String, dynamic>>.from(json.decode(jsonString));
  }

  static Future<List<Map<String, dynamic>>> loadDistricts() async {
    final String jsonString = await rootBundle.loadString(
      'assets/district.json',
    );
    return List<Map<String, dynamic>>.from(json.decode(jsonString));
  }
}

class LocalStorage {
  static const _userDetailsKey = 'user_details';

  static Future<void> saveUserDetails(Map<String, dynamic> userDetails) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDetailsKey, jsonEncode(userDetails));
  }

  static Future<bool> isUserRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_userDetailsKey);
  }

  static Future<Map<String, dynamic>?> getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_userDetailsKey)) return null;

    final String jsonString = prefs.getString(_userDetailsKey)!;
    return jsonDecode(jsonString);
  }

  static Future<void> clearUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userDetailsKey);
  }
}
