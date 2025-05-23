import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../Service/db_helper.dart';
import '../Service/system_modal.dart';

part 'system_event.dart';
part 'system_state.dart';

class SystemBloc extends Bloc<SystemEvent, SystemState> {
  SystemBloc(super.initialState) {
    on<FetchSystem>(fetchSystemData);
    on<AddSystem>(insertSystemData); // Fixed method name
    on<UpdateSystem>(updateSystemData); // Fixed method name
    on<DeleteSystem>(deleteSystemData); // Fixed method name
  }

  Future<void> fetchSystemData(
      FetchSystem event,
      Emitter<SystemState> emit,
      ) async {
    final systems = await DbHelper.dbHelper.fetchSystems( // Fixed method name
        employeeId: event.employeeId,
        adminId: event.adminId
    );

    emit(SystemState(systems: systems));
  }

  Future<void> insertSystemData( // Fixed method name
      AddSystem event,
      Emitter<SystemState> emit,
      ) async {
    await DbHelper.dbHelper.insertIntoSystem(
      systemName: event.systemName,
      version: event.version ?? "",
      operatingSystem: event.operatingSystem??"",
      status: event.status??"",
      adminId: event.adminId,
      managerId: event.managerId,
      employeeId: event.employeeId,
      employeeName: event.employeeName,
    );
    add(FetchSystem(adminId: event.adminId, employeeId: event.employeeId));
  }

  Future<void> updateSystemData( // Fixed method name
      UpdateSystem event,
      Emitter<SystemState> emit,
      ) async {
    await DbHelper.dbHelper.updateSystem(
      id: event.id,
      systemName: event.systemName,
      version: event.version ?? "",
      operatingSystem: event.operatingSystem??"",
      status: event.status??"",
      adminId: event.adminId,
      managerId: event.managerId,
      employeeId: event.employeeId,
    );
    add(FetchSystem(adminId: event.adminId, employeeId: event.employeeId)); // Added employeeId
  }

  Future<void> deleteSystemData( // Fixed method name
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