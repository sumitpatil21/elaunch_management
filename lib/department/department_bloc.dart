import 'package:bloc/bloc.dart';

import 'package:elaunch_management/Service/firebase_database.dart';
import 'package:equatable/equatable.dart';

import '../Service/department_modal.dart';

part 'department_event.dart';
part 'department_state.dart';

class DepartmentBloc extends Bloc<DepartmentEvent, DepartmentState> {
  DepartmentBloc() : super(DepartmentState()) {
    on<FetchDepartments>(fetchDepartmentsData);
    on<AddDepartment>(insertDepartmentData);
    on<UpdateDepartment>(updateDepartmentData);
    on<DeleteDepartment>(deleteDepartmentData);
  }
  Future<void> fetchDepartmentsData(
    FetchDepartments event,
    Emitter<DepartmentState> emit,
  ) async {
    final fire = await FirebaseDbHelper.firebase.getDepartments();
    emit(DepartmentState(departments: fire));
  }

  Future<void> insertDepartmentData(
    AddDepartment event,
    Emitter<DepartmentState> emit,
  ) async {
    final department = DepartmentModal(
      id: "1",
      name: event.departmentName,
      field: event.dob,
    );

    await FirebaseDbHelper.firebase.createDepartment(department);
    final departments = await FirebaseDbHelper.firebase.getDepartments();
    emit(DepartmentState(departments: departments));
  }

  Future<void> updateDepartmentData(
    UpdateDepartment event,
    Emitter<DepartmentState> emit,
  ) async {
    await FirebaseDbHelper.firebase.updateDepartment(event.departmentModal);

    final departments = await FirebaseDbHelper.firebase.getDepartments();
    emit(DepartmentState(departments: departments));
  }

  Future<void> deleteDepartmentData(
    DeleteDepartment event,
    Emitter<DepartmentState> emit,
  ) async {
    await FirebaseDbHelper.firebase.deleteDepartment(event.id);
    final departments = await FirebaseDbHelper.firebase.getDepartments(
      (event.adminId ?? 0) as String,
    );
    emit(DepartmentState(departments: departments));
  }
}
