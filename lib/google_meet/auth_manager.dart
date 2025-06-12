import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AuthManager {
  static const String _keyUserData = 'google_user_data';
  static const String _keyAuthTokens = 'google_auth_tokens';
  static const String _keySignInTime = 'google_sign_in_time';

  // Save user authentication data
  static Future<void> saveUserAuth({
    required String email,
    required String displayName,
    required String accessToken,
    String? refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    final userData = {
      'email': email,
      'displayName': displayName,
      'signInTime': DateTime.now().millisecondsSinceEpoch,
    };
    
    final authTokens = {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'tokenTime': DateTime.now().millisecondsSinceEpoch,
    };

    await prefs.setString(_keyUserData, json.encode(userData));
    await prefs.setString(_keyAuthTokens, json.encode(authTokens));
    await prefs.setInt(_keySignInTime, DateTime.now().millisecondsSinceEpoch);
  }

  // Get saved user data
  static Future<Map<String, dynamic>?> getSavedUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_keyUserData);
    
    if (userDataString != null) {
      return json.decode(userDataString);
    }
    return null;
  }

  // Get saved auth tokens
  static Future<Map<String, dynamic>?> getSavedAuthTokens() async {
    final prefs = await SharedPreferences.getInstance();
    final authTokensString = prefs.getString(_keyAuthTokens);
    
    if (authTokensString != null) {
      return json.decode(authTokensString);
    }
    return null;
  }

  // Check if tokens are still valid (not expired)
  static Future<bool> areTokensValid() async {
    final tokens = await getSavedAuthTokens();
    if (tokens == null) return false;
    
    final tokenTime = tokens['tokenTime'] as int?;
    if (tokenTime == null) return false;
    
    // Tokens are typically valid for 1 hour, check if they're still valid
    final tokenDateTime = DateTime.fromMillisecondsSinceEpoch(tokenTime);
    final now = DateTime.now();
    final difference = now.difference(tokenDateTime);
    
    // Consider tokens valid for 50 minutes to have some buffer
    return difference.inMinutes < 50;
  }

  // Check if user has signed in recently (within last 30 days)
  static Future<bool> hasRecentSignIn() async {
    final prefs = await SharedPreferences.getInstance();
    final signInTime = prefs.getInt(_keySignInTime);
    
    if (signInTime == null) return false;
    
    final signInDateTime = DateTime.fromMillisecondsSinceEpoch(signInTime);
    final now = DateTime.now();
    final difference = now.difference(signInDateTime);
    
    // Consider sign-in recent if within 30 days
    return difference.inDays < 30;
  }

  // Clear saved authentication data
  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserData);
    await prefs.remove(_keyAuthTokens);
    await prefs.remove(_keySignInTime);
  }

  // Get user display info for UI
  static Future<String?> getUserDisplayName() async {
    final userData = await getSavedUserData();
    return userData?['displayName'];
  }

  static Future<String?> getUserEmail() async {
    final userData = await getSavedUserData();
    return userData?['email'];
  }
}