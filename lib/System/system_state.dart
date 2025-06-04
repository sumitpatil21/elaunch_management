

import 'package:equatable/equatable.dart';

import '../Service/system_modal.dart';

class SystemState extends Equatable {
  final List<SystemModal> systems;
  final List<SystemModal> requests;

  const SystemState({this.systems = const [], this.requests = const []});

  SystemState copyWith({List<SystemModal>? systems, List<SystemModal>? requests}) {
    return SystemState(systems: systems ?? this.systems, requests: requests ?? this.requests);
  }

  @override
  List<Object> get props => [systems, requests];
}





