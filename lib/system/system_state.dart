import 'dart:ui';

import 'package:equatable/equatable.dart';

import '../Service/system_modal.dart';

class SystemState extends Equatable {
  final List<SystemModal> systems;
  final List<SystemModal> requests;
  final Map<String, Color> statusColors;
  final Map<String, Color> statusTextColors;

  const SystemState({this.systems = const [], this.requests = const [], this.statusColors = const {}, this.statusTextColors = const {}});

  SystemState copyWith({
    List<SystemModal>? systems,
    List<SystemModal>? requests,
    Map<String, Color>? statusColors,
    Map<String, Color>? statusTextColors,
  }) {
    return SystemState(
      systems: systems ?? this.systems,
      requests: requests ?? this.requests,
      statusColors: statusColors ?? this.statusColors,
      statusTextColors: statusTextColors ?? this.statusTextColors,
    );
  }

  @override
  List<Object> get props => [systems, requests];
}
