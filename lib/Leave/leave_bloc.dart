import 'dart:developer';
import 'package:bloc/bloc.dart';
import '../Service/firebaseDatabase.dart';
import '../Service/leave_modal.dart';
import 'leave_event.dart';
import 'leave_state.dart';

class LeaveBloc extends Bloc<LeaveEvent, LeaveState> {
  LeaveBloc() : super(const LeaveState()) {
    on<FetchLeaves>(fetchLeaves);
    on<AddLeave>(addLeave);
    on<UpdateLeaveStatus>(updateLeaveStatus);
    on<DeleteLeave>(deleteLeave);
    on<FilterLeavesByStatus>(filterLeavesByStatus);
    on<SearchLeaves>(searchLeaves);
  }

  Future<void> fetchLeaves(FetchLeaves event, Emitter<LeaveState> emit) async {
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
  }

  Future<void> addLeave(AddLeave event, Emitter<LeaveState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    log('Adding new leave: ${event.leave.toString()}');

    final leaveWithId =
        event.leave.id.isEmpty
            ? event.leave.copyWith(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
            )
            : event.leave;

    await FirebaseDbHelper.firebase.createLeaves(leaveWithId);
    log('Leave added successfully');
  }

  Future<void> updateLeaveStatus(
    UpdateLeaveStatus event,
    Emitter<LeaveState> emit,
  ) async {
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
        filteredLeaves: updatedLeaves,
        isLoading: false,
        error: null,
      ),
    );

    log('Leave status updated successfully');
  }

  Future<void> deleteLeave(DeleteLeave event, Emitter<LeaveState> emit) async {
    await FirebaseDbHelper.firebase.deleteLeave(event.id);

    final updatedLeaves =
        state.leaves.where((leave) => leave.id != event.id).toList();

    emit(
      state.copyWith(
        leaves: updatedLeaves,
        filteredLeaves: updatedLeaves,
        isLoading: false,
        error: null,
      ),
    );

    log('Leave deleted successfully');
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
      emit(state.copyWith(filteredLeaves: state.leaves, searchQuery: ''));
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
}
