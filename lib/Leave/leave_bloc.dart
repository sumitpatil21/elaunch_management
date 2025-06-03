import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Service/firebaseDatabase.dart';
import '../Service/leave_modal.dart';
import 'leave_event.dart';
import 'leave_state.dart';

class LeaveBloc extends Bloc<LeaveEvent, LeaveState> {
  LeaveBloc() : super(const LeaveState()) {
    on<FetchLeaves>(getLeaves);
    on<AddLeave>(addLeave);
    on<DeleteLeave>(deleteLeave);
  }

  Future<void> addLeave(AddLeave event, Emitter<LeaveState> emit) async {
    await FirebaseDbHelper.firebase.addLeave(event.leave);
    print("Leave added");
      add(FetchLeaves());

  }

  Future<void> deleteLeave(DeleteLeave event, Emitter<LeaveState> emit) async {
    await FirebaseDbHelper.firebase.deleteLeave(event.id);
    print("Leave deleted");
      add(FetchLeaves());

  }

  Future<void> getLeaves(FetchLeaves event, Emitter<LeaveState> emit) async {
    final devices = await FirebaseDbHelper.firebase.fetchLeaves();
    emit(LeaveState(leaves: devices));



  }

}