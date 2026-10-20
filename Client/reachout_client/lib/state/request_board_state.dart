import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reachout_client/state/models/request_board.dart';
import 'package:reachout_client/state/repositories/request_repository.dart';

class RequestBoardCubit extends Cubit<RequestBoardState> {
  new() : _repository = RequestRepository(), super(const RequestBoardEmpty()) {
    loadRequestBoard();
    // For testing purposes.
    //emit(RequestBoardLoadFailure(exception: Exception("Hell.")));
    //emit(RequestBoardLoading());
  }

  final RequestRepository _repository;

  void loadRequestBoard() {
    emit(
      RequestBoardLoadSuccess(
        accepted: _repository.acceptedRequests,
        requestedByMe: _repository.requestsByMe,
        requestedByOthers: _repository.requestsByOthers,
      ),
    );
  }

  void sendRequest(
    int userID,
    String title,
    String location,
    String description,
  ) {
    // The ID is set to -1 because the server should be responsible for handling the assignment of IDs.
    _repository.sendRequest(
      userID,
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
  void acceptRequest(int userID, int identifier) {
    _repository.cancelRequest(userID, identifier);
  }

  /// Cancel the request with the ID [identifier]. 
  /// 
  /// This should be used to either remove the request from the board or remove the accepted status.
  void cancelRequest(int userID, int identifier) {
    _repository.cancelRequest(userID, identifier);
  }

  /// Take/accept the request with the ID [identifier].
  void markRequestAsComplete(int userID, int identifier) {
    _repository.cancelRequest(userID, identifier);
  }
}
