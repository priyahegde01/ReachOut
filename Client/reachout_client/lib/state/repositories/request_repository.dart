import 'package:reachout_client/state/models/request_board.dart';

class RequestRepository {
  final List<DummyRequest> _requests = [
    DummyRequest(
      title: "Burga",
      description: "This a burga",
      type: .acceptedByMe,
    ),
    DummyRequest(
      title: "Burga",
      description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent semper ipsum a ex vestibulum, sed rutrum sem euismod. Sed molestie elit lorem, vel facilisis magna vulputate in. Integer pharetra tempor quam, vitae viverra mauris rutrum nec. Aliquam quis molestie diam, eu fringilla orci. Quisque ut ante nec justo elementum posuere ut a eros. Aliquam cursus lorem ut purus condimentum, eu lobortis lacus pellentesque. Vestibulum rhoncus enim maximus velit ullamcorper semper.",
      type: .requestedByMe,
      status: .accepted,
    ),
    DummyRequest(
      title: "Burga",
      description: "This a burga",
      type: .requestedByMe,
      status: .pending,
    ),
    DummyRequest(
      title: "Burga",
      description: "This a burga",
      type: .requestedByMe,
      status: .pending,
    ),
    DummyRequest(
      title: "Burga",
      description: "This a burga",
      type: .requestedByOther,
    ),
    DummyRequest(
      title: "Cheese",
      description: "The moon is made out of it.",
      type: .requestedByOther,
    ),
    DummyRequest(
      title: "Cheese",
      description: "The moon is made out of it.",
      type: .requestedByOther,
    ),
    DummyRequest(
      title: "Cheese",
      description: "The moon is made out of it.",
      type: .requestedByOther,
    ),
    DummyRequest(
      title: "Cheese",
      description: "The moon is made out of it.",
      type: .requestedByOther,
    ),
    DummyRequest(
      title: "Cheese",
      description: "The moon is made out of it.",
      type: .requestedByOther,
    ),
    DummyRequest(
      title: "Cheese",
      description: "The moon is made out of it.",
      type: .requestedByOther,
    ),
    DummyRequest(
      title: "Cheese",
      description: "The moon is made out of it.",
      type: .requestedByOther,
    ),
    DummyRequest(
      title: "Cheese",
      description: "The moon is made out of it.",
      type: .requestedByOther,
    ),
    DummyRequest(
      title: "Cheese",
      description: "The moon is made out of it.",
      type: .requestedByOther,
    ),
    DummyRequest(
      title: "Cheese",
      description: "The moon is made out of it.",
      type: .requestedByOther,
    ),
    DummyRequest(
      title: "Cheese",
      description: "The moon is made out of it.",
      type: .requestedByOther,
    ),
    DummyRequest(
      title: "Cheese",
      description: "The moon is made out of it.",
      type: .requestedByOther,
    ),
    DummyRequest(
      title: "Cheese",
      description: "The moon is made out of it.",
      type: .requestedByOther,
    ),
    DummyRequest(
      title: "Cheese",
      description: "The moon is made out of it.",
      type: .requestedByOther,
    ),
    DummyRequest(
      title: "Cheese",
      description: "The moon is made out of it.",
      type: .requestedByOther,
    ),
    DummyRequest(
      title: "Cheese",
      description: "The moon is made out of it.",
      type: .requestedByOther,
    ),
    DummyRequest(
      title: "Cheese",
      description: "The moon is made out of it.",
      type: .requestedByOther,
    ),
  ];

  List<DummyRequest> get acceptedRequests {
    return _requests.where((request) => request.type == .acceptedByMe).toList();
  }

  List<DummyRequest> get requestsByMe {
    return _requests
        .where((request) => request.type == .requestedByMe)
        .toList();
  }

  List<DummyRequest> get requestsByOthers {
    return _requests
        .where((request) => request.type == .requestedByOther)
        .toList();
  }
}
