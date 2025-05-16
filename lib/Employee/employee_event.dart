part of 'employee_bloc.dart';

class EmployeeEvent extends Equatable {
  const EmployeeEvent();
  @override
  List<Object> get props => [];
}

class FetchEmployees extends EmployeeEvent {
  final int? departmentId;
  final String? managerName;
  final String? departmentName;

  const FetchEmployees({this.departmentId, this.managerName, this.departmentName});

  @override
  List<Object> get props => [departmentId ?? 0, managerName ?? "", departmentName ?? ""];
}

class AddEmployee extends EmployeeEvent {
  final int id;
  final int managerId;
  final int departmentId;
  final String name;
  final String email;
  final String address;
  final String dob;
  final String managerName;
  final String department;

  const AddEmployee({
    required this.id,
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
  List<Object> get props => [
    id,
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
  List<Object> get props => [
    id,
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
  final int? departmentId;
  final String? managerName;
  final String? departmentName;

  const DeleteEmployee({
    required this.id,
    this.departmentId,
    this.managerName,
    this.departmentName,
  });

  @override
  List<Object> get props => [id, departmentId ?? 0, managerName ?? "", departmentName ?? ""];
}