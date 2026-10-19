import 'package:reachout_client/state/models/request_board.dart';

// TODO: implement part of network logic here (receive data).

class RequestRepository {
  // TODO: remove dummy data.
  final List<Request> _requests = [
    Request(
      title: "Burga",
      location: "Burger town",
      description: "This a burga",
      type: .acceptedByMe,
    ),
    Request(
      title: "Burga",
      location: "Burger town",
      description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent semper ipsum a ex vestibulum, sed rutrum sem euismod. Sed molestie elit lorem, vel facilisis magna vulputate in. Integer pharetra tempor quam, vitae viverra mauris rutrum nec. Aliquam quis molestie diam, eu fringilla orci. Quisque ut ante nec justo elementum posuere ut a eros. Aliquam cursus lorem ut purus condimentum, eu lobortis lacus pellentesque. Vestibulum rhoncus enim maximus velit ullamcorper semper.",
      type: .requestedByMe,
      status: .accepted,
    ),
    Request(
      title: "Burga",
      location: "Burger town",
      description: "This a burga",
      type: .requestedByMe,
      status: .pending,
    ),
    Request(
      title: "Burga",
      location: "Burger town",
      description: "This a burga",
      type: .requestedByMe,
      status: .pending,
    ),
    Request(
      title: "Burga",
      location: "Burger town",
      description: "This a burga",
      type: .requestedByOther,
    ),
    Request(
      title: "Cheese",
      location: "Burger town",
      description: "The moon is made out of it.",
      type: .requestedByOther,
    ),
  ];

  List<Request> get acceptedRequests {
    return _requests.where((request) => request.type == .acceptedByMe).toList();
  }

  List<Request> get requestsByMe {
    return _requests
        .where((request) => request.type == .requestedByMe)
        .toList();
  }

  List<Request> get requestsByOthers {
    return _requests
        .where((request) => request.type == .requestedByOther)
        .toList();
  }

  void sendRequest(Request request) {
    // TODO: send request and update list. Note that a new state has
    // to be emitted in cubits that use this.
  }

  /// Recieve requests from the server.
  /// 
  /// Does nothing in case the request list is up to date.
  void getRequests() {
    // TODO: check if the list stored in this class is up to date
    // and if not, recieve the up-to-date list. 
    // TODO: consider if the server should instead broadcast data to the clients.
  }
}
