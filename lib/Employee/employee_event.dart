part of 'employee_bloc.dart';

abstract class EmployeeEvent extends Equatable {
  const EmployeeEvent();

  @override
  List<Object?> get props => [];
}

class FetchEmployees extends EmployeeEvent {
  final String? role;

  const FetchEmployees({
    this.role,
  });

  @override
  List<Object?> get props => [role];
}

class AddEmployee extends EmployeeEvent {
  final int? id;
  final int? adminId;
  final int departmentId;
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
    required this.departmentId,
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
  final int id;
  final int? adminId;
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
  final int id;
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