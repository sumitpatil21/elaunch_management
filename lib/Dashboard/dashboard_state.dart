part of 'dashboard_bloc.dart';

class DashboardState extends Equatable {
 final List<EmployeeModal> employee;
 final List<DepartmentModal> department;
 const DashboardState({this.employee = const [], this.department = const []});

 DashboardState copyWith({List<EmployeeModal>? employee, List<DepartmentModal>? department}) {
  return DashboardState(
   employee: employee ?? this.employee,
   department: department ?? this.department,
  );
 }

 @override
 List<Object> get props => [employee, department];
}
