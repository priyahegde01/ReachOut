import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reachout_client/state/models/request_board.dart';
import 'package:reachout_client/state/repositories/network_repository.dart';
import 'package:reachout_client/state/repositories/preference_repository.dart';
import 'package:reachout_client/state/repositories/request_repository.dart';

class RequestBoardCubit extends Cubit<RequestBoardState> {
  final RequestRepository _repository;
  final NetworkRepository _networkRepository;
  final PreferencesRepository _preferencesRepository;
  late final StreamSubscription<void> _subscription;

  RequestBoardCubit(this._repository, this._networkRepository, this._preferencesRepository)
    : super(const RequestBoardEmpty()) {
    // Rebuild the board whenever the repository's list changes
    // (server responses and expired requests being removed).

    _subscription = _repository.changes.listen((_) => _emitRequestBoard());
    _networkRepository.requestListData((data) async {
      String? UUID = await _preferencesRepository.userID;
      return _repository.readRequestData(data, UUID ?? "None");
    });
  }

  void _emitRequestBoard() {
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
    _networkRepository.sendRequest(
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
    _networkRepository.send("accept_request", requestId: identifier);
  }

  /// Cancel the request with the ID [identifier].
  ///
  /// This should be used to either remove the request from the board or remove the accepted status.
  void cancelRequest(int identifier) {
    _networkRepository.send("cancel_request", requestId: identifier);
  }

  /// Mark the request with the ID [identifier] as completed.
  void markRequestAsComplete(int identifier) {
    _networkRepository.send("mark_request_completed", requestId: identifier);
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    _repository.dispose();
    return super.close();
  }
}
