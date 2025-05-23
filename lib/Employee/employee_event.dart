part of 'employee_bloc.dart';

abstract class EmployeeEvent extends Equatable {
  const EmployeeEvent();

  @override
  List<Object?> get props => [];
}

class FetchEmployees extends EmployeeEvent {
  final String? departmentName;
  final int? adminId;
  final String? managerName;

  const FetchEmployees({
    this.departmentName,
    this.adminId,
    this.managerName,
  });

  @override
  List<Object?> get props => [departmentName, managerName, adminId];
}

class AddEmployee extends EmployeeEvent {
  final int? id;
  final int? adminId;
  final int managerId;
  final int departmentId;
  final String name;
  final String email;
  final String address;
  final String dob;
  final String managerName;
  final String department;

  const AddEmployee({
    this.id,
    this.adminId,
    required this.managerId,
    required this.departmentId,
    required this.name,
    required this.email,
    required this.address,
    required this.dob,
    required this.managerName,
    required this.department,
  });

  @override
  List<Object?> get props => [
    id,
    adminId,
    managerId,
    departmentId,
    name,
    email,
    address,
    dob,
    managerName,
    department,
  ];
}

class UpdateEmployee extends EmployeeEvent {
  final int id;
  final int? adminId;
  final int managerId;
  final int departmentId;
  final String name;
  final String email;
  final String address;
  final String dob;
  final String managerName;
  final String department;

  const UpdateEmployee({
    required this.id,
    this.adminId,
    required this.managerId,
    required this.departmentId,
    required this.name,
    required this.email,
    required this.address,
    required this.dob,
    required this.managerName,
    required this.department,
  });

  @override
  List<Object?> get props => [
    id,
    adminId,
    managerId,
    departmentId,
    name,
    email,
    address,
    dob,
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