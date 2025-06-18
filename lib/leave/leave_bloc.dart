import 'dart:developer';
import 'package:bloc/bloc.dart';
import '../Leave/leave_event.dart';
import '../Leave/leave_state.dart';
import '../Service/firebase_database.dart';
import '../Service/leave_modal.dart';

class LeaveBloc extends Bloc<LeaveEvent, LeaveState> {
  LeaveBloc() : super(LeaveState()) {
    on<FetchLeaves>(fetchLeaves);
    on<AddLeave>(addLeave);
    on<UpdateLeaveStatus>(updateLeaveStatus);
    on<DeleteLeave>(deleteLeave);
    on<FilterLeavesByStatus>(filterLeavesByStatus);
    on<SearchLeaves>(searchLeaves);
    on<SelectLeaveType>(selectLeaveType);
    on<SelectStartDate>(selectStartDate);
    on<SelectEndDate>(selectEndDate);
    on<SelectNotifyEmployee>(selectNotifyEmployee);
    on<UpdateReason>(updateReason);
    on<ResetLeaveForm>(resetLeaveForm);
  }

  Future<void> fetchLeaves(
    FetchLeaves event,
    Emitter<LeaveState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));

      log(
        'Fetching leaves for employeeId: ${event.employeeId}, status: ${event.status}',
      );

      final leaves = await FirebaseDbHelper.firebase.getLeaves(
        employeeId: event.employeeId,
        status: event.status,
      );

      log('Fetched ${leaves.length} leaves from Firebase');

      emit(
        state.copyWith(
          leaves: leaves,
          filteredLeaves: leaves,
          isLoading: false,
          error: null,
        ),
      );
    } catch (e) {
      log('Error fetching leaves: $e');
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to fetch leaves: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> addLeave(AddLeave event, Emitter<LeaveState> emit) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));

      log('Adding new leave: ${event.leave.toString()}');

      final leaveWithId =
          event.leave.id.isEmpty
              ? event.leave.copyWith(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
              )
              : event.leave;

      await FirebaseDbHelper.firebase.createLeaves(leaveWithId);

      final updatedLeaves = [...state.leaves, leaveWithId];

      emit(
        state.copyWith(
          leaves: updatedLeaves,
          filteredLeaves: updatedLeaves,
          isLoading: false,
          error: null,
        ),
      );

      log('Leave added successfully');
    } catch (e) {
      log('Error adding leave: $e');
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to add leave: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> updateLeaveStatus(
    UpdateLeaveStatus event,
    Emitter<LeaveState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));

      log(
        'Updating leave status: ${event.leaveModal.id} to ${event.leaveModal.status}',
      );

      await FirebaseDbHelper.firebase.updateLeaves(event.leaveModal);

      final updatedLeaves =
          state.leaves.map((leave) {
            if (leave.id == event.leaveModal.id) {
              return event.leaveModal;
            }
            return leave;
          }).toList();

      emit(
        state.copyWith(
          leaves: updatedLeaves,
          filteredLeaves: applyCurrentFilters(updatedLeaves),
          isLoading: false,
          error: null,
        ),
      );

      log('Leave status updated successfully');
    } catch (e) {
      log('Error updating leave status: $e');
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to update leave: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> deleteLeave(DeleteLeave event, Emitter<LeaveState> emit) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));

      await FirebaseDbHelper.firebase.deleteLeave(event.id);

      final updatedLeaves =
          state.leaves.where((leave) => leave.id != event.id).toList();

      emit(
        state.copyWith(
          leaves: updatedLeaves,
          filteredLeaves: applyCurrentFilters(updatedLeaves),
          isLoading: false,
          error: null,
        ),
      );

      log('Leave deleted successfully');
    } catch (e) {
      log('Error deleting leave: $e');
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to delete leave: ${e.toString()}',
        ),
      );
    }
  }

  void filterLeavesByStatus(
    FilterLeavesByStatus event,
    Emitter<LeaveState> emit,
  ) {
    final filteredLeaves =
        event.status == null || event.status == 'all'
            ? state.leaves
            : state.leaves
                .where((leave) => leave.status == event.status)
                .toList();

    emit(
      state.copyWith(
        filteredLeaves: filteredLeaves,
        selectedFilter: event.status,
      ),
    );
  }

  void searchLeaves(SearchLeaves event, Emitter<LeaveState> emit) {
    if (event.query.isEmpty) {
      emit(
        state.copyWith(
          filteredLeaves: applyStatusFilter(state.leaves),
          searchQuery: '',
        ),
      );
      return;
    }

    final filteredLeaves =
        state.leaves.where((leave) {
          final query = event.query.toLowerCase();
          return leave.employeeName.toLowerCase().contains(query) ||
              (leave.leaveType?.toLowerCase().contains(query) ?? false) ||
              leave.reason.toLowerCase().contains(query) ||
              leave.status.toLowerCase().contains(query);
        }).toList();

    emit(
      state.copyWith(filteredLeaves: filteredLeaves, searchQuery: event.query),
    );
  }

  void selectLeaveType(SelectLeaveType event, Emitter<LeaveState> emit) {
    emit(state.copyWith(selectedLeaveType: event.leaveType));
  }

  void selectStartDate(SelectStartDate event, Emitter<LeaveState> emit) {
    emit(
      state.copyWith(
        startDate: event.date,
        endDate:
            state.endDate != null && state.endDate!.isBefore(event.date)
                ? null
                : state.endDate,
      ),
    );
  }

  void selectEndDate(SelectEndDate event, Emitter<LeaveState> emit) {
    int x = event.date.difference(state.startDate!).inDays + 1;
    emit(state.copyWith(endDate: event.date, duration: x));
  }

  void selectNotifyEmployee(
    SelectNotifyEmployee event,
    Emitter<LeaveState> emit,
  ) {
    emit(state.copyWith(selectedNotifyEmployee: event.employeeName));
  }

  void updateReason(UpdateReason event, Emitter<LeaveState> emit) {
    emit(state.copyWith(reason: event.reason));
  }

  void resetLeaveForm(ResetLeaveForm event, Emitter<LeaveState> emit) {
    emit(
      state.copyWith(
        selectedLeaveType: 'Annual leave',
        startDate: null,
        endDate: null,
        selectedNotifyEmployee: null,
        reason: '',
      ),
    );
  }

  List<LeaveModal> applyCurrentFilters(List<LeaveModal> leaves) {
    var filtered = leaves;

    if (state.selectedFilter != null && state.selectedFilter != 'all') {
      filtered =
          filtered
              .where((leave) => leave.status == state.selectedFilter)
              .toList();
    }

    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filtered =
          filtered.where((leave) {
            return leave.employeeName.toLowerCase().contains(query) ||
                (leave.leaveType?.toLowerCase().contains(query) ?? false) ||
                leave.reason.toLowerCase().contains(query) ||
                leave.status.toLowerCase().contains(query);
          }).toList();
    }

    return filtered;
  }

  List<LeaveModal> applyStatusFilter(List<LeaveModal> leaves) {
    if (state.selectedFilter == null || state.selectedFilter == 'all') {
      return leaves;
    }
    return leaves
        .where((leave) => leave.status == state.selectedFilter)
        .toList();
  }
}
