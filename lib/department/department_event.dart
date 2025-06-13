part of 'department_bloc.dart';

class DepartmentEvent extends Equatable {
  const DepartmentEvent();

  @override
  List<Object> get props => [];
}

class FetchDepartments extends DepartmentEvent {
  const FetchDepartments();

  @override
  List<Object> get props => [];
}

class AddDepartment extends DepartmentEvent {
  final String departmentName;
  final String dob;
  final int id;

  const AddDepartment({
    required this.departmentName,
    required this.dob,

    required this.id,
  });

  @override
  List<Object> get props => [departmentName, dob, id];
}

class UpdateDepartment extends DepartmentEvent {
  final DepartmentModal departmentModal;

  const UpdateDepartment({required this.departmentModal});

  @override
  List<Object> get props => [departmentModal];
}

class DeleteDepartment extends DepartmentEvent {
  final String id;
  final String? adminId;

  const DeleteDepartment({required this.id, this.adminId});

  @override
  List<Object> get props => [id, adminId ?? ""];
}
