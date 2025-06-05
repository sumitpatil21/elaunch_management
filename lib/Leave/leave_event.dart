
// leave_event.dart
import 'package:equatable/equatable.dart';

import '../Service/leave_modal.dart';

 class LeaveEvent extends Equatable{
  const LeaveEvent();

  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}

class FetchLeaves extends LeaveEvent {
  final String? employeeId;
  final String? status;

  const FetchLeaves({this.employeeId, this.status});
}

class AddLeave extends LeaveEvent {
  final LeaveModal leave;

  const AddLeave(this.leave);
}

class UpdateLeaveStatus extends LeaveEvent {
  final LeaveModal leaveModal;

  const UpdateLeaveStatus(this.leaveModal);
}

class DeleteLeave extends LeaveEvent {
  final String id;

  const DeleteLeave(this.id);
}

class FilterLeavesByStatus extends LeaveEvent {
  final String? status;

  const FilterLeavesByStatus(this.status);
}

class SearchLeaves extends LeaveEvent {
  final String query;

  const SearchLeaves(this.query);
}