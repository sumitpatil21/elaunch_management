part of 'department_bloc.dart';

class DepartmentEvent extends Equatable {
  const DepartmentEvent();

  @override
  List<Object> get props => [];
}

class FetchDepartments extends DepartmentEvent {
  final int? adminId;

  const FetchDepartments({this.adminId});

  @override
  List<Object> get props => [adminId ?? 0];
}

class AddDepartment extends DepartmentEvent {
  final String departmentName;
  final String dob;
  final int id;

  const AddDepartment({required this.departmentName, required this.dob, required this.id});

  @override
  List<Object> get props => [departmentName, dob, id];
}

class UpdateDepartment extends DepartmentEvent {
  final int id;
  final String departmentName;
  final String dob;
  final int? adminId; // Added adminId for refreshing the list after update

  const UpdateDepartment({
    required this.id,
    required this.departmentName,
    required this.dob,
    this.adminId,
  });

  @override
  List<Object> get props => [id, departmentName, dob, adminId ?? 0];
}

class DeleteDepartment extends DepartmentEvent {
  final int id;
  final int? adminId; // Added adminId for refreshing the list after deletion

  const DeleteDepartment({required this.id, this.adminId});

  @override
  List<Object> get props => [id, adminId ?? 0];
}