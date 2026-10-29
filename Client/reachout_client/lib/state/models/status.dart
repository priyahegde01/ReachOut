sealed class StatusState {
  const StatusState();
}

final class StatusInitial extends StatusState;

final class StatusSuccess extends StatusState {
  const new({required this.hasServerConnection, required this.points});
  final bool hasServerConnection;
  final int points;

  StatusSuccess copyWith({bool? hasServerConnection, int? points}) {
    return StatusSuccess(
      hasServerConnection: hasServerConnection ?? this.hasServerConnection,
      points: points ?? this.points,
    );
  }
}
