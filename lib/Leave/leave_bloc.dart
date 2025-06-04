import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Service/firebaseDatabase.dart';
import 'leave_event.dart';
import 'leave_state.dart';

class LeaveBloc extends Bloc<LeaveEvent, LeaveState> {
  LeaveBloc() : super(const LeaveState()) {
    on<FetchLeaves>(fetchLeaveData);
    on<AddLeave>(insertLeaveData);
    on<UpdateLeaveStatus>(updateLeaveData);
    on<DeleteLeave>(deleteLeaveData);
  }

  Future<void> fetchLeaveData(
      FetchLeaves event,
      Emitter<LeaveState> emit,
      ) async {
    try {
      emit(state.copyWith(isLoading: true));
      final leaves = await FirebaseDbHelper.firebase.getLeaves(
      );
      emit(LeaveState(leaves: leaves));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> insertLeaveData(
      AddLeave event,
      Emitter<LeaveState> emit,
      ) async {
    try {
      await FirebaseDbHelper.firebase.createLeaves(event.leave);
      add(FetchLeaves(employeeId: event.leave.employeeId));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> updateLeaveData(
      UpdateLeaveStatus event,
      Emitter<LeaveState> emit,
      ) async {
    try {
      await FirebaseDbHelper.firebase.updateLeaves(event.leaveModal);
      add(FetchLeaves());
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> deleteLeaveData(
      DeleteLeave event,
      Emitter<LeaveState> emit,
      ) async {
    try {
      await FirebaseDbHelper.firebase.deleteLeave(event.id);
      add(FetchLeaves());
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}