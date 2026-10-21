import 'package:material_ui/material_ui.dart';

sealed class PreferencesState {
  const PreferencesState();
}

final class PreferencesInitial extends PreferencesState {
  const new();
}

final class PreferencesLoadingInProgress extends PreferencesState {
  const new();
}

/// Stores all user Preferences.
final class PreferencesLoadSuccess extends PreferencesState {
  const new({required this.userID, required this.themeMode});
  
  /// The ID the server gave this user, or null if not registered yet.
  final String? userID;
  final ThemeMode themeMode;

  PreferencesLoadSuccess copyWith({String? userID, ThemeMode? themeMode}) {
    return PreferencesLoadSuccess(userID: userID ?? this.userID, themeMode: themeMode ?? this.themeMode);
  }
}

final class PreferencesLoadFailure extends PreferencesState {
  const new({required this.exception});
  final Exception exception;
}