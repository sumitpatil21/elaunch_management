part of 'dashboard_bloc.dart';

sealed class DashboardEvent extends Equatable {
  const DashboardEvent();
}
class FetchEmployee extends DashboardEvent {
  const FetchEmployee();
  @override
  List<Object> get props => [];
}

class FetchDepartment extends DashboardEvent {
  final int adminId;
  const FetchDepartment(this.adminId);
  @override
  List<Object> get props => [adminId];
}
