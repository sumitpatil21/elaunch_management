

import 'package:equatable/equatable.dart';

import '../Service/leave_modal.dart';

class LeaveEvent extends Equatable {
  const LeaveEvent();
  @override
  List<Object?> get props => [];
}

class AddLeave extends LeaveEvent {
  final Leave leave;
  const AddLeave(this.leave);
}

class DeleteLeave extends LeaveEvent {
  final String id;
  const DeleteLeave(this.id);
  @override
  List<Object?> get props => [id];
}

class FetchLeaves extends LeaveEvent {
  final String? employeeId;
  const FetchLeaves({this.employeeId});
  @override
  List<Object?> get props => [employeeId];

}