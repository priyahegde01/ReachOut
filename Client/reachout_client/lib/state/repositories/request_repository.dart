import 'package:reachout_client/state/models/request_board.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class RequestRepository {
  // TODO: remove dummy data.
  final List<Request> _requests = [
    Request(
      id: 1,
      title: "Burga",
      location: "Burger town",
      description: "This a burga",
      type: .acceptedByMe,
    ),
    Request(
      id: 2,
      title: "Burga",
      location: "Burger town",
      description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent semper ipsum a ex vestibulum, sed rutrum sem euismod. Sed molestie elit lorem, vel facilisis magna vulputate in. Integer pharetra tempor quam, vitae viverra mauris rutrum nec. Aliquam quis molestie diam, eu fringilla orci. Quisque ut ante nec justo elementum posuere ut a eros. Aliquam cursus lorem ut purus condimentum, eu lobortis lacus pellentesque. Vestibulum rhoncus enim maximus velit ullamcorper semper.",
      type: .requestedByMe,
      status: .accepted,
    ),
    Request(
      id: 3,
      title: "Burga",
      location: "Burger town",
      description: "This a burga",
      type: .requestedByMe,
      status: .pending,
    ),
    Request(
      id: 4,
      title: "Burga",
      location: "Burger town",
      description: "This a burga",
      type: .requestedByMe,
      status: .pending,
    ),
    Request(
      id: 5,
      title: "Burga",
      location: "Burger town",
      description: "This a burga",
      type: .requestedByOther,
    ),
    Request(
      id: 6,
      title: "Cheese",
      location: "Burger town",
      description: "The moon is made out of it.",
      type: .requestedByOther,
    ),
  ];

  late final WebSocketChannel channel;
  // TODO: replace this port number with the actual port number of the server if needed.
  final int port = 8080;
  
  new() {
    // TODO: connect to the appropriate IP address (for testing purposes, keep it to localhost).
    channel = WebSocketChannel.connect(Uri.parse("ws://localhost:$port"));
    // TODO: write a private method (using _ as a prefix for the method) for each of the cases and replace the
    // placeholders below.
    channel.stream.listen(
      (message) {
        print(message);
      },
      onError: (error) {
        print("Received Websocket error: $error");
      },
      onDone: () {
        print("WebSocket connection closed");
      },
    );
  }

  int requestUserID() {
    // TODO: Implement function.
    return 0;
  }

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

  void sendRequest(int UserID, Request request) {
    // TODO: send request and update list. Note that a new state has
    // to be emitted in cubits that use this.
  }

  void cancelRequest(int UserID, int identifier) {
    // TODO: send request and update list. Note that a new state has
    // to be emitted in cubits that use this.
  }

  void acceptRequest(int UserID, int identifier) {
    // TODO: Implement
  } 

  void markRequestAsComplete(int UserID, int identifier) {
    // TODO: Implement
  } 
}
