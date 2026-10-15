import 'package:material_ui/material_ui.dart';

sealed class PreferencesState {
  const PreferencesState();
}

final class PreferencesInitial extends PreferencesState {
  const PreferencesInitial();
}

final class PreferencesLoadingInProgress extends PreferencesState {
  const PreferencesLoadingInProgress();
}

/// Stores all user Preferences.
final class PreferencesLoadSuccess extends PreferencesState {
  const PreferencesLoadSuccess({required this.userID, required this.themeMode});
  
  final int userID;
  final ThemeMode themeMode;

  PreferencesLoadSuccess copyWith({int? userID, ThemeMode? themeMode}) {
    return PreferencesLoadSuccess(userID: userID ?? this.userID, themeMode: themeMode ?? this.themeMode);
  }
}

final class PreferencesLoadFailure extends PreferencesState {
  const PreferencesLoadFailure({required this.exception});
  final Exception exception;
}