part of 'admin_bloc.dart';

class AdminState extends Equatable {
  final List<AdminModal>? adminList;
  final bool isLogin;

  const AdminState({this.adminList, this.isLogin = true});

  AdminState copyWith({List<AdminModal>? adminList, bool? isLogin}) {
    return AdminState(
      adminList: adminList ?? this.adminList,
      isLogin: isLogin ?? this.isLogin,
    );
  }

  @override
  List<Object?> get props => [adminList, isLogin];
}
