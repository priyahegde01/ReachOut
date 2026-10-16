import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesRepository {
  PreferencesRepository();
  final SharedPreferencesAsync _asyncPreferences = SharedPreferencesAsync();
  static const String _themeModeKey = "theme mode";
  static const String _userIDKey = "user ID";

  ThemeMode? _themeMode;
  int? _userID;

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

  Future<int?> get userID async {
    if (_userID != null) {
      _userID = await _asyncPreferences.getInt(_userIDKey);
    }
    return _userID;
  }

  set userID(int identifier) {
    _asyncPreferences.setInt(_userIDKey, identifier);
  }
}
