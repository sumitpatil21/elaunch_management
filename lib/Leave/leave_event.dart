import 'package:elaunch_management/Service/leave_modal.dart';
import 'package:equatable/equatable.dart';

abstract class LeaveEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchLeaves extends LeaveEvent {
  final String? employeeId;

  FetchLeaves({this.employeeId});

  @override
  List<Object?> get props => [employeeId];
}

class AddLeave extends LeaveEvent {
  final LeaveModal leave;

  AddLeave(this.leave);

  @override
  List<Object?> get props => [leave];
}

class DeleteLeave extends LeaveEvent {
  final String id;

  DeleteLeave(this.id);

  @override
  List<Object?> get props => [id];
}

class UpdateLeaveStatus extends LeaveEvent {

  final LeaveModal leaveModal;

   UpdateLeaveStatus(this.leaveModal);

  @override
  List<Object?> get props => [leaveModal];
}