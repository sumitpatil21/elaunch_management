import 'package:elaunch_management/System/system_event.dart';
import 'package:elaunch_management/System/system_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../service/firebase_database.dart';
import '../Service/system_modal.dart';

class SystemBloc extends Bloc<SystemEvent, SystemState> {
  SystemBloc() : super(const SystemState()) {
    on<FetchSystem>(fetchSystemData);
    on<AddSystem>(insertSystemData);
    on<UpdateSystem>(updateSystemData);
    on<DeleteSystem>(deleteSystemData);
    on<RequestSystem>(requestSystemData);
    on<FetchRequests>(fetchRequestsData);
    on<ApproveRequest>(approveRequestData);
    on<RejectRequest>(rejectRequestData);
    on<CancelRequest>(cancelRequestData);
  }

  Future<void> fetchSystemData(
    FetchSystem event,
    Emitter<SystemState> emit,
  ) async {
    final systems = await FirebaseDbHelper.firebase.getSystems();
    emit(state.copyWith(systems: systems));
  }

  Future<void> insertSystemData(
    AddSystem event,
    Emitter<SystemState> emit,
  ) async {
    final system = SystemModal(
      systemName: event.systemName,
      version: event.version ?? "",
      operatingSystem: event.operatingSystem ?? "",
      status: event.status ?? "available",
      adminId: event.adminId,
      employeeId: event.employeeId,
      employeeName: event.employeeName,
    );

    await FirebaseDbHelper.firebase.createSystem(system);
    add(const FetchSystem());
  }

  Future<void> updateSystemData(
    UpdateSystem event,
    Emitter<SystemState> emit,
  ) async {
    await FirebaseDbHelper.firebase.updateSystem(event.system);
    add(const FetchSystem());
  }

  Future<void> deleteSystemData(
    DeleteSystem event,
    Emitter<SystemState> emit,
  ) async {
    await FirebaseDbHelper.firebase.deleteSystem(event.id);
    add(const FetchSystem());
  }

  Future<void> requestSystemData(
    RequestSystem event,
    Emitter<SystemState> emit,
  ) async {
    await FirebaseDbHelper.firebase.createSystemRequests(event.system);
    add(const FetchRequests());
    add(const FetchSystem());
  }

  Future<void> fetchRequestsData(
    FetchRequests event,
    Emitter<SystemState> emit,
  ) async {
    final requests = await FirebaseDbHelper.firebase.fetchRequests();
    emit(state.copyWith(requests: requests));
  }

  Future<void> approveRequestData(
    ApproveRequest event,
    Emitter<SystemState> emit,
  ) async {
    await FirebaseDbHelper.firebase.approveSystemRequest(event.system);
    add(const FetchRequests());
    add(const FetchSystem());
  }

  Future<void> rejectRequestData(
    RejectRequest event,
    Emitter<SystemState> emit,
  ) async {
    await FirebaseDbHelper.firebase.rejectSystemRequest(event.system);
    add(const FetchRequests());
    add(const FetchSystem());
  }

  Future<void> cancelRequestData(
    CancelRequest event,
    Emitter<SystemState> emit,
  ) async {
    await FirebaseDbHelper.firebase.cancelSystemRequest(
      event.systemId,
      event.requestId,
    );
    add(const FetchRequests());
    add(const FetchSystem());
  }
}
