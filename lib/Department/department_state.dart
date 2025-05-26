part of 'department_bloc.dart';

class DepartmentState extends Equatable {
 final List<DepartmentModal> departments,fireDepartments;
 final bool connect;


 const DepartmentState({
  this.departments = const [],
  this.fireDepartments = const [],
  this.connect = false, // Default value for connect
 });

 DepartmentState copyWith({List<DepartmentModal>? depart, List<DepartmentModal>? fireDepart, bool? network}) {
  return DepartmentState(
   departments: depart ?? this.departments,
   fireDepartments: fireDepart ?? this.fireDepartments,
   connect: network ?? this.connect,
  );
 }

 @override
 List<Object> get props => [departments,connect,fireDepartments];
}




