import 'dart:developer';

import "package:bloc/bloc.dart";
import 'package:elaunch_management/service/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Service/firebase_auth.dart';
import '../service/employee_modal.dart';
import 'employee_event.dart';
import 'employee_state.dart';

class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  static const String loginKey = 'is_login';
  static const String roleKey = 'user_role';
  static const String idKey = 'user_id';

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
    on<EmployeeLoginCheck>(employeeLoginCheck); // Add this line
    on<EmployeeLogout>(employeeLogout);
    on<UpdateSearchQuery>(updateSearchQuery);
    on<ClearSearch>(clearSearch);
    applyAllFilters;
    loginGet();
  }

  Future<void> employeeLogin(
    EmployeeLogin event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    log('Employee login attempt with email: ${event.email}');

    await AuthServices.authServices.signInWithEmailAndPassword(
      email: event.email,
      password: event.password,
    );

    var currentUser = AuthServices.authServices.getCurrentUser();

    if (currentUser != null) {
      final employees = await FirebaseDbHelper.firebase.getEmployeeByEmail(
        event.email ?? "",
      );

      EmployeeModal? employeeModal;

      if (employees.isNotEmpty) {
        employeeModal = employees.first;
      } else {
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
      }

      await saveLogin(true, 'Employee', currentUser.uid);

      emit(
        state.copyWith(
          isLogin: true,
          isLoading: false,
          loggedInEmployee: employeeModal,
        ),
      );
    } else {
      emit(state.copyWith(isLoading: false, isLogin: false));
    }
  }

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
        final employees = await FirebaseDbHelper.firebase.getEmployeeByEmail(
          currentUser.email!,
        );

        if (employees.isNotEmpty) {
          final employeeModal = employees.first;
          emit(state.copyWith(loggedInEmployee: employeeModal, isLogin: true));
        } else {
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
      } else {
        await clearLogin();
        add(EmployeeLoginCheck(isLogin: false));
      }
    }
  }


  Future<void> saveLogin(bool isLogin, String role, String? userId) async {
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
    emit(state.copyWith(loggedInEmployee: null));
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

    add(FetchEmployees(role: event.role));

    emit(state.copyWith(isLoading: false));
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
    add(FetchEmployees(role: event.role));

    emit(state.copyWith(isLoading: false));
  }

  void applyAllFilters(Emitter<EmployeeState> emit) {
    List<EmployeeModal> filtered = List.from(state.employees);

    if (state.employees != null) {
      filtered = filtered.where((e) => e.role == state.roleFilter).toList();
    }

    if (state.departmentFilter != null) {
      filtered =
          filtered
              .where((e) => e.departmentId == state.departmentFilter)
              .toList();
    }

    if (state.managerFilter != null) {
      filtered =
          filtered.where((e) => e.managerId == state.managerFilter).toList();
    }

    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filtered =
          filtered
              .where(
                (e) =>
                    e.name.toLowerCase().contains(query) ||
                    e.email.toLowerCase().contains(query) ||
                    e.role.toLowerCase().contains(query) ||
                    e.id.toLowerCase().contains(query),
              )
              .toList();
    }

    emit(state.copyWith(filteredEmployees: filtered));
  }

  Future<void> fetchEmployeesData(
    FetchEmployees event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final employees = await FirebaseDbHelper.firebase.getEmployees(
      role: event.role,
      departmentId: event.departmentId,
    );

    log("Employee data ->>>>>: $employees");

    emit(
      state.copyWith(
        employees: employees,
        filteredEmployees: employees,
        isLoading: false,
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
        roleFilter: null,
        departmentFilter: null,
        managerFilter: null,
        searchQuery: '',
        filteredEmployees: state.employees,
      ),
    );
  }

  Future<void> updateSearchQuery(
    UpdateSearchQuery event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(state.copyWith(searchQuery: event.query));
    applyAllFilters(emit);
  }

  Future<void> clearSearch(
    ClearSearch event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(state.copyWith(searchQuery: ''));
    applyAllFilters(emit);
  }
}
