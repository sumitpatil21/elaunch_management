import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../Service/db_helper.dart';
import '../Service/employee_modal.dart';

part 'employee_event.dart';
part 'employee_state.dart';

class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  EmployeeBloc(super.initialState) {
    on<FetchEmployees>(fetchEmployeesData);
    on<AddEmployee>(insertEmployeeData);
    on<UpdateEmployee>(updateEmployeeData);
    on<DeleteEmployee>(deleteEmployeeData);
  }


  Future<void> fetchEmployeesData(
      FetchEmployees event,
      Emitter<EmployeeState> emit,
      ) async {
    final employees = await DbHelper.dbHelper.employeeFetch();
    emit(EmployeeState(employees: employees));
  }

  Future<void> insertEmployeeData(
      AddEmployee event,
      Emitter<EmployeeState> emit,
      ) async {
    await DbHelper.dbHelper.insertIntoEmployee(
      name: event.name,
      email: event.email,
      address: event.address,
      dob: event.dob,
      managerId: event.managerId,
      manager: event.managerName,
      department: event.department,
    );
    add(FetchEmployees(
      departmentId: event.departmentId,
      managerName: event.managerName,
      departmentName: event.department,
    ));
  }

  Future<void> updateEmployeeData(
      UpdateEmployee event,
      Emitter<EmployeeState> emit,
      ) async {
    await DbHelper.dbHelper.updateEmployee(
      id: event.id,
      name: event.name,
      email: event.email,
      address: event.address,
      dob: event.dob,
      managerId: event.managerId,
    );
    add(FetchEmployees(
      departmentId: event.departmentId,
      managerName: event.managerName,
      departmentName: event.department,
    ));
  }

  Future<void> deleteEmployeeData(
      DeleteEmployee event,
      Emitter<EmployeeState> emit,
      ) async {
    await DbHelper.dbHelper.deleteEmp(event.id);
    add(FetchEmployees(
      departmentId: event.departmentId,
      managerName: event.managerName,
      departmentName: event.departmentName,
    ));
  }
}