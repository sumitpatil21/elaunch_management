part of 'department_bloc.dart';

class DepartmentEvent extends Equatable {
  const DepartmentEvent();

  @override
  List<Object> get props => [];
}

class FetchDepartments extends DepartmentEvent {
  final String? adminId;

  const FetchDepartments({this.adminId});

  @override
  List<Object> get props => [adminId ?? ""];
}

class AddDepartment extends DepartmentEvent {
  final String departmentName;
  final String dob, adminId;
  final int id;
  // Removed int id since Firestore generates document IDs automatically

  const AddDepartment({
    required this.departmentName,
    required this.dob,
    required this.adminId,
    required this.id,
  });

  @override
  List<Object> get props => [departmentName, dob, adminId,id];
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
  final String id; // Changed from int to String to match Firestore document IDs
  final String? adminId; // Changed from int? to String?

  const DeleteDepartment({required this.id, this.adminId});

  @override
  List<Object> get props => [id, adminId ?? ""];
}