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

  void sendRequest(String title, String location, String description) {
    _repository.sendRequest(
      Request(title: title, location: location, description: description, type: .requestedByMe),
    );
  }
}
