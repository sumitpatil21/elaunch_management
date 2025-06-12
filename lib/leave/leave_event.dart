
import 'package:equatable/equatable.dart';
import '../Service/leave_modal.dart';

abstract class LeaveEvent extends Equatable {
  const LeaveEvent();

  @override
  List<Object?> get props => [];
}

class FetchLeaves extends LeaveEvent {
  final String? employeeId;
  final String? status;

  const FetchLeaves({this.employeeId, this.status});

  @override
  List<Object?> get props => [employeeId, status];
}

class AddLeave extends LeaveEvent {
  final LeaveModal leave;

  const AddLeave(this.leave);

  @override
  List<Object?> get props => [leave];
}

class UpdateLeaveStatus extends LeaveEvent {
  final LeaveModal leaveModal;

  const UpdateLeaveStatus(this.leaveModal);

  @override
  List<Object?> get props => [leaveModal];
}

class DeleteLeave extends LeaveEvent {
  final String id;

  const DeleteLeave(this.id);

  @override
  List<Object?> get props => [id];
}

class FilterLeavesByStatus extends LeaveEvent {
  final String? status;

  const FilterLeavesByStatus(this.status);

  @override
  List<Object?> get props => [status];
}

class SearchLeaves extends LeaveEvent {
  final String query;

  const SearchLeaves(this.query);

  @override
  List<Object?> get props => [query];
}
