part of 'system_bloc.dart';

sealed class SystemEvent extends Equatable {
  const SystemEvent();
}

class CreateSystem extends SystemEvent {
  final System system;

  const CreateSystem(this.system);

  @override
  List<Object> get props => [system];
}

class UpdateSystem extends SystemEvent {
  final System system;

  const UpdateSystem(this.system);

  @override
  List<Object> get props => [system];
}

class DeleteSystem extends SystemEvent {
  const DeleteSystem();
}
