part of 'employee_bloc.dart';

abstract class EmployeeEvent extends Equatable {
  const EmployeeEvent();

  @override
  List<Object?> get props => [];
}

class LoadEmployees extends EmployeeEvent {}

class FetchEmployees extends EmployeeEvent {
  final String? role;
  final String? departmentId;

  const FetchEmployees({this.role, this.departmentId});

  @override
  List<Object?> get props => [role, departmentId];
}

class AddEmployee extends EmployeeEvent {
  final String id;
  final String name;
  final String email;
  final String password;
  final String address;
  final String role;
  final String? adminId;
  final String? departmentId;

  const AddEmployee({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.address,
    required this.role,
    this.adminId,
    this.departmentId,
  });

  @override
  List<Object?> get props => [id, name, email, password, address, role, adminId, departmentId];
}

class UpdateEmployee extends EmployeeEvent {
  final String id;
  final String name;
  final String email;
  final String password;
  final String address;
  final String role;
  final String? adminId;
  final String? departmentId;

  const UpdateEmployee({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.address,
    required this.role,
    this.adminId,
    this.departmentId,
  });

  @override
  List<Object?> get props => [id, name, email, password, address, role, adminId, departmentId];
}

class DeleteEmployee extends EmployeeEvent {
  final String id;

  const DeleteEmployee({required this.id});

  @override
  List<Object?> get props => [id];
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

class EmployeeLogin extends EmployeeEvent {
  final String? email;
  final String? password;


  const EmployeeLogin({
     this.email,
     this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class EmployeeLogout extends EmployeeEvent {
  const EmployeeLogout();
}
class EmployeeLoginCheck extends EmployeeEvent {
  final bool isLogin;

  const EmployeeLoginCheck({required this.isLogin});

  @override
  List<Object> get props => [isLogin];
}