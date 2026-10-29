import 'dart:async';

import 'package:reachout_client/state/models/request_board.dart';

class RequestRepository {
  List<Request> _requests = [];
  final _changes = StreamController<void>.broadcast();
  Stream<void> get changes => _changes.stream;

  new();

  List<Request> get requests => _requests;

  List<Request> get acceptedRequests => _ofType(RequestType.acceptedByMe);

  List<Request> get requestedByMe => _ofType(RequestType.requestedByMe);

  List<Request> get requestedByOthers => List.unmodifiable(
    _requests.where(
      (request) =>
          request.type == RequestType.requestedByOther &&
          request.status != RequestStatus.accepted,
    ),
  );

  List<Request> _ofType(RequestType type) =>
      List.unmodifiable(_requests.where((request) => request.type == type));

  // ---------- Deserialization ----------

  /// Reads request data from JSON
  void readRequestData(Map<String, dynamic> data, String myUUID) {
    final list = (data["requests"] as List).cast<Map<String, dynamic>>();
    _requests = list.map((e) => _requestFromJson(e, myUUID)).toList();
    _changes.add(null);
  }

  Request _requestFromJson(Map<String, dynamic> jsonData, String myUUID) {
    final id = jsonData["request_id"] as int;
    final createdBy = jsonData["user_id"] as String;
    final String? acceptedBy = jsonData["accepted_by"];

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
      title: (jsonData["title"] ?? jsonData["description"] ?? "") as String,
      location: jsonData["location"],
      description: jsonData["description"],
      type: createdBy.compareTo(myUUID) != 0
          ? status == .accepted
                ? acceptedBy != null && acceptedBy.compareTo(myUUID) == 0
                      ? .acceptedByMe
                      : .ignore
                : .requestedByOther
          : .requestedByMe,
      status: status,
      timeToLive: lifetime,
    );
  }

  // ---------- Public API ----------

  void dispose() {
    _changes.close();
  }
}
