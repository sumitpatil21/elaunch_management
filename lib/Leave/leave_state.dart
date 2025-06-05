import 'package:equatable/equatable.dart';
import '../Service/leave_modal.dart';

class LeaveState extends Equatable {
 final List<LeaveModal> leaves;
 final List<LeaveModal> filteredLeaves;
 final bool isLoading;
 final String? error;
 final String? selectedFilter;
 final String searchQuery;

 const LeaveState({
  this.leaves = const [],
  this.filteredLeaves = const [],
  this.isLoading = false,
  this.error,
  this.selectedFilter,
  this.searchQuery = '',
 });

 LeaveState copyWith({
  List<LeaveModal>? leaves,
  List<LeaveModal>? filteredLeaves,
  bool? isLoading,
  String? error,
  String? selectedFilter,
  String? searchQuery,
 }) {
  return LeaveState(
   leaves: leaves ?? this.leaves,
   filteredLeaves: filteredLeaves ?? this.filteredLeaves,
   isLoading: isLoading ?? this.isLoading,
   error: error,
   selectedFilter: selectedFilter ?? this.selectedFilter,
   searchQuery: searchQuery ?? this.searchQuery,
  );
 }

 @override
 List<Object?> get props => [
  leaves,
  filteredLeaves,
  isLoading,
  error,
  selectedFilter,
  searchQuery,
 ];
}