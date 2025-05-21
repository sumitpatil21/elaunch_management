import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:elaunch_management/Service/firebaseDatabase.dart';
import 'package:equatable/equatable.dart';

import '../Service/db_helper.dart';
import '../Service/department_modal.dart';

part 'department_event.dart';
part 'department_state.dart';

class DepartmentBloc extends Bloc<DepartmentEvent, DepartmentState> {
  DepartmentBloc(super.initialState) {
    on<FetchDepartments>(fetchDepartmentsData);
    on<AddDepartment>(insertDepartmentData);
    on<UpdateDepartment>(updateDepartmentData);
    on<DeleteDepartment>(deleteDepartmentData);
    on<NetworkDepartment>(networkDepartmentData);
  }
  Future<void> fetchDepartmentsData(
      FetchDepartments event,
      Emitter<DepartmentState> emit,
      ) async {

    final departments = await DbHelper.dbHelper.departmentFetch(event.adminId ?? 0,);
    FirebaseDbHelper.firebaseDbHelper.insertDepartment(departments);
    final fireDepart = await FirebaseDbHelper.firebaseDbHelper.fetchDepartments(departments.first.id_admin);
    log("${fireDepart}Fetch.......");
    emit(DepartmentState(departments: departments,fireDepartments: fireDepart));
  }


  Future<void> insertDepartmentData(
    AddDepartment event,
    Emitter<DepartmentState> emit,
  ) async {
    await DbHelper.dbHelper.insertIntoDepartment(
      id: event.id,
      departmentName: event.departmentName,
      dob: event.dob,
    );
    final departments = await DbHelper.dbHelper.departmentFetch(event.id);
    emit(DepartmentState(departments: departments));
  }

  Future<void> updateDepartmentData(
    UpdateDepartment event,
    Emitter<DepartmentState> emit,
  ) async {
    await DbHelper.dbHelper.updateDepartment(
      id: event.id,
      departmentName: event.departmentName,
      dob: event.dob,
    );
    final departments = await DbHelper.dbHelper.departmentFetch(event.id);
    emit(DepartmentState(departments: departments));
  }

  Future<void> deleteDepartmentData(
    DeleteDepartment event,
    Emitter<DepartmentState> emit,
  ) async {
    await DbHelper.dbHelper.deleteDepartment(event.id);
    final departments = await DbHelper.dbHelper.departmentFetch(
      event.adminId ?? 0,
    );
    emit(DepartmentState(departments: departments));
  }

  Future<void> networkDepartmentData(NetworkDepartment event,Emitter<DepartmentState> emit)
  async {

    final connectivityResult =
    await Connectivity().checkConnectivity();
    if(ConnectivityResult.mobile == connectivityResult)
    {
      event.connect=false;
      log("Not");
    }
    else if(ConnectivityResult.none == connectivityResult)
    {
      event.connect=true;
      log("Yes");
    }
    emit(state.copyWith(network: event.connect));
  }
}
