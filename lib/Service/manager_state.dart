part of '../Manager/manager_bloc.dart';

class ManagerState extends Equatable {
  final List<MangerModal> managers;

  const ManagerState({this.managers = const []});

  ManagerState copyWith({List<MangerModal>? managers}) {
    return ManagerState(managers: managers ?? this.managers);
  }

  @override
  List<Object?> get props => [managers];
}
