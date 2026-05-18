import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userKey = 'user_data';
  static const String _tokenKey = 'auth_token';

  static const String _userIdKey = 'user_id';
  static const String _firstNameKey = 'first_name';
  static const String _lastNameKey = 'last_name';
  static const String _fullNameKey = 'full_name';
  static const String _emailKey = 'email';
  static const String _genderKey = 'gender';
  static const String _postpartumModeKey = 'postpartum_mode';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _profileImageKey = 'profile_image';
  static const String _emojiKey = 'emoji'; // ✅ NEW

  // ─── Save Session ─────────────────────────────────────────────────────────
  static Future<void> saveUserSession(Map<String, dynamic>? user,
      {String? token}) async {
    if (user == null) {
      print('SESSION SAVE FAILED: USER IS NULL');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      final firstName = user['first_name']?.toString().trim() ?? '';
      final lastName  = user['last_name']?.toString().trim() ?? '';
      final fullName  = '$firstName $lastName'.trim();
      final emoji     = user['emoji']?.toString().trim() ?? ''; // ✅ NEW

      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_userKey, jsonEncode(user));

      await prefs.setInt(_userIdKey, user['id'] ?? 0);
      await prefs.setString(_firstNameKey, firstName);
      await prefs.setString(_lastNameKey, lastName);
      await prefs.setString(_fullNameKey, fullName);
      await prefs.setString(_emailKey, user['email']?.toString() ?? '');
      await prefs.setString(_genderKey, user['gender']?.toString() ?? '');
      await prefs.setString(_emojiKey, emoji); // ✅ NEW
      await prefs.setInt(
        _postpartumModeKey,
        int.tryParse(user['postpartum_mode']?.toString() ?? '0') ?? 0,
      );
      await prefs.setInt(
        _notificationsEnabledKey,
        int.tryParse(user['notifications_enabled']?.toString() ?? '0') ?? 0,
      );
      await prefs.setString(
        _profileImageKey,
        user['profile_image']?.toString() ?? '',
      );

      if (token != null && token.trim().isNotEmpty) {
        await prefs.setString(_tokenKey, token.trim());
        print('TOKEN SAVED: $token');
      }

      print('SESSION SAVED SUCCESSFULLY');
      print('USER ID: ${user['id']}');
      print('FIRST NAME: $firstName');
      print('LAST NAME: $lastName');
      print('FULL NAME: $fullName');
      print('EMAIL: ${user['email']}');
      print('EMOJI: $emoji'); // ✅ NEW
      print('POSTPARTUM MODE: ${user['postpartum_mode']}');
    } catch (e) {
      print('SESSION SAVE ERROR: $e');
    }
  }

  // ─── Get Token ────────────────────────────────────────────────────────────
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      print('GET TOKEN: $token');
      return token;
    } catch (e) {
      print('GET TOKEN ERROR: $e');
      return null;
    }
  }

  // ─── Save Token ───────────────────────────────────────────────────────────
  static Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token.trim());
      print('TOKEN SAVED SEPARATELY: $token');
    } catch (e) {
      print('SAVE TOKEN ERROR: $e');
    }
  }

  // ─── Get User ─────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString(_userKey);

      if (userString == null || userString.isEmpty) {
        print('NO USER FOUND IN SESSION');
        return null;
      }

      final decodedUser = jsonDecode(userString);

      if (decodedUser is Map<String, dynamic>) {
        print('SESSION USER FETCHED: $decodedUser');
        return decodedUser;
      }

      print('SESSION USER FORMAT INVALID');
      return null;
    } catch (e) {
      print('GET USER ERROR: $e');
      return null;
    }
  }

  // ─── Is Logged In ─────────────────────────────────────────────────────────
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // ─── Get User ID ──────────────────────────────────────────────────────────
  static Future<int> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey) ?? 0;
  }

  // ─── Get First Name ───────────────────────────────────────────────────────
  static Future<String> getFirstName() async {
    final prefs = await SharedPreferences.getInstance();
    final firstName = prefs.getString(_firstNameKey) ?? '';

    if (firstName.trim().isNotEmpty) {
      return firstName.trim().split(' ').first;
    }

    final user = await getUser();
    final rawName = user?['first_name']?.toString().trim() ?? '';

    return rawName.isNotEmpty ? rawName.split(' ').first : '';
  }

  // ─── Get Last Name ────────────────────────────────────────────────────────
  static Future<String> getLastName() async {
    final prefs = await SharedPreferences.getInstance();
    final lastName = prefs.getString(_lastNameKey) ?? '';

    if (lastName.trim().isNotEmpty) {
      return lastName.trim();
    }

    final user = await getUser();
    return user?['last_name']?.toString().trim() ?? '';
  }

  // ─── Get Full Name ────────────────────────────────────────────────────────
  static Future<String> getFullName() async {
    final prefs = await SharedPreferences.getInstance();
    final fullName = prefs.getString(_fullNameKey) ?? '';

    if (fullName.trim().isNotEmpty) {
      return fullName.trim();
    }

    final firstName = await getFirstName();
    final lastName  = await getLastName();

    return '$firstName $lastName'.trim();
  }

  // ─── Get Email ────────────────────────────────────────────────────────────
  static Future<String> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_emailKey) ?? '';

    if (email.trim().isNotEmpty) {
      return email.trim();
    }

    final user = await getUser();
    return user?['email']?.toString().trim() ?? '';
  }

  // ─── Get Gender ───────────────────────────────────────────────────────────
  static Future<String> getGender() async {
    final prefs = await SharedPreferences.getInstance();
    final gender = prefs.getString(_genderKey) ?? '';

    if (gender.trim().isNotEmpty) {
      return gender.trim();
    }

    final user = await getUser();
    return user?['gender']?.toString().trim() ?? '';
  }

  // ─── Get Emoji ✅ NEW ─────────────────────────────────────────────────────
  static Future<String> getEmoji() async {
    final prefs = await SharedPreferences.getInstance();
    final emoji = prefs.getString(_emojiKey) ?? '';

    if (emoji.trim().isNotEmpty) {
      return emoji.trim();
    }

    final user = await getUser();
    return user?['emoji']?.toString().trim() ?? '🌸';
  }

  // ─── Get Postpartum Mode ──────────────────────────────────────────────────
  static Future<int> getPostpartumMode() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getInt(_postpartumModeKey);

    if (mode != null) {
      return mode;
    }

    final user = await getUser();
    return int.tryParse(user?['postpartum_mode']?.toString() ?? '0') ?? 0;
  }

  // ─── Get Notifications Enabled ────────────────────────────────────────────
  static Future<int> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt(_notificationsEnabledKey);

    if (value != null) {
      return value;
    }

    final user = await getUser();
    return int.tryParse(user?['notifications_enabled']?.toString() ?? '0') ?? 0;
  }

  // ─── Get Profile Image ────────────────────────────────────────────────────
  static Future<String> getProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final image = prefs.getString(_profileImageKey) ?? '';

    if (image.trim().isNotEmpty) {
      return image.trim();
    }

    final user = await getUser();
    return user?['profile_image']?.toString().trim() ?? '';
  }

  // ─── Update User Session ──────────────────────────────────────────────────
  static Future<void> updateUserSession(Map<String, dynamic> updatedUser) async {
    await saveUserSession(updatedUser);
    print('SESSION UPDATED SUCCESSFULLY');
  }

  // ─── Update User ✅ NEW ───────────────────────────────────────────────────
  static Future<void> updateUser(Map<String, dynamic> updatedUser) async {
    await saveUserSession(updatedUser);
    print('USER UPDATED IN SESSION');
  }

  // ─── Clear Session ────────────────────────────────────────────────────────
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_userKey);
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_firstNameKey);
    await prefs.remove(_lastNameKey);
    await prefs.remove(_fullNameKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_genderKey);
    await prefs.remove(_emojiKey);  // ✅ NEW
    await prefs.remove(_postpartumModeKey);
    await prefs.remove(_notificationsEnabledKey);
    await prefs.remove(_profileImageKey);

    print('SESSION CLEARED SUCCESSFULLY');
  }
}