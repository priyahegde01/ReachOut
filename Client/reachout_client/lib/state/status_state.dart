import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reachout_client/state/models/status.dart';
import 'package:reachout_client/state/repositories/network_repository.dart';

class StatusStateCubit extends Cubit<StatusState> {
  new(this._networkRepository) : super(StatusSuccess(hasServerConnection: _networkRepository.isConnected, points: -1)) {
    _networkRepository.registerOnUserDetailsCallback((points) {
      final newstate = (state as StatusSuccess).copyWith(points: points);
      print("called");
      emit(newstate);
    });
    _networkRepository.registerOnServerConnectionChange((isConnected) {
      final newstate = (state as StatusSuccess).copyWith(hasServerConnection: isConnected);
      emit(newstate);
    });
  } 

  final NetworkRepository _networkRepository;
}