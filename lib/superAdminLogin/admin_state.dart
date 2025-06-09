
import 'package:equatable/equatable.dart';

import '../Service/admin_modal.dart';
import '../Service/employee_modal.dart';

class AdminState extends Equatable {
  final List<AdminModal>? adminList;
  final AdminModal? adminModal;
  final EmployeeModal? employeeModal;
  final bool isLogin;
  final bool isLoading;
  final String? selectedRole;
  final String? errorMessage;
  final String? successMessage;

  const AdminState({
    this.adminList,
    this.adminModal,
    this.employeeModal,
    this.isLogin = false,
    this.isLoading = false,
    this.selectedRole,
    this.errorMessage,
    this.successMessage,
  });

  AdminState copyWith({
    List<AdminModal>? adminList,
    AdminModal? adminModal,
    EmployeeModal? employeeModal,
    bool? isLogin,
    bool? isLoading,
    String? selectedRole,
    String? errorMessage,
    String? successMessage,
  }) {
    return AdminState(
      adminList: adminList ?? this.adminList,
      adminModal: adminModal ?? this.adminModal,
      employeeModal: employeeModal ?? this.employeeModal,
      isLogin: isLogin ?? this.isLogin,
      isLoading: isLoading ?? this.isLoading,
      selectedRole: selectedRole ?? this.selectedRole,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
    adminList,
    adminModal,
    employeeModal,
    isLogin,
    isLoading,
    selectedRole,
    errorMessage,
    successMessage,
  ];
}







