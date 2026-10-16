enum RequestType { acceptedByMe, requestedByMe, requestedByOther }

enum RequestStatus { none, pending, accepted }

class DummyRequest {
  const new({
    required this.title,
    required this.description,
    required this.type,
    this.status = .none,
  });
  final String title;
  final String description;
  final RequestType type;
  final RequestStatus status;
}

sealed class RequestBoardState {
  const RequestBoardState();
}

final class RequestBoardEmpty extends RequestBoardState {
  const new();
}

final class RequestBoardLoading extends RequestBoardState {
  const new();
}

final class RequestBoardLoadSuccess extends RequestBoardState {
  const new({
    required this.accepted,
    required this.requestedByMe,
    required this.requestedByOthers,
  });

  // "Me" refers to the user running this client, while "Others" refers
  // to other users of the service.
  final List<DummyRequest> accepted;
  final List<DummyRequest> requestedByMe;
  final List<DummyRequest> requestedByOthers;
}

final class RequestBoardLoadFailure extends RequestBoardState {
  const new({required this.exception});
  final Exception exception;
}
