import 'dart:convert';
import 'package:reachout_client/state/models/request_board.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class NetworkRepository {
  final int port = 8000;
  late final WebSocketChannel _channel;
  Function (String) onNewID = (_) {};
  Function(Map<String, dynamic>) onNewRequestBoardData = (_) {};

  new() {
    _channel = WebSocketChannel.connect(
      Uri.parse("ws://127.0.0.1:$port/server"),
    );
    _channel.stream.listen(
      _onMessage,
      // ignore: avoid_print
      onError: (error) => print("Received Websocket error: $error"),
      // ignore: avoid_print
      onDone: () => print("WebSocket connection closed"),
    );
  }

  void send(
    String type, {
    int? requestId,
    Map<String, dynamic> data = const {},
  }) {
    _channel.sink.add(
      jsonEncode({"type": type, "request_id": requestId, "data": data}),
    );
  }

  void requestNewUserID(Function(String uuid) onNewIDRetrieved) {
    onNewID = onNewIDRetrieved;
    send("register_user");
  }

  void verifyUserID(String uuid, Function(String uuid) onNewIDRetrieved) {
    onNewID = onNewIDRetrieved;
    send("verify_user", data: {"user_id": uuid});
  }

  /// Sets [onData] as a callback when request list data is received from the server and sends a request for data to the server. 
  void requestListData(Function(Map<String, dynamic>) onData) {
    onNewRequestBoardData = onData; 
    send("list_requests");
  }

  void _onMessage(dynamic raw) {
    final Map<String, dynamic> msg = jsonDecode(raw as String);
    final data = (msg["data"] ?? <String, dynamic>{}) as Map<String, dynamic>;

    switch (msg["type"]) {
      case "user_registered":
      case "Valid ID": _handleUserRegister(data);
      case "Invalid ID": requestNewUserID(onNewID);
      case "list_requests": onNewRequestBoardData(data);
      case "error":
        _handleServerError(msg);
      default:
        // ignore: avoid_print
        print("Unhandled message: $msg");
    
    }
  }

  /// Set the user ID. 
  void _handleUserRegister(Map<String, dynamic> data) {
    final String uuid = data["user_id"];
    onNewID(uuid);
  }

  void _handleServerError(Map<String, dynamic> msg) {
    final message =
        msg["message"] as String? ?? "The server returned an error.";
    // ignore: avoid_print
    print("Server error: $message");
  }

  void sendRequest(Request request) {
    send(
      "create_request",
      data: {
        "title": request.title,
        "location": request.location,
        "description": request.description,
      },
    );
  }

  
}
