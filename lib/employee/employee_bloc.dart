
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:elaunch_management/service/firebase_database.dart';

import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Service/firebase_auth.dart';
import '../service/employee_modal.dart';

part 'employee_event.dart';
part 'employee_state.dart';

class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  static const String loginKey = 'is_login';
  static const String roleKey = 'user_role';
  static const String idKey = 'user_id';

// 5. Register the missing event handler in EmployeeBloc constructor:

  EmployeeBloc() : super(const EmployeeState()) {
    on<FetchEmployees>(fetchEmployeesData);
    on<LoadEmployees>(loadEmployees);
    on<AddEmployee>(insertEmployeeData);
    on<UpdateEmployee>(updateEmployeeData);
    on<DeleteEmployee>(deleteEmployeeData);
    on<FilterEmployeesByDepartment>(filterDepartment);
    on<FilterEmployeesByManager>(filterManager);
    on<ResetEmployeeFilters>(resetFilters);
    on<FilterEmployeesByRole>(filterRole);
    on<EmployeeLogin>(employeeLogin);
    on<EmployeeLoginCheck>(employeeLoginCheck); // Add this line
    on<EmployeeLogout>(employeeLogout);
    loginGet();
  }

// 6. Fix the loginGet method in EmployeeBloc:
  Future<void> employeeLogin(
      EmployeeLogin event,
      Emitter<EmployeeState> emit,
      ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      log('Employee login attempt with email: ${event.email}');

      await AuthServices.authServices.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      var currentUser = AuthServices.authServices.getCurrentUser();
      EmployeeModal? employeeModal;

      if (currentUser != null) {
        // You might want to fetch additional employee data from your database here
        employeeModal = EmployeeModal(
          id: currentUser.uid,
          name: currentUser.displayName ?? '',
          email: currentUser.email ?? '',
          password: '',
          address: '',
          role: 'Employee',
          adminId: '',
          departmentId: '',
          departmentName: '',
          managerName: '',
          managerId: '',
        );

        await saveLogin(true, 'Employee', currentUser.uid);

        emit(state.copyWith(
          loggedInEmployee: employeeModal,
          isLogin: true,
          isLoading: false,
          successMessage: 'Employee login successful!',
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to get user information',
        ));
      }
    } catch (e) {
      log('Employee login error: $e');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Login failed: ${e.toString()}',
      ));
    }
  }

// 4. Add the missing EmployeeLoginCheck handler:

  Future<void> employeeLoginCheck(
      EmployeeLoginCheck event,
      Emitter<EmployeeState> emit,
      ) async {
    emit(state.copyWith(isLogin: event.isLogin));
  }

  Future<void> loginGet() async {
    final prefs = await SharedPreferences.getInstance();
    final isLogin = prefs.getBool(loginKey) ?? false;
    final userRole = prefs.getString(roleKey) ?? 'Admin';
    final userId = prefs.getString(idKey);

    if (isLogin && userRole == 'Employee' && userId != null) {
      add(EmployeeLoginCheck(isLogin: true));

      var currentUser = AuthServices.authServices.getCurrentUser();
      if (currentUser != null) {
        final employeeModal = EmployeeModal(
          id: currentUser.uid,
          name: currentUser.displayName ?? '',
          email: currentUser.email ?? '',
          password: '',
          address: '',
          role: 'Employee',
          adminId: '',
          departmentId: '',
          departmentName: '',
          managerName: '',
          managerId: '',
        );

        emit(state.copyWith(loggedInEmployee: employeeModal, isLogin: true));
      }
    }
  }

// 7. Fix the logical operator issue in applyAllFilters method:

  void applyAllFilters(Emitter<EmployeeState> emit) {
    List<EmployeeModal> filtered = List.from(state.employees);

    if (state.roleFilter != null) {
      filtered = filtered.where((e) => e.role == state.roleFilter).toList();
    }

    if (state.departmentFilter != null) {
      filtered = filtered
          .where((e) => e.departmentId == state.departmentFilter)
          .toList();
    }

    if (state.managerFilter != null) {
// Fixed: Using logical OR operator instead of missing operator
      filtered = filtered
          .where(
            (e) =>
        e.managerName == state.managerFilter ||
            e.managerId == state.managerFilter,
      )
          .toList();
    }

    emit(state.copyWith(filteredEmployees: filtered));
  }

  Future<void> saveLogin(
      bool isLogin,
      String role,
      String? userId,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(loginKey, isLogin);
    await prefs.setString(roleKey, role);
    if (userId != null) {
      await prefs.setString(idKey, userId);
    }
  }

  Future<void> clearLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(loginKey);
    await prefs.remove(roleKey);
    await prefs.remove(idKey);
  }


  Future<void> employeeLogout(
    EmployeeLogout event,
    Emitter<EmployeeState> emit,
  ) async {
    await AuthServices.authServices.signOut();
    emit(
      state.copyWith(
        loggedInEmployee: null,
        isAuthenticated: false,
        errorMessage: null,
      ),
    );
  }

  Future<void> loadEmployees(
    LoadEmployees event,
    Emitter<EmployeeState> emit,
  ) async {
    add(FetchEmployees());
  }

  Future<void> fetchEmployeesData(
    FetchEmployees event,
    Emitter<EmployeeState> emit,
  ) async {
    final employees = await FirebaseDbHelper.firebase.getEmployees(
      role: event.role,
      departmentId: event.departmentId,
    );
    log("Employee data ->>>>>: $employees");
    emit(
      state.copyWith(
        employees: employees ,
        filteredEmployees: employees,
        isLoading: false,
        errorMessage: null,
      ),
    );
  }

  Future<void> insertEmployeeData(
    AddEmployee event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    await AuthServices.authServices.createAccountWithEmailAndPassword(
      email: event.email,
      password: event.password,
    );

    final employee = EmployeeModal(
      id: event.id,
      name: event.name,
      email: event.email,
      password: event.password,
      address: event.address,
      role: event.role,
      adminId: event.adminId ?? "",
      departmentId: event.departmentId ?? "",
      departmentName: event.departmentName ?? "",
      managerName: event.managerName ?? "",
      managerId: event.managerId ?? "",
    );

    await FirebaseDbHelper.firebase.createEmployee(employee);

    // Refresh the employee list
    add(FetchEmployees(role: event.role));

    emit(
      state.copyWith(
        isLoading: false,
        successMessage: 'Employee added successfully',
      ),
    );
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
      role: event.role,
      adminId: event.adminId ?? "",
      departmentId: event.departmentId ?? "",
      departmentName: event.departmentName ?? "",
      managerName: event.managerName ?? "",
      managerId: event.managerId ?? "",
    );

    await FirebaseDbHelper.firebase.updateEmployee(updated);

    // Refresh the employee list
    add(FetchEmployees(role: event.role));

    emit(
      state.copyWith(
        isLoading: false,
        successMessage: 'Employee updated successfully',
      ),
    );
  }

  Future<void> deleteEmployeeData(
    DeleteEmployee event,
    Emitter<EmployeeState> emit,
  ) async {
    await FirebaseDbHelper.firebase.deleteEmployee(event.id.toString());

    final updatedEmployees =
        state.employees.where((e) => e.id != event.id.toString()).toList();

    emit(
      state.copyWith(
        employees: updatedEmployees,
        isLoading: false,
        successMessage: 'Employee deleted successfully',
      ),
    );

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

}
