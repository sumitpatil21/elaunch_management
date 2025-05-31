part of 'employee_bloc.dart';

class EmployeeState extends Equatable {
  final List<EmployeeModal> employees;
  final List<EmployeeModal> filteredEmployees;
  final String? roleFilter;
  final String? departmentFilter;
  final String? managerFilter;
  final EmployeeModal? loggedInEmployee; // Add this
  final bool isLoggedIn; // Add this

  const EmployeeState({
    this.employees = const [],
    this.filteredEmployees = const [],
    this.roleFilter,
    this.departmentFilter,
    this.managerFilter,
    this.loggedInEmployee, // Add this
    this.isLoggedIn = false, // Add this
  });


  EmployeeState copyWith({
    List<EmployeeModal>? employees,
    List<EmployeeModal>? filteredEmployees,
    String? roleFilter,
    String? departmentFilter,
    String? managerFilter,
    EmployeeModal? loggedInEmployee, // Add this
    bool? isLoggedIn, // Add this
  }) {
    return EmployeeState(
      employees: employees ?? this.employees,
      filteredEmployees: filteredEmployees ?? this.filteredEmployees,
      roleFilter: roleFilter ?? this.roleFilter,
      departmentFilter: departmentFilter ?? this.departmentFilter,
      managerFilter: managerFilter ?? this.managerFilter,
      loggedInEmployee: loggedInEmployee ?? this.loggedInEmployee, // Add this
      isLoggedIn: isLoggedIn ?? this.isLoggedIn, // Add this
    );
  }

  @override
  List<Object?> get props => [
    employees,
    filteredEmployees,
    roleFilter,
    departmentFilter,
    managerFilter,
    loggedInEmployee, // Add this
    isLoggedIn, // Add this
  ];
}