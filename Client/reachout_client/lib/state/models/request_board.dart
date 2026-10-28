enum RequestType { acceptedByMe, requestedByMe, requestedByOther }

enum RequestStatus { none, pending, accepted, completed }

class Request {
  new({
    required this.id,
    required this.title,
    required this.location,
    required this.description,
    required this.type,
    this.status = .none,
    this.timeToLive = const Duration(seconds: 10)
  }) {
    created = DateTime.now();
    expires = created.add(timeToLive);
  }

  final int id;
  final String title;
  final String location;
  final String description;
  final RequestType type;
  final RequestStatus status;
  late final DateTime created;
  late final DateTime expires;
  final Duration timeToLive;
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
  final List<Request> accepted;
  final List<Request> requestedByMe;
  final List<Request> requestedByOthers;
}

final class RequestBoardLoadFailure extends RequestBoardState {
  const new({required this.exception});
  final Exception exception;
}
