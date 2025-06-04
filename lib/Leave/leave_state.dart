import 'package:equatable/equatable.dart';

import '../Service/leave_modal.dart';
class LeaveState extends Equatable{
 final List<LeaveModal> leaves;


 const LeaveState({
  this.leaves = const [],
 });

 LeaveState copyWith({
  List<LeaveModal>? leaves,
  bool? isLoading,
  String? error,
 }) {
  return LeaveState(
   leaves: leaves ?? this.leaves,

  );
 }
 @override
 List<Object?> get props => [leaves];
}



