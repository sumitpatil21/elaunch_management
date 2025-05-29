part of 'employee_bloc.dart';

abstract class EmployeeEvent extends Equatable {
  const EmployeeEvent();

  @override
  List<Object?> get props => [];
}

class FetchEmployees extends EmployeeEvent {
  final String? role;
  final String? departmentId;
  final String? adminId;
  const FetchEmployees({this.role, this.departmentId, this.adminId});

  @override
  List<Object?> get props => [role, departmentId, adminId];
}

class AddEmployee extends EmployeeEvent {
  final String? id;
  final String? adminId;
  final String? departmentId;
  final String name;
  final String email;
  final String address;
  final String dob;
  final String role;
  final String managerName;
  final String department;

  const AddEmployee({
    this.id,
    this.adminId,
    this.departmentId,

    required this.name,
    required this.email,
    required this.address,
    required this.dob,
    required this.role,
    required this.managerName,
    required this.department,
  });

  @override
  List<Object?> get props => [
    id,
    adminId,
    departmentId,
    name,
    email,
    address,
    dob,
    role,
    managerName,
    department,
  ];
}

class UpdateEmployee extends EmployeeEvent {
  final String id;
  final String? adminId;
  final String? departmentId;
  final String name;
  final String email;
  final String address;
  final String dob;
  final String role;

  final String managerName;
  final String department;

  const UpdateEmployee({
    required this.id,
    this.adminId,
    this.departmentId,
    required this.name,
    required this.email,
    required this.address,
    required this.dob,
    required this.role,
    required this.managerName,
    required this.department,
  });

  @override
  List<Object?> get props => [
    id,
    adminId,
    departmentId,
    name,
    email,
    address,
    dob,
    role,
    managerName,
    department,
  ];
}

class DeleteEmployee extends EmployeeEvent {
  final String id;
  final int? adminId;
  final String? managerName;
  final String? departmentName;

  const DeleteEmployee({
    required this.id,
    this.adminId,
    this.managerName,
    this.departmentName,
  });

  @override
  List<Object?> get props => [id, adminId, managerName, departmentName];
}

class FilterEmployeesByRole extends EmployeeEvent {
  final String role;

  const FilterEmployeesByRole({required this.role});

  @override
  List<Object?> get props => [role];
}

class FilterEmployeesByDepartment extends EmployeeEvent {
  final String? department;

  const FilterEmployeesByDepartment({this.department});

  @override
  List<Object?> get props => [department];
}

class FilterEmployeesByManager extends EmployeeEvent {
  final String? manager;

  const FilterEmployeesByManager({this.manager});

  @override
  List<Object?> get props => [manager];
}

class ResetEmployeeFilters extends EmployeeEvent {
  const ResetEmployeeFilters();
}
