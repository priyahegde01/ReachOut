import 'dart:async';
import 'dart:convert';

import 'package:reachout_client/state/models/request_board.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class RequestRepository {
  final List<Request> _requests = [];
  

  String? _userId;
  Completer<String>? _authCompleter;
  late final WebSocketChannel channel;
  final int port = 8000;
  final _changes = StreamController<void>.broadcast();
  Stream<void> get changes => _changes.stream;

  RequestRepository() {
    // Android emulator: use 10.0.2.2 instead of localhost.
    channel = WebSocketChannel.connect(
      Uri.parse("ws://127.0.0.1:$port/server"),
    );
    channel.stream.listen(
      _onMessage,
      // ignore: avoid_print
      onError: (error) => print("Received Websocket error: $error"),
      // ignore: avoid_print
      onDone: () => print("WebSocket connection closed"),
    );
  }

  List<Request> get acceptedRequests => _ofType(RequestType.acceptedByMe);

  List<Request> get requestedByMe => _ofType(RequestType.requestedByMe);

  List<Request> get requestedByOthers => List.unmodifiable(_requests.where((request) => request.type == .requestedByOther && request.status != .accepted));

  List<Request> _ofType(RequestType type) =>
      List.unmodifiable(_requests.where((request) => request.type == type));

  // ---------- Serialization ----------

  void _send(
    String type, {
    int? requestId,
    Map<String, dynamic> data = const {},
  }) {
    channel.sink.add(
      jsonEncode({"type": type, "request_id": ?requestId, "data": data}),
    );
  }

  void _onMessage(dynamic raw) {
    final Map<String, dynamic> msg = jsonDecode(raw as String);
    final data = (msg["data"] ?? <String, dynamic>{}) as Map<String, dynamic>;

    switch (msg["type"]) {
      case "user_registered":
      case "user_verified":
        _handleUserAuthenticated(data);
      case "error":
        _handleServerError(msg);
      case "request_created":
        _handleRequestCreated(data);
      case "list_requests":
      case "read_all_requests":
        _handleReadAllRequests(data);
      default:
        // ignore: avoid_print
        print("Unhandled message: $msg");
    }
  }

  void _handleUserAuthenticated(Map<String, dynamic> data) {
    _userId = data["user_id"] as String;
    final completer = _authCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete(_userId!);
    }
  }

  void _handleServerError(Map<String, dynamic> msg) {
    final completer = _authCompleter;
    final message =
        msg["message"] as String? ?? "The server returned an error.";

    if (completer != null && !completer.isCompleted) {
      completer.completeError(StateError(message));
    } else {
      // ignore: avoid_print
      print("Server error: $message");
    }
  }

  void _handleRequestCreated(Map<String, dynamic> data) {
    // The response only has request_id, so re-fetch the full list.
    _send("list_requests");
  }

  void _handleReadAllRequests(Map<String, dynamic> data) {
    final list = (data["requests"] as List).cast<Map<String, dynamic>>();
    _requests
      ..clear()
      ..addAll(list.map(_requestFromJson));
    _changes.add(null);
  }

  Request _requestFromJson(Map<String, dynamic> jsonData) {
    // final id = j["id"] as int;
    final id = (jsonData["id"] ?? jsonData["request_id"]) as int;
    

    final createdBy = (jsonData["created_by"] ?? jsonData["user_id"]) as String?;

    // final createdBy = j["created_by"] as String?;
    final acceptedBy = jsonData["accepted_by"] as String?;
    // Without a user ID nothing can be "mine"; comparing null to null would
    // wrongly mark every unaccepted request as accepted by me.
    final me = _userId;
    final type = me != null && createdBy == me
        ? RequestType.requestedByMe
        : me != null && acceptedBy == me
        ? RequestType.acceptedByMe
        : RequestType.requestedByOther;

    final status = switch (jsonData["status"]) {
      "ACCEPTED" => RequestStatus.accepted,
      "COMPLETED" => RequestStatus.completed,
      _ => RequestStatus.pending, // "PENDING" / "UNACCEPTED"
    };

    final current = DateTime.now();
    final expires = DateTime.parse(jsonData["expires_at"]);
    final lifetime = expires.difference(current);

    return Request(
      id: id,
      // title: j["title"],
      title: (jsonData["title"] ?? jsonData["description"] ?? "") as String,
      location: jsonData["location"],
      description: jsonData["description"],
      type: type,
      status: status,
      timeToLive: lifetime
    );
  }

  // ---------- Expiry ----------

  // ---------- Public API ----------

  /// Returns the user ID, registering with the server only if there is none.
  ///
  /// Pass [savedId] when an ID was stored by an earlier launch, so the same
  /// user is kept instead of registering a new one.
  // Future<String> requestUserID({String? savedId}) {
  //   _userId ??= savedId;
  //   if (_userId != null) return Future.value(_userId!);
  //   if (_userIdCompleter == null) {
  //     _userIdCompleter = Completer<String>();
  //     _send("register_user");
  //   }
  //   return _userIdCompleter!.future;
  // }

  Future<String> registerUser() {
    return _authenticate("register_user");
  }

  Future<String> verifyUser(String userId) {
    return _authenticate("verify_user", data: {"user_id": userId});
  }

  Future<String> _authenticate(
    String type, {
    Map<String, dynamic> data = const {},
  }) {
    final existingCompleter = _authCompleter;
    if (existingCompleter != null && !existingCompleter.isCompleted) {
      return Future<String>.error(
        StateError("Authentication is already in progress."),
      );
    }

    final completer = Completer<String>();
    _authCompleter = completer;
    _send(type, data: data);

    return completer.future.whenComplete(() {
      if (identical(_authCompleter, completer)) {
        _authCompleter = null;
      }
    });
  }

  void refresh() => _send("list_requests");

  void sendRequest(Request request) {
    _send(
      "create_request",
      data: {
        "title": request.title,
        "location": request.location,
        "description": request.description,
      },
    );
    // The list updates when the server replies (request_created -> list_requests).
  }

  // The server handles messages in order, so asking for the list right after
  // an action returns the list with that action applied.
  void cancelRequest(int identifier) {
    _send("cancel_request", requestId: identifier);
    refresh();
  }

  void acceptRequest(int identifier) {
    _send("accept_request", requestId: identifier);
    refresh();
  }

  void markRequestAsComplete(int identifier) {
    _send("mark_request_completed", requestId: identifier);
    refresh();
  }

  void dispose() {
    _changes.close();
    channel.sink.close();
  }
}
