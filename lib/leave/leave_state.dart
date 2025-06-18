import 'package:equatable/equatable.dart';
import '../Service/leave_modal.dart';

class LeaveState extends Equatable {
  final List<LeaveModal> leaves;
  final List<LeaveModal> filteredLeaves;


  final String selectedLeaveType;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? selectedNotifyEmployee;
  final String reason;
  final String? selectedFilter;
  final String searchQuery;
  final int duration;

  const LeaveState({
    this.leaves = const [],
    this.filteredLeaves = const [],

    this.selectedLeaveType = 'Annual leave',
    this.startDate,
    this.endDate,
    this.selectedNotifyEmployee,
    this.reason = '',
    this.selectedFilter,
    this.searchQuery = '',
    this.duration = 0,
  });

  LeaveState copyWith({
    List<LeaveModal>? leaves,
    List<LeaveModal>? filteredLeaves,
    bool? isLoading,
    String? error,
    String? selectedLeaveType,
    DateTime? startDate,
    DateTime? endDate,
    String? selectedNotifyEmployee,
    String? reason,
    String? selectedFilter,
    String? searchQuery,
    int? duration,
  }) {
    return LeaveState(
      leaves: leaves ?? this.leaves,
      filteredLeaves: filteredLeaves ?? this.filteredLeaves,

      selectedLeaveType: selectedLeaveType ?? this.selectedLeaveType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      selectedNotifyEmployee:
          selectedNotifyEmployee ?? this.selectedNotifyEmployee,
      reason: reason ?? this.reason,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      duration: duration ?? this.duration,
    );
  }

  @override
  List<Object?> get props => [
    leaves,
    filteredLeaves,

    selectedLeaveType,
    startDate,
    endDate,
    selectedNotifyEmployee,
    reason,
    selectedFilter,
    searchQuery,
    duration,
  ];
}
