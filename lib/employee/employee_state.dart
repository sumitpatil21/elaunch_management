


// employee_state.dart
part of 'employee_bloc.dart';


class EmployeeState extends Equatable {
  final List<EmployeeModal> employees;
  final List<EmployeeModal> filteredEmployees;
  final String? roleFilter;
  final String? departmentFilter;
  final String? managerFilter;
  final EmployeeModal? loggedInEmployee;
  final bool isLogin;
  final bool isLoading;
  final bool isAuthenticated;


  const EmployeeState({
    this.employees = const [],
    this.filteredEmployees = const [],
    this.roleFilter,
    this.departmentFilter,
    this.managerFilter,
    this.loggedInEmployee,
    this.isLogin = false,
    this.isLoading = false,
    this.isAuthenticated = false,

  });

  EmployeeState copyWith({
    List<EmployeeModal>? employees,
    List<EmployeeModal>? filteredEmployees,
    String? roleFilter,
    String? departmentFilter,
    String? managerFilter,
    EmployeeModal? loggedInEmployee,
    bool? isLogin,
    bool? isLoading,
    bool? isAuthenticated,
    String? errorMessage,
    String? successMessage,
  }) {
    return EmployeeState(
      employees: employees ?? this.employees,
      filteredEmployees: filteredEmployees ?? this.filteredEmployees,
      roleFilter: roleFilter ?? this.roleFilter,
      departmentFilter: departmentFilter ?? this.departmentFilter,
      managerFilter: managerFilter ?? this.managerFilter,
      isLogin: isLogin ?? this.isLogin,
      loggedInEmployee: loggedInEmployee ?? this.loggedInEmployee,
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,

    );
  }

  @override
  List<Object?> get props => [
    employees,
    filteredEmployees,
    roleFilter,
    departmentFilter,
    managerFilter,
    loggedInEmployee,
    isLogin,
    isLoading,
    isAuthenticated,

  ];
}

