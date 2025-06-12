
import 'package:equatable/equatable.dart';
import '../Service/admin_modal.dart';
import '../Service/employee_modal.dart';


class AdminState extends Equatable {
  final List<AdminModal>? adminList;
  final AdminModal? adminModal;
  final EmployeeModal? employeeModal;
  final bool isLogin;
  final bool isLoading;
  final bool obscureLoginPassword;
  final bool obscureRegisterPassword;
  final String selectedRole;
  final int currentTabIndex;



  const AdminState({
    this.adminList,
    this.adminModal,
    this.employeeModal,
    this.isLogin = false,
    this.isLoading = false,
    this.obscureLoginPassword = true,
    this.obscureRegisterPassword = true,

    this.selectedRole = 'Admin',
    this.currentTabIndex = 0,


  });

  AdminState copyWith({
    List<AdminModal>? adminList,
    AdminModal? adminModal,
    EmployeeModal? employeeModal,
    bool? isLogin,
    bool? isLoading,
    bool? obscureLoginPassword,
    bool? obscureRegisterPassword,
    String? selectedRole,
    int? currentTabIndex,
    String? errorMessage,
    String? successMessage,
    bool? isRegistrationSuccess,
  }) {
    return AdminState(
      adminList: adminList ?? this.adminList,
      adminModal: adminModal ?? this.adminModal,
      employeeModal: employeeModal ?? this.employeeModal,
      isLogin: isLogin ?? this.isLogin,
      isLoading: isLoading ?? this.isLoading,
      obscureLoginPassword: obscureLoginPassword ?? this.obscureLoginPassword,
      obscureRegisterPassword: obscureRegisterPassword ?? this.obscureRegisterPassword,

      selectedRole: selectedRole ?? this.selectedRole,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,


    );
  }

  @override
  List<Object?> get props => [
    adminList,
    adminModal,
    employeeModal,
    isLogin,
    isLoading,
    obscureLoginPassword,
    obscureRegisterPassword,
    selectedRole,
    currentTabIndex,

  ];
}