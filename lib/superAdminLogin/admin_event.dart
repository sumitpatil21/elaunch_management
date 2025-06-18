

import 'package:equatable/equatable.dart';

import '../Service/admin_modal.dart';
import '../service/employee_modal.dart';




class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

class AdminFetch extends AdminEvent {}

class AdminLogin extends AdminEvent {
  final String email;
  final String password;

  const AdminLogin({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class AdminRegister extends AdminEvent {
  final String name;
  final String email;
  final String password;
  final String companyName;
  final String field;
  final String phone;

  const AdminRegister({
    required this.name,
    required this.email,
    required this.password,
    required this.companyName,
    required this.field,
    required this.phone,
  });

  @override
  List<Object> get props => [name, email, password, companyName, field, phone];
}

class AdminForgotPassword extends AdminEvent {
  final String email;

  const AdminForgotPassword({required this.email});

  @override
  List<Object> get props => [email];
}

class AdminLogout extends AdminEvent {}

class AdminLoginCheck extends AdminEvent {
  final bool isLogin;

  const AdminLoginCheck({required this.isLogin});

  @override
  List<Object> get props => [isLogin];
}

class SelectRole extends AdminEvent {
   String selectedRole;
   AdminModal? adminModal;
   EmployeeModal? employeeModal;

   SelectRole({
     required this.selectedRole,
    this.adminModal,
    this.employeeModal,
  });

  @override
  List<Object?> get props => [selectedRole, adminModal, employeeModal];
}

class ToggleObscurePassword extends AdminEvent {
  final String passwordType;

  const ToggleObscurePassword({required this.passwordType});

  @override
  List<Object> get props => [passwordType];
}

class ChangeRole extends AdminEvent {
  final String role;

  const ChangeRole({required this.role});

  @override
  List<Object> get props => [role];
}



