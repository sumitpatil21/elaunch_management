part of 'department_bloc.dart';

class DepartmentState extends Equatable {
 final List<DepartmentModal> departments;



 const DepartmentState({
  this.departments = const [],


 });

 DepartmentState copyWith(List<DepartmentModal> depart) {
  return DepartmentState(
   departments: depart ?? this.departments,

  );
 }

 @override
 List<Object> get props => [departments];
}




