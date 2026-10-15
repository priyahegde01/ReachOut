import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reachout_client/state/models/preferences.dart';
import 'package:reachout_client/state/repositories/preference_repository.dart';

/// Manages the state of the user's settings
///
/// This includes things such as loading settings and updating settings.
class PreferencesCubit extends Cubit<PreferencesState> {
  PreferencesCubit(this._repository) : super(const PreferencesInitial()) {
    loadPreferences();
  }

  final PreferencesRepository _repository;

  Future<void> loadPreferences() async {
    emit(const PreferencesLoadingInProgress());

    try {
      final userID = await _repository.userID;
      final themeMode = await _repository.themeMode;

      emit(PreferencesLoadSuccess(userID: userID ?? -1, themeMode: themeMode ?? .system));
    } on Exception catch (e) {
      emit(PreferencesLoadFailure(exception: e));
    }
  }

  void switchThemeMode() {
    if (state is PreferencesLoadSuccess) {
      final currentMode = (state as PreferencesLoadSuccess).themeMode;
      final values = ThemeMode.values;
      themeMode = values[currentMode.index + 1 >= values.length ? 0 : currentMode.index + 1];
    }
  }

  set themeMode(ThemeMode mode) {
    if (state is PreferencesLoadSuccess) {
      emit((state as PreferencesLoadSuccess).copyWith(themeMode: mode));
      _repository.themeMode = mode;
    }
  }

  set userID(int indentifier) {
    if (state is PreferencesLoadSuccess) {
      emit((state as PreferencesLoadSuccess).copyWith(userID: indentifier));
    }
  }
}
