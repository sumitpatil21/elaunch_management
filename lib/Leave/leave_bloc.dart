

import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Service/firebaseDatabase.dart';
import '../Service/leave_modal.dart';
import 'leave_event.dart';
import 'leave_state.dart';

class LeaveBloc extends Bloc<LeaveEvent, LeaveState> {
  LeaveBloc() : super(const LeaveState()) {
    on<FetchLeaves>(_onFetchLeaves);
    on<AddLeave>(_onAddLeave);
    on<UpdateLeaveStatus>(_onUpdateLeaveStatus);
    on<DeleteLeave>(_onDeleteLeave);
    on<FilterLeavesByStatus>(_onFilterLeavesByStatus);
    on<SearchLeaves>(_onSearchLeaves);
  }

  Future<void> _onFetchLeaves(
      FetchLeaves event,
      Emitter<LeaveState> emit,
      ) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));

      final leaves = await FirebaseDbHelper.firebase.getLeaves(
        employeeId: event.employeeId,
      );

      emit(state.copyWith(
        leaves: leaves,
        filteredLeaves: event.status != null
            ? leaves.where((leave) => leave.status == event.status).toList()
            : leaves,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to fetch leaves: ${e.toString()}',
      ));
    }
  }

  Future<void> _onAddLeave(
      AddLeave event,
      Emitter<LeaveState> emit,
      ) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));
      log(event.leave.reason);
      await FirebaseDbHelper.firebase.createLeaves(event.leave);

      // Refresh the leaves list
      add(FetchLeaves(employeeId: event.leave.employeeId));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to add leave: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUpdateLeaveStatus(
      UpdateLeaveStatus event,
      Emitter<LeaveState> emit,
      ) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));

      await FirebaseDbHelper.firebase.updateLeaves(event.leaveModal);

      // Update the local state immediately for better UX
      final updatedLeaves = state.leaves.map((leave) {
        if (leave.id == event.leaveModal.id) {
          return event.leaveModal;
        }
        return leave;
      }).toList();

      emit(state.copyWith(
        leaves: updatedLeaves,
        filteredLeaves: updatedLeaves,
        isLoading: false,
        error: null,
      ));

      // Refresh from server to ensure consistency
      add(FetchLeaves());
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to update leave status: ${e.toString()}',
      ));
    }
  }

  Future<void> _onDeleteLeave(
      DeleteLeave event,
      Emitter<LeaveState> emit,
      ) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));

      await FirebaseDbHelper.firebase.deleteLeave(event.id);

      // Remove from local state immediately
      final updatedLeaves = state.leaves.where((leave) => leave.id != event.id).toList();

      emit(state.copyWith(
        leaves: updatedLeaves,
        filteredLeaves: updatedLeaves,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to delete leave: ${e.toString()}',
      ));
    }
  }

  void _onFilterLeavesByStatus(
      FilterLeavesByStatus event,
      Emitter<LeaveState> emit,
      ) {
    final filteredLeaves = event.status == null || event.status == 'all'
        ? state.leaves
        : state.leaves.where((leave) => leave.status == event.status).toList();

    emit(state.copyWith(
      filteredLeaves: filteredLeaves,
      selectedFilter: event.status,
    ));
  }

  void _onSearchLeaves(
      SearchLeaves event,
      Emitter<LeaveState> emit,
      ) {
    if (event.query.isEmpty) {
      emit(state.copyWith(
        filteredLeaves: state.leaves,
        searchQuery: '',
      ));
      return;
    }

    final filteredLeaves = state.leaves.where((leave) {
    final query = event.query.toLowerCase();
    return leave.employeeName.toLowerCase().contains(query) ||
    leave.leaveType!.toLowerCase().contains(query) ||
    leave.reason.toLowerCase().contains(query) ||
    leave.status.toLowerCase().contains(query);
    }).toList();

    emit(state.copyWith(
    filteredLeaves: filteredLeaves,
    searchQuery: event.query,
    ));
  }
}

