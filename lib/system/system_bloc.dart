



import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../Service/firebase_database.dart';
import '../Service/system_modal.dart';
import '../System/system_event.dart';
import '../System/system_state.dart';

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
    on<FilterSystems>(filterSystems);
    on<SearchSystems>(searchSystems);
    on<ClearSearch>(clearFilters);
  }




  Future<void> fetchSystemData(
      FetchSystem event,
      Emitter<SystemState> emit,
      ) async {
    final systems = await FirebaseDbHelper.firebase.getSystems();
    emit(state.copyWith(
      systems: systems,
      displayedSystems: systems, // Initialize displayedSystems
    ));
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

  Future<void> applyFilters(Emitter<SystemState> emit) async {
    List<SystemModal> filtered = state.systems;


    if (state.statusFilter != 'all') {
    filtered = filtered
        .where((system) => system.status == state.statusFilter)
        .toList();
    }

    // Apply search filter
    if (state.searchQuery.isNotEmpty) {
    final query = state.searchQuery.toLowerCase();
    filtered = filtered.where((system) {
    return system.systemName.toLowerCase().contains(query) ||
    (system.version?.toLowerCase().contains(query) ?? false) ||
    (system.employeeName?.toLowerCase().contains(query) ?? false) ||
    (system.operatingSystem?.toLowerCase().contains(query) ?? false);
    }).toList();
    }

    emit(state.copyWith(displayedSystems: filtered));
  }

  Future<void> filterSystems(
      FilterSystems event,
      Emitter<SystemState> emit,
      ) async {
    emit(state.copyWith(statusFilter: event.statusFilter));
    await applyFilters(emit);
  }

  Future<void> searchSystems(
      SearchSystems event,
      Emitter<SystemState> emit,
      ) async {
    emit(state.copyWith(searchQuery: event.searchQuery));
    await applyFilters(emit);
  }

  Future<void> clearFilters(
      ClearSearch event,
      Emitter<SystemState> emit,
      ) async {
    emit(state.copyWith(
      searchQuery: '',
      statusFilter: 'all',
      displayedSystems: state.systems,
    ));
  }
}