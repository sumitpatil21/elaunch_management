import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:elaunch_management/Service/department_modal.dart';
import 'package:equatable/equatable.dart';

import '../Service/db_helper.dart';
import '../Service/manger_modal.dart';

part 'manager_event.dart';

part 'manager_state.dart';

class ManagerBloc extends Bloc<ManagerEvent, ManagerState> {
  ManagerBloc(super.initialState) {
    on<AddManager>(insertManagerData);
    on<FetchManagers>(fetchManagersData);
    on<UpdateManager>(updateManagerData);
    on<DeleteManager>(deleteManagerData);
  }

  Future<void> insertManagerData(
    AddManager event,
    Emitter<ManagerState> emit,
  ) async {
    await DbHelper.dbHelper.insertIntoManager(
      id: event.departmentId,
      name: event.name,
      dob: event.dob,
      email: event.email,
      address: event.address,
    );
    add(
      FetchManagers(departmentId: event.departmentId, adminId: event.adminId??1),
    );
  }

  Future<void> fetchManagersData(
    FetchManagers event,
    Emitter<ManagerState> emit,
  ) async {
    final managers = await DbHelper.dbHelper.fetchAllManager(
       event.adminId,
       event.departmentId,
    );
    emit(state.copyWith(managers: managers));
  }

  Future<void> updateManagerData(
    UpdateManager event,
    Emitter<ManagerState> emit,
  ) async {
    await DbHelper.dbHelper.updateManager(
      id: event.id,
      name: event.name,
      dob: event.dob,
      email: event.email,
      address: event.address,
      departmentId: event.departmentId,
    );
    add(
      FetchManagers(departmentId: event.departmentId, adminId: event.adminId??1),
    );
  }

  Future<void> deleteManagerData(
    DeleteManager event,
    Emitter<ManagerState> emit,
  ) async {
    await DbHelper.dbHelper.deleteManager(event.id);
    add(
      FetchManagers(departmentId: event.departmentId, adminId: event.adminId??1),
    );
  }
}
