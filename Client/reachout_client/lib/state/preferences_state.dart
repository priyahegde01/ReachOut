import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reachout_client/state/models/preferences.dart';
import 'package:reachout_client/state/repositories/network_repository.dart';
import 'package:reachout_client/state/repositories/preference_repository.dart';

/// Manages the state of the user's settings
///
/// This includes things such as loading settings and updating settings.
class PreferencesCubit extends Cubit<PreferencesState> {
  final PreferencesRepository _repository;
  final NetworkRepository _networkRepository;

  PreferencesCubit(this._repository, this._networkRepository) : super(const PreferencesInitial()) {
    loadPreferences();
  }
  
  Future<void> loadPreferences() async {
    emit(const PreferencesLoadingInProgress());

    try {
      var uuid = await _repository.userID;
      final themeMode = await _repository.themeMode;
      
      if (uuid == null) {
        _networkRepository.requestNewUserID(setUUID);
      } else {
        _networkRepository.verifyUserID(uuid, setUUID);
      }

      // UUID is set later.
      emit(PreferencesLoadSuccess(userID: "Initial", themeMode: themeMode ?? .system));
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

  set userID(String identifier) {
    _repository.userID = identifier;
    if (state is PreferencesLoadSuccess) {
      emit((state as PreferencesLoadSuccess).copyWith(userID: identifier));
    }
  }

  void setUUID(String uuid) {
    userID = uuid;
  }
}
