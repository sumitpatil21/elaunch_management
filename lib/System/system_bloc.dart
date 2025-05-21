import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../Service/db_helper.dart';
import '../Service/system_modal.dart';

part 'system_event.dart';
part 'system_state.dart';

class SystemBloc extends Bloc<SystemEvent, SystemState> {
  SystemBloc(super.initialState) {
    on<FetchSystem>(fetchSystemData);
    on<AddSystem>(insertEmployeeData);
    on<UpdateSystem>(updateEmployeeData);
    on<DeleteSystem>(deleteEmployeeData);
  }

  Future<void> fetchSystemData(
    FetchSystem event,
    Emitter<SystemState> emit,
  ) async {
    final systems = await DbHelper.dbHelper.fetchSystemsByEmployeeId(
      employeeId: event.employeeId,
      adminId: event.adminId
    );

    emit(SystemState(systems: systems));
  }

  Future<void> insertEmployeeData(
    AddSystem event,
    Emitter<SystemState> emit,
  ) async {
    await DbHelper.dbHelper.insertIntoSystem(
      systemName: event.systemName,
      version: event.version ?? "",
      adminId: event.adminId,
      managerId: event.managerId,
      employeeId: event.employeeId,
    );
    add(FetchSystem(adminId: event.adminId, employeeId: event.employeeId));
  }

  Future<void> updateEmployeeData(
    UpdateSystem event,
    Emitter<SystemState> emit,
  ) async {
    await DbHelper.dbHelper.updateSystem(
      id: event.id,
      systemName: event.systemName,
      version: event.version ?? "",
      adminId: event.adminId,
      managerId: event.managerId,
      employeeId: event.employeeId,
    );
    add(FetchSystem(adminId: event.adminId));
  }

  Future<void> deleteEmployeeData(
    DeleteSystem event,
    Emitter<SystemState> emit,
  ) async {
    await DbHelper.dbHelper.deleteSystem(event.id);
    add(
      FetchSystem(
        adminId: event.adminId,
      employeeId: event.employeeId
      ),
    );
  }
}
