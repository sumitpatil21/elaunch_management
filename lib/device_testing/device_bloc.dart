
import 'dart:ui';
import 'package:bloc/bloc.dart';
import 'package:elaunch_management/Service/device_modal.dart';
import 'package:equatable/equatable.dart';
import '../Service/firebase_database.dart';
import 'device_event.dart';

part 'device_state.dart';

class DeviceBloc extends Bloc<DeviceEvent, DeviceState> {
  DeviceBloc() : super(const DeviceState()) {
    on<FetchDevice>(fetchDeviceData);
    on<AddDevice>(insertDeviceData);
    on<UpdateDevice>(updateDeviceData);
    on<DeleteDevice>(deleteDeviceData);
    on<FilterSystems>(filterSystems);
    on<SearchSystems>(searchSystems);
    on<ClearSearch>(clearFilters);
  }

  Future<void> fetchDeviceData(
      FetchDevice event,
      Emitter<DeviceState> emit,
      ) async {
    try {
      final devices = await FirebaseDbHelper.firebase.getDevices();

      emit(state.copyWith(
        allDevices: devices,
        filteredDevices: devices,
      ));
    } catch (e) {
      // Handle error appropriately
      print('Error fetching devices: $e');
    }
  }

  Future<void> insertDeviceData(
      AddDevice event,
      Emitter<DeviceState> emit,
      ) async {
    try {
      await FirebaseDbHelper.firebase.createDevice(event.device);
      add(FetchDevice());
    } catch (e) {
      print('Error adding device: $e');
    }
  }

  Future<void> updateDeviceData(
      UpdateDevice event,
      Emitter<DeviceState> emit,
      ) async {
    try {
      await FirebaseDbHelper.firebase.updateDevice(event.device);
      add(FetchDevice());
    } catch (e) {
      print('Error updating device: $e');
    }
  }

  Future<void> deleteDeviceData(
      DeleteDevice event,
      Emitter<DeviceState> emit,
      ) async {
    try {
      await FirebaseDbHelper.firebase.deleteDevice(event.id);
      add(FetchDevice());
    } catch (e) {
      print('Error deleting device: $e');
    }
  }

  void applyFilters(Emitter<DeviceState> emit) {
    List<TestingDeviceModal> filtered = List.from(state.devices);


    if (state.statusFilter != 'all') {
      filtered = filtered
          .where((device) => device.status.toLowerCase() == state.statusFilter.toLowerCase())
          .toList();
    }

    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filtered = filtered.where((device) {
        return device.deviceName.toLowerCase().contains(query) ||
            (device.osVersion?.toLowerCase().contains(query) ?? false) ||
            (device.assignedEmployeeName?.toLowerCase().contains(query) ?? false) ||
            (device.operatingSystem?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    emit(state.copyWith(filteredDevices: filtered));
  }

  void filterSystems(
      FilterSystems event,
      Emitter<DeviceState> emit,
      ) {
    emit(state.copyWith(statusFilter: event.statusFilter));
    applyFilters(emit);
  }

  void searchSystems(
      SearchSystems event,
      Emitter<DeviceState> emit,
      ) {
    emit(state.copyWith(searchQuery: event.searchQuery));
    applyFilters(emit);
  }

  void clearFilters(
      ClearSearch event,
      Emitter<DeviceState> emit,
      ) {
    emit(state.copyWith(
      searchQuery: '',
      statusFilter: 'all',
      filteredDevices: state.devices,
    ));
  }
}


