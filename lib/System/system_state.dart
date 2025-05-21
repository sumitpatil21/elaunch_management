part of 'system_bloc.dart';

class SystemState extends Equatable {
  final List<SystemModal> systems;

  const SystemState({this.systems = const []});

  SystemState copyWith({List<SystemModal>? systems}) {
    return SystemState(systems: systems ?? this.systems);
  }

  @override
  List<Object?> get props => [systems];
}

