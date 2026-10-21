import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reachout_client/state/models/preferences.dart';
import 'package:reachout_client/state/models/request_board.dart';
import 'package:reachout_client/state/preferences_state.dart';
import 'package:reachout_client/state/repositories/request_repository.dart';

class RequestBoardCubit extends Cubit<RequestBoardState> {
  RequestBoardCubit(this._preferences)
    : _repository = RequestRepository(),
      super(const RequestBoardEmpty()) {
    // Rebuild the board whenever the repository's list changes
    // (server responses and expired requests being removed).
    _subscription = _repository.changes.listen((_) => loadRequestBoard());

    _start();

    // For testing purposes.
    //emit(RequestBoardLoadFailure(exception: Exception("Hell.")));
    //emit(RequestBoardLoading());
  }

  final PreferencesCubit _preferences;
  final RequestRepository _repository;
  late final StreamSubscription<void> _subscription;

  /// Gets the user ID, then loads the board.
  ///
  /// The user ID must be known before the list is fetched, because the
  /// repository uses it to work out requestedByMe / acceptedByMe.
  Future<void> _start() async {
    final prefs = _preferences.state is PreferencesLoadSuccess
        ? _preferences.state
        : await _preferences.stream.firstWhere(
            (s) => s is PreferencesLoadSuccess || s is PreferencesLoadFailure,
          );
    final savedId = prefs is PreferencesLoadSuccess ? prefs.userID : null;

    final userId = await _repository.requestUserID(savedId: savedId);
    if (userId != savedId) _preferences.userID = userId;
    _repository.refresh();
  }

  void loadRequestBoard() {
    emit(
      RequestBoardLoadSuccess(
        accepted: _repository.acceptedRequests,
        requestedByMe: _repository.requestedByMe,
        requestedByOthers: _repository.requestedByOthers,
      ),
    );
  }

  void sendRequest(String title, String location, String description) {
    // The ID is -1 because the server assigns the real ID.
    // The board updates when the server replies (request_created -> list_requests).
    _repository.sendRequest(
      Request(
        id: -1,
        title: title,
        location: location,
        description: description,
        type: .requestedByMe,
      ),
    );
  }

  /// Take/accept the request with the ID [identifier].
  void acceptRequest(int identifier) {
    _repository.acceptRequest(identifier);
  }

  /// Cancel the request with the ID [identifier].
  ///
  /// This should be used to either remove the request from the board or remove the accepted status.
  void cancelRequest(int identifier) {
    _repository.cancelRequest(identifier);
  }

  /// Mark the request with the ID [identifier] as completed.
  void markRequestAsComplete(int identifier) {
    _repository.markRequestAsComplete(identifier);
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    _repository.dispose();
    return super.close();
  }
}
