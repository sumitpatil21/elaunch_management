
import 'package:equatable/equatable.dart';

import '../Service/admin_modal.dart';
import '../Service/employee_modal.dart';

 class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

class AdminInsert extends AdminEvent {
  final String id;
  final String name;
  final String email;
  final String password;
  final String companyName;
  final String field;

  const AdminInsert({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.companyName,
    required this.field,
  });

  @override
  List<Object> get props => [id, name, email, password, companyName, field];
}

class AdminFetch extends AdminEvent {}

class AdminLogin extends AdminEvent {
  final String email;
  final String password;

  const AdminLogin({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class AdminLogout extends AdminEvent {
  final String? email;

  const AdminLogout({this.email});

  @override
  List<Object?> get props => [email];
}

class AdminLoginCheck extends AdminEvent {
  final bool isLogin;

  const AdminLoginCheck({required this.isLogin});

  @override
  List<Object> get props => [isLogin];
}

class SelectRole extends AdminEvent {
  final String selectedRole;
  final AdminModal? adminModal;
  final EmployeeModal? employeeModal;

  const SelectRole({
    required this.selectedRole,
    this.adminModal,
    this.employeeModal,
  });

  @override
  List<Object?> get props => [selectedRole, adminModal, employeeModal];
}

class AdminPasswordReset extends AdminEvent {
  final String email;

  const AdminPasswordReset({required this.email});

  @override
  List<Object> get props => [email];
}

class AdminClearError extends AdminEvent {}