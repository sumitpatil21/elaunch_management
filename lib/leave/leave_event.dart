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

class SelectLeaveType extends LeaveEvent {
  final String leaveType;

  const SelectLeaveType(this.leaveType);

  @override
  List<Object?> get props => [leaveType];
}

class SelectStartDate extends LeaveEvent {
  final DateTime date;

  const SelectStartDate(this.date);

  @override
  List<Object?> get props => [date];
}

class SelectEndDate extends LeaveEvent {
  final DateTime date;


  const SelectEndDate(this.date);

  @override
  List<Object?> get props => [date];
}

class SelectNotifyEmployee extends LeaveEvent {
  final String? employeeName;

  const SelectNotifyEmployee(this.employeeName);

  @override
  List<Object?> get props => [employeeName];
}

class UpdateReason extends LeaveEvent {
  final String reason;

  const UpdateReason(this.reason);
  @override
  List<Object?> get props => [reason];
}

class ResetLeaveForm extends LeaveEvent {
  const ResetLeaveForm();
}

