part of 'employee_bloc.dart';

class EmployeeState extends Equatable {
 final List<EmployeeModal> employees;
 const EmployeeState({this.employees = const []});

 EmployeeState copyWith({List<EmployeeModal>? employees}) {
  return EmployeeState(employees: employees??this.employees);
 }

 @override
 List<Object> get props => [employees];
}