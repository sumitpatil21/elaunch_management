part of 'employee_bloc.dart';

class EmployeeState extends Equatable {
  final List<EmployeeModal> employees;
  final List<EmployeeModal> filteredEmployees;
  final String? roleFilter;
  final String? departmentFilter;
  final String? managerFilter;


  const EmployeeState({
    this.employees = const [],
    this.filteredEmployees = const [],
    this.roleFilter,
    this.departmentFilter,
    this.managerFilter,
  });

  EmployeeState copyWith({
    List<EmployeeModal>? employees,
    List<EmployeeModal>? filteredEmployees,
    String? roleFilter,
    String? departmentFilter,
    String? managerFilter,
    String? error,
  }) {
    return EmployeeState(
      employees: employees ?? this.employees,
      filteredEmployees: filteredEmployees ?? this.filteredEmployees,
      roleFilter: roleFilter ?? this.roleFilter,
      departmentFilter: departmentFilter ?? this.departmentFilter,
      managerFilter: managerFilter ?? this.managerFilter,
    );
  }

  @override
  List<Object?> get props => [
    employees,
    filteredEmployees,
    roleFilter,
    departmentFilter,
    managerFilter,
  ];
}
