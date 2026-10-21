import 'dart:async';
import 'dart:convert';

import 'package:reachout_client/state/models/request_board.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class RequestRepository {
  final List<Request> _requests = [];
  final Map<int, DateTime> _expiry =
      {}; // request id -> expires_at (or add expiresAt to Request)

  String? _userId;
  Completer<String>? _userIdCompleter;

  late final WebSocketChannel channel;
  final int port = 8080;
  Timer? _expiryTimer;

  // Cubits listen to this and emit a new state when it fires.
  final _changes = StreamController<void>.broadcast();

  Stream<void> get changes => _changes.stream;

  RequestRepository() {
    // Android emulator: use 10.0.2.2 instead of localhost.
    channel = WebSocketChannel.connect(Uri.parse("ws://localhost:$port"));
    channel.stream.listen(
      _onMessage,
      // ignore: avoid_print
      onError: (error) => print("Received Websocket error: $error"),
      // ignore: avoid_print
      onDone: () => print("WebSocket connection closed"),
    );
    _expiryTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _removeExpired(),
    );
  }

  List<Request> get acceptedRequests => _ofType(RequestType.acceptedByMe);

  List<Request> get requestedByMe => _ofType(RequestType.requestedByMe);

  List<Request> get requestedByOthers => _ofType(RequestType.requestedByOther);

  List<Request> _ofType(RequestType type) =>
      List.unmodifiable(_requests.where((r) => r.type == type));

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
    final data = (msg["data"] ?? {}) as Map<String, dynamic>;
    switch (msg["type"]) {
      case "user_registered":
        _handleUserRegistered(data);
      case "request_created":
        _handleRequestCreated(data);
      case "read_all_requests":
        _handleReadAllRequests(data);
      default:
        // ignore: avoid_print
        print("Unhandled message: $msg");
    }
  }

  // ---------- Handlers ----------

  void _handleUserRegistered(Map<String, dynamic> data) {
    _userId = data["user_id"] as String;
    _userIdCompleter?.complete(_userId);
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
    _removeExpired(notify: false);
    _changes.add(null);
  }

  Request _requestFromJson(Map<String, dynamic> j) {
    final id = j["id"] as int;
    if (j["expires_at"] != null) _expiry[id] = DateTime.parse(j["expires_at"]);

    final createdBy = j["created_by"] as String?;
    final acceptedBy = j["accepted_by"] as String?;
    // Without a user ID nothing can be "mine"; comparing null to null would
    // wrongly mark every unaccepted request as accepted by me.
    final me = _userId;
    final type = me != null && createdBy == me
        ? RequestType.requestedByMe
        : me != null && acceptedBy == me
        ? RequestType.acceptedByMe
        : RequestType.requestedByOther;

    final status = switch (j["status"]) {
      "ACCEPTED" => RequestStatus.accepted,
      "COMPLETED" => RequestStatus.completed,
      _ => RequestStatus.pending, // "PENDING" / "UNACCEPTED"
    };

    return Request(
      id: id,
      title: j["title"],
      location: j["location"],
      description: j["description"],
      type: type,
      status: status,
    );
  }

  // ---------- Expiry ----------

  void _removeExpired({bool notify = true}) {
    final now = DateTime.now().toUtc();
    final before = _requests.length;
    _requests.removeWhere((r) {
      final exp = _expiry[r.id];
      return exp != null && exp.isBefore(now);
    });
    _expiry.removeWhere((id, exp) => exp.isBefore(now));
    if (notify && _requests.length != before) _changes.add(null);
  }

  // ---------- Public API ----------

  /// Returns the user ID, registering with the server only if there is none.
  ///
  /// Pass [savedId] when an ID was stored by an earlier launch, so the same
  /// user is kept instead of registering a new one.
  Future<String> requestUserID({String? savedId}) {
    _userId ??= savedId;
    if (_userId != null) return Future.value(_userId!);
    if (_userIdCompleter == null) {
      _userIdCompleter = Completer<String>();
      _send("register_user");
    }
    return _userIdCompleter!.future;
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
    _expiryTimer?.cancel();
    _changes.close();
    channel.sink.close();
  }
}
