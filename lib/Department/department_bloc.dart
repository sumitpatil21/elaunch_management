import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:elaunch_management/Service/firebaseDatabase.dart';
import 'package:equatable/equatable.dart';

import '../Service/department_modal.dart';

part 'department_event.dart';
part 'department_state.dart';

class DepartmentBloc extends Bloc<DepartmentEvent, DepartmentState> {
  DepartmentBloc(): super(DepartmentState()){
    on<FetchDepartments>(fetchDepartmentsData);
    on<AddDepartment>(insertDepartmentData);
    on<UpdateDepartment>(updateDepartmentData);
    on<DeleteDepartment>(deleteDepartmentData);
  }

  Future<void> fetchDepartmentsData(
      FetchDepartments event,
      Emitter<DepartmentState> emit,
      ) async {
    final fire = await FirebaseDbHelper.firebaseDbHelper
        .fetchDepartments(event.adminId ?? 0);
    emit(DepartmentState(departments: fire));
  }

  Future<void> insertDepartmentData(
      AddDepartment event,
      Emitter<DepartmentState> emit,
      ) async {
    final department = DepartmentModal(
      name: event.departmentName,
      date: event.dob,
      id: event.id, id_admin: event.adminId,
    );

    await FirebaseDbHelper.firebaseDbHelper.insertDepartment(department);
    final departments = await FirebaseDbHelper.firebaseDbHelper
        .fetchDepartments(event.id);
    emit(DepartmentState(departments: departments));
  }

  Future<void> updateDepartmentData(
      UpdateDepartment event,
      Emitter<DepartmentState> emit,
      ) async {
    await FirebaseDbHelper.firebaseDbHelper
        .updateDepartment(department: event.departmentModal);

    final departments = await FirebaseDbHelper.firebaseDbHelper
        .fetchDepartments(event.departmentModal.id_admin);
    emit(DepartmentState(departments: departments));
  }

  Future<void> deleteDepartmentData(
      DeleteDepartment event,
      Emitter<DepartmentState> emit,
      ) async {
    await FirebaseDbHelper.firebaseDbHelper.deleteDepartment("${event.id}");
    final departments = await FirebaseDbHelper.firebaseDbHelper
        .fetchDepartments(event.adminId ?? 0);
    emit(DepartmentState(departments: departments));
  }
}


// import 'dart:developer';
//
// import 'package:bloc/bloc.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:elaunch_management/Service/firebaseDatabase.dart';
// import 'package:equatable/equatable.dart';
//
// import '../Service/db_helper.dart';
// import '../Service/department_modal.dart';
//
// part 'department_event.dart';
// part 'department_state.dart';
//
// class DepartmentBloc extends Bloc<DepartmentEvent, DepartmentState> {
//   DepartmentBloc(super.initialState) {
//     on<FetchDepartments>(fetchDepartmentsData);
//     on<AddDepartment>(insertDepartmentData);
//     on<UpdateDepartment>(updateDepartmentData);
//     on<DeleteDepartment>(deleteDepartmentData);
//     on<NetworkDepartment>(networkDepartmentData);
//   }
//
//
//  Future<void> fetchDepartmentsData(
//       FetchDepartments event,
//       Emitter<DepartmentState> emit,
//       ) async {
//     final connectivityResult = await Connectivity().checkConnectivity();
//
//     if (connectivityResult == ConnectivityResult.mobile ||
//         connectivityResult == ConnectivityResult.wifi) {
//         final fire = await FirebaseDbHelper.firebaseDbHelper
//             .fetchDepartments(event.adminId ?? 0);
//         emit(DepartmentState(fireDepartments: fire, departments: fire, connect: true));
//     } else {
//       final local = await DbHelper.dbHelper.departmentFetch(event.adminId ?? 0);
//       emit(DepartmentState(departments: local, connect: false));
//     }
//   }
//
//
//   Future<void> insertDepartmentData(
//     AddDepartment event,
//     Emitter<DepartmentState> emit,
//   ) async {
//     await DbHelper.dbHelper.insertIntoDepartment(
//       id: event.id,
//       departmentName: event.departmentName,
//       dob: event.dob,
//     );
//     final departments = await DbHelper.dbHelper.departmentFetch(event.id);
//     FirebaseDbHelper.firebaseDbHelper.insertDepartment(departments.last);
//     emit(DepartmentState(departments: departments));
//   }
//
//   Future<void> updateDepartmentData(
//     UpdateDepartment event,
//     Emitter<DepartmentState> emit,
//   ) async {
//     await DbHelper.dbHelper.updateDepartment(
//       id: event.departmentModal.id,
//       departmentName: event.departmentModal.name,
//       dob: event.departmentModal.date,
//     );
//     final departments = await DbHelper.dbHelper.departmentFetch(event.departmentModal.id_admin);
//      FirebaseDbHelper.firebaseDbHelper.updateDepartment(department: event.departmentModal);
//     emit(DepartmentState(departments: departments));
//   }
//
//   Future<void> deleteDepartmentData(
//     DeleteDepartment event,
//     Emitter<DepartmentState> emit,
//   ) async {
//     await DbHelper.dbHelper.deleteDepartment(event.id);
//     final departments = await DbHelper.dbHelper.departmentFetch(
//       event.adminId ?? 0,
//     );
//     emit(DepartmentState(departments: departments));
//   }
//
//   Future<void> networkDepartmentData(NetworkDepartment event,Emitter<DepartmentState> emit)
//   async {
//
//     final connectivityResult =
//     await Connectivity().checkConnectivity();
//     if(ConnectivityResult.mobile == connectivityResult)
//     {
//       event.connect=false;
//       log("Not");
//     }
//     else if(ConnectivityResult.none == connectivityResult)
//     {
//       event.connect=true;
//       log("Yes");
//     }
//     emit(state.copyWith(network: event.connect));
//   }
// }
