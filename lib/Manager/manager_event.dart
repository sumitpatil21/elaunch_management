part of 'manager_bloc.dart';

abstract class ManagerEvent extends Equatable {
  const ManagerEvent();

  @override
  List<Object?> get props => [];
}

class FetchManagers extends ManagerEvent {
  final int? departmentId;
  final int? adminId;

  const FetchManagers({this.departmentId, this.adminId});

  @override
  List<Object?> get props => [departmentId, adminId];
}

class ManagerScreenArguments extends ManagerEvent {
  final int adminId;
  final int departmentId;

  ManagerScreenArguments({required this.adminId, required this.departmentId});
  @override
  List<Object?> get props => [adminId,departmentId];
}


class AddManager extends ManagerEvent {
  final String name;
  final String email;
  final String address;
  final String dob;
  final int departmentId;
  final int? adminId;
  final String? departmentName;

  const AddManager({
    required this.name,
    required this.email,
    required this.address,
    required this.dob,
    required this.departmentId,
    this.adminId,
    this.departmentName,
  });

  @override
  List<Object?> get props => [name, email, address, dob, departmentId, adminId, departmentName];
}

class UpdateManager extends ManagerEvent {
  final int id;
  final String name;
  final String email;
  final String address;
  final String dob;
  final int departmentId;
  final int? adminId;

  const UpdateManager({
    required this.id,
    required this.name,
    required this.email,
    required this.address,
    required this.dob,
    required this.departmentId,
    this.adminId,
  });

  @override
  List<Object?> get props => [id, name, email, address, dob, departmentId, adminId];
}

class DeleteManager extends ManagerEvent {
  final int id;
  final int? departmentId;
  final int? adminId;

  const DeleteManager(this.id, {this.departmentId, this.adminId});

  @override
  List<Object?> get props => [id, departmentId, adminId];
}