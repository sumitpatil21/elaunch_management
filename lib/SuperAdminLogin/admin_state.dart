part of 'admin_bloc.dart';


class AdminState extends Equatable {
  final List<AdminModal>? adminList;

  const AdminState({this.adminList});

  AdminState copyWith({
    List<AdminModal>? adminList,
  }) {
    return AdminState(
      adminList: adminList ?? this.adminList,
    );
  }

  @override
  List<Object?> get props => [adminList];
}

