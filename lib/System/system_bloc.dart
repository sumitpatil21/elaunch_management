import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'system_event.dart';
part 'system_state.dart';

class SystemBloc extends Bloc<SystemEvent, SystemState> {
  SystemBloc(super.initialState) {
    on<SystemEvent>
  }
}
