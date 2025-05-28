import 'package:bloc/bloc.dart';
import 'package:elaunch_management/Service/firebaseDatabase.dart';
import 'package:elaunch_management/Service/employee_modal.dart';
import 'package:equatable/equatable.dart';
// import 'package:elaunch_management/Service/db_helper.dart'; // Local DB - commented

part 'employee_event.dart';
part 'employee_state.dart';

class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  EmployeeBloc(): super(const EmployeeState()) {
    on<FetchEmployees>(fetchEmployeesData);
    on<AddEmployee>(insertEmployeeData);
    on<UpdateEmployee>(updateEmployeeData);
    on<DeleteEmployee>(deleteEmployeeData);
  }

  Future<void> fetchEmployeesData(
      FetchEmployees event,
      Emitter<EmployeeState> emit,
      ) async {

    // final employees = await DbHelper.dbHelper.employeeFetchFilter(
    //   adminId: event.adminId ?? 1,
    //   departmentName: event.departmentName,
    //   managerName: event.managerName,
    // );

    final employees = await FirebaseDbHelper.firebase.getEmployees(
      role: event.role,
      departmentId: event.departmentId,
      // adminId: event.adminId ?? 1,
      // departmentName: event.departmentName,
      // managerName: event.managerName,
    );

    emit(EmployeeState(employees: employees));
  }

  Future<void> insertEmployeeData(
      AddEmployee event,
      Emitter<EmployeeState> emit,
      ) async {

    // await DbHelper.dbHelper.insertIntoEmployee(...);

    final employee = EmployeeModal(
      id: event.id,
      name: event.name,
      email: event.email,
      address: event.address,
      dob: event.dob,
      role: event.role,
      managerName: event.managerName,
      departmentName: event.department,
      adminId: event.adminId??"",
      departmentId: event.departmentId??"",
    );

    await FirebaseDbHelper.firebase.createEmployee(employee);

    add(FetchEmployees(
    role: event.role,
    ));
  }

  Future<void> updateEmployeeData(
      UpdateEmployee event,
      Emitter<EmployeeState> emit,
      ) async {

    // await DbHelper.dbHelper.updateEmployee(...);

    final updated = EmployeeModal(
      id: event.id,
      name: event.name,
      email: event.email,
      address: event.address,
      dob: event.dob,
      role: event.role,
      managerName: event.managerName,
      departmentName: event.department,
      adminId: event.adminId??"",
      departmentId: event.departmentId??"",
    );

    await FirebaseDbHelper.firebase.updateEmployee(updated);

    add(FetchEmployees(
      role: event.role,
    ));
  }

  Future<void> deleteEmployeeData(
      DeleteEmployee event,
      Emitter<EmployeeState> emit,
      ) async {

    // await DbHelper.dbHelper.deleteEmp(event.id);

    await FirebaseDbHelper.firebase.deleteEmployee(event.id.toString());


  }
}