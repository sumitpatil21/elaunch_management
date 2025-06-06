import 'package:bloc/bloc.dart';
import 'package:elaunch_management/Service/firebaseDatabase.dart';
import 'package:elaunch_management/Service/employee_modal.dart';
import 'package:equatable/equatable.dart';

part 'employee_event.dart';
part 'employee_state.dart';

class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  EmployeeBloc() : super(const EmployeeState()) {
    on<FetchEmployees>(fetchEmployeesData);
    on<AddEmployee>(insertEmployeeData);
    on<UpdateEmployee>(updateEmployeeData);
    on<DeleteEmployee>(deleteEmployeeData);
    on<FilterEmployeesByDepartment>(filterDepartment);
    on<FilterEmployeesByManager>(filterManager);
    on<ResetEmployeeFilters>(resetFilters);
    on<FilterEmployeesByRole>(filterRole);
    on<EmployeeLogin>(employeeLogin);
  }

  Future<void> employeeLogin(
    EmployeeLogin event,
    Emitter<EmployeeState> emit,
  ) async {
    final employee = await FirebaseDbHelper.firebase
        .getEmployeeByEmailAndPassword(
          email: event.email,
          password: event.password,
        );

    if (employee != null) {
      emit(state.copyWith(loggedInEmployee: employee));
    }
  }

  Future<void> fetchEmployeesData(
    FetchEmployees event,
    Emitter<EmployeeState> emit,
  ) async {
    final employees = await FirebaseDbHelper.firebase.getEmployees(
      role: event.role,
      departmentId: event.departmentId,
    );

    emit(state.copyWith(employees: employees, filteredEmployees: employees));
  }

  Future<void> insertEmployeeData(
    AddEmployee event,
    Emitter<EmployeeState> emit,
  ) async {
    final employee = EmployeeModal(
      id: event.id,
      name: event.name,
      email: event.email,
      password: event.password,
      address: event.address,
      dob: event.dob,
      role: event.role,
      managerName: event.managerName,
      departmentName: event.department,
      adminId: event.adminId ?? "",
      departmentId: event.departmentId ?? "",
    );

    await FirebaseDbHelper.firebase.createEmployee(employee);
    add(FetchEmployees(role: event.role));
  }

  Future<void> updateEmployeeData(
    UpdateEmployee event,
    Emitter<EmployeeState> emit,
  ) async {
    final updated = EmployeeModal(
      id: event.id,
      name: event.name,
      email: event.email,
      password: event.password,
      address: event.address,
      dob: event.dob,
      role: event.role,
      managerName: event.managerName,
      departmentName: event.department,
      adminId: event.adminId ?? "",
      departmentId: event.departmentId ?? "",
    );

    await FirebaseDbHelper.firebase.updateEmployee(updated);
    add(FetchEmployees(role: event.role));
  }

  Future<void> deleteEmployeeData(
    DeleteEmployee event,
    Emitter<EmployeeState> emit,
  ) async {
    await FirebaseDbHelper.firebase.deleteEmployee(event.id.toString());

    final updatedEmployees =
        state.employees.where((e) => e.id != event.id.toString()).toList();

    emit(state.copyWith(employees: updatedEmployees));
    applyAllFilters(emit);
  }

  Future<void> filterRole(
    FilterEmployeesByRole event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(state.copyWith(roleFilter: event.role == 'All' ? null : event.role));
    applyAllFilters(emit);
  }

  Future<void> filterDepartment(
    FilterEmployeesByDepartment event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(state.copyWith(departmentFilter: event.department));
    applyAllFilters(emit);
  }

  Future<void> filterManager(
    FilterEmployeesByManager event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(state.copyWith(managerFilter: event.manager));
    applyAllFilters(emit);
  }

  Future<void> resetFilters(
    ResetEmployeeFilters event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(
      state.copyWith(
        filteredEmployees: state.employees,
        roleFilter: null,
        departmentFilter: null,
        managerFilter: null,
      ),
    );
  }

  void applyAllFilters(Emitter<EmployeeState> emit) {
    List<EmployeeModal> filtered = List.from(state.employees);

    if (state.roleFilter != null) {
      filtered = filtered.where((e) => e.role == state.roleFilter).toList();
    }

    if (state.departmentFilter != null) {
      filtered =
          filtered
              .where((e) => e.departmentName == state.departmentFilter)
              .toList();
    }
    if (state.managerFilter != null) {
      filtered =
          filtered.where((e) => e.managerName == state.managerFilter).toList();
    }

    emit(state.copyWith(filteredEmployees: filtered));
  }
}
