part of 'admin_bloc.dart';

class AdminState extends Equatable {
  final List<AdminModal> adminList;
  const AdminState({this.adminList = const []});
  AdminState copyWith({List<AdminModal>? adminList}) {
    log(adminList![0].email);
    return AdminState(adminList: adminList ?? this.adminList);
  }


  @override
  List<Object> get props => [adminList];
}
