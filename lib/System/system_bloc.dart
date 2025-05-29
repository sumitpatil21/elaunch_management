import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../Service/firebaseDatabase.dart';
import '../Service/system_modal.dart';

part 'system_event.dart';
part 'system_state.dart';

class SystemBloc extends Bloc<SystemEvent, SystemState> {
  SystemBloc() : super(const SystemState()) {
    on<FetchSystem>(fetchSystemData);
    on<AddSystem>(insertSystemData);
    on<UpdateSystem>(updateSystemData);
    on<DeleteSystem>(deleteSystemData);
  }

  Future<void> fetchSystemData(
    FetchSystem event,
    Emitter<SystemState> emit,
  ) async {
    final systems = await FirebaseDbHelper.firebase.getSystems(
      event.adminId ?? "",
    );
    emit(SystemState(systems: systems));
  }

  Future<void> insertSystemData(
    AddSystem event,
    Emitter<SystemState> emit,
  ) async {
    final system = SystemModal(
      systemName: event.systemName,
      version: event.version ?? "",
      operatingSystem: event.operatingSystem ?? "",
      status: event.status ?? "available",
      adminId: event.adminId,

      employeeId: event.employeeId,
      employeeName: event.employeeName,
      id: "1",
    );

    await FirebaseDbHelper.firebase.createSystem(system);

    add(FetchSystem(adminId: "${event.adminId}",));
  }

  Future<void> updateSystemData(
    UpdateSystem event,
    Emitter<SystemState> emit,
  ) async {
    final system = SystemModal(
      id: event.id,
      systemName: event.systemName,
      version: event.version ?? "",
      operatingSystem: event.operatingSystem ?? "",
      status: event.status ?? "available",
      adminId: event.adminId,
      employeeId: event.employeeId,
      employeeName: event.employeeName,
    );
    await FirebaseDbHelper.firebase.updateSystem(system);

    add(FetchSystem(adminId: "${event.adminId}",));
  }

  Future<void> deleteSystemData(
    DeleteSystem event,
    Emitter<SystemState> emit,
  ) async {
    await FirebaseDbHelper.firebase.deleteSystem(event.id);

    add(FetchSystem(adminId: "${event.adminId}"));
  }
}
