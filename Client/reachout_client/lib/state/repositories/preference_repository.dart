import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesRepository {
  PreferencesRepository();
  final SharedPreferencesAsync _asyncPreferences = SharedPreferencesAsync();
  static const String _themeModeKey = "theme mode";
  static const String _userIDKey = "user ID";

  ThemeMode? _themeMode;
  String? _userID;

  Future<ThemeMode?> get themeMode async {
    if (_themeMode == null) {
      final themeModeIndex = await _asyncPreferences.getInt(_themeModeKey);
      if (themeModeIndex != null) {
        _themeMode = ThemeMode.values[themeModeIndex];
      }
    }
    return _themeMode;
  }

  set themeMode(ThemeMode mode) {
    _asyncPreferences.setInt(_themeModeKey, mode.index);
    _themeMode = mode;
  }

  Future<String?> get userID async {
    _userID ??= await _asyncPreferences.getString(_userIDKey);
    return _userID;
  }

  set userID(String identifier) {
    _asyncPreferences.setString(_userIDKey, identifier);
    _userID = identifier;
  }
}
