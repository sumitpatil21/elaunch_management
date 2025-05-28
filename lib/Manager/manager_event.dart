// part of 'manager_bloc.dart';
//
// abstract class ManagerEvent extends Equatable {
//   const ManagerEvent();
//
//   @override
//   List<Object?> get props => [];
// }
//
// class FetchManagers extends ManagerEvent {
//   final int? departmentId;
//   final int adminId;
//
//   const FetchManagers({this.departmentId, required this.adminId});
//
//   @override
//   List<Object?> get props => [departmentId, adminId];
// }
//
// class AddManager extends ManagerEvent {
//   final int id;
//   final String name;
//   final String email;
//   final String address;
//   final String dob;
//   final int departmentId;
//   final int? adminId;
//   final String? departmentName;
//
//   const AddManager({
//     required this.id,
//     required this.name,
//     required this.email,
//     required this.address,
//     required this.dob,
//     required this.departmentId,
//     this.adminId,
//     this.departmentName,
//   });
//
//   @override
//   List<Object?> get props => [
//     id,
//     name,
//     email,
//     address,
//     dob,
//     departmentId,
//     adminId,
//     departmentName,
//   ];
// }
//
// class UpdateManager extends ManagerEvent {
//   final int id;
//   final String name;
//   final String email;
//   final String address;
//   final String dob;
//   final int departmentId;
//   final int? adminId;
//
//   const UpdateManager({
//     required this.id,
//     required this.name,
//     required this.email,
//     required this.address,
//     required this.dob,
//     required this.departmentId,
//     this.adminId,
//   });
//
//   @override
//   List<Object?> get props => [
//     id,
//     name,
//     email,
//     address,
//     dob,
//     departmentId,
//     adminId,
//   ];
// }
//
//
// class DeleteManager extends ManagerEvent {
//   final String id; // Firebase document ID
//   final int? departmentId;
//   final int? adminId;
//
//   const DeleteManager(this.id, {this.departmentId, this.adminId});
//
//   @override
//   List<Object?> get props => [id, departmentId, adminId];
// }
//
// class ManagerScreenArguments extends ManagerEvent {
//
//   final DepartmentModal? department;
//   final MangerModal? manager;
//   final List<DepartmentModal>? departmentList;
//
//   const ManagerScreenArguments({
//
//     this.department,
//     this.manager,
//     this.departmentList,
//   });
//
//   @override
//   List<Object?> get props => [
//
//     department,
//     departmentList,
//     manager,
//   ];
// }