part of 'admin_bloc.dart';

class AdminState extends Equatable {
  final List<AdminModal>? adminList;
  final bool isLogin;
  final String? selectedRole;
  final AdminModal? adminModal;
  final EmployeeModal? employeeModal;


  const AdminState({this.adminList, this.isLogin = false, this.selectedRole, this.adminModal, this.employeeModal,});

  AdminState copyWith({List<AdminModal>? adminList, bool? isLogin, String? selectedRole, AdminModal? adminModal, EmployeeModal? employeeModal, bool? isLoading}) {
    return AdminState(
      adminList: adminList ?? this.adminList,
      isLogin: isLogin ?? this.isLogin,
      selectedRole: selectedRole ?? this.selectedRole,
      adminModal: adminModal ?? this.adminModal,
      employeeModal: employeeModal ?? this.employeeModal,

    );
  }

  @override
  List<Object?> get props => [adminList, isLogin, selectedRole, adminModal, employeeModal];
}