part of 'system_bloc.dart';

sealed class SystemState extends Equatable {
  const SystemState();
}

final class SystemInitial extends SystemState {
  @override
  List<Object> get props => [];
}
