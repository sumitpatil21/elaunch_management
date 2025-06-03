

import 'package:equatable/equatable.dart';

import '../Service/leave_modal.dart';

 class LeaveState extends Equatable {
  final List<Leave>? leaves;
  const LeaveState({this.leaves});

  @override
  List<Object?> get props => [leaves];

}

