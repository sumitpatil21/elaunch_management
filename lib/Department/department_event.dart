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
  final int id, adminId;


  const AddDepartment({required this.departmentName, required this.dob, required this.id, required this.adminId});

  @override
  List<Object> get props => [departmentName, dob, id, adminId];
}

class UpdateDepartment extends DepartmentEvent {
  final DepartmentModal departmentModal;

  const UpdateDepartment({
    required this.departmentModal,

  });

  @override
  List<Object> get props => [departmentModal];
}

class DeleteDepartment extends DepartmentEvent {
  final int id;
  final int? adminId; 

  const DeleteDepartment({required this.id, this.adminId});

  @override
  List<Object> get props => [id, adminId ?? 0];
}

class NetworkDepartment extends DepartmentEvent {
   bool? connect;
   NetworkDepartment({  this.connect,});

  @override
  List<Object> get props => [connect!];
}