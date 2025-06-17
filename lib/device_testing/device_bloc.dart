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
    on<UpdateSearchQueryDevice>(updateSearchQuery);
    on<UpdateStatusFilterDevice>(updateStatusFilter);
    on<ClearSearchDevice>(clearSearch);

  }

  Future<void> fetchDeviceData(
      FetchDevice event,
      Emitter<DeviceState> emit,
      ) async {

      emit(state.copyWith(isLoading: true, errorMessage: null));

      final devices = await FirebaseDbHelper.firebase.getDevices();

      emit(state.copyWith(
        devices: devices,
        isLoading: false,
      ));

  }

  Future<void> insertDeviceData(
      AddDevice event,
      Emitter<DeviceState> emit,
      ) async {

      emit(state.copyWith(isLoading: true, errorMessage: null));

      await FirebaseDbHelper.firebase.createDevice(event.device);

      // Hide dialog after successful creation
      emit(state.copyWith(
        isDialogVisible: false,
        dialogDevice: null,
        dialogData: {},
      ));

      add(FetchDevice());

  }

  Future<void> updateDeviceData(
      UpdateDevice event,
      Emitter<DeviceState> emit,
      ) async {

      emit(state.copyWith(isLoading: true, errorMessage: null));

      await FirebaseDbHelper.firebase.updateDevice(event.device);

      emit(state.copyWith(
        isDialogVisible: false,
        dialogDevice: null,
        dialogData: {},
      ));


      add(FetchDevice());

  }

  Future<void> deleteDeviceData(
      DeleteDevice event,
      Emitter<DeviceState> emit,
      ) async {

      emit(state.copyWith(isLoading: true, errorMessage: null));

      await FirebaseDbHelper.firebase.deleteDevice(event.id);

      add(FetchDevice());

  }

  void updateSearchQuery(
      UpdateSearchQueryDevice event,
      Emitter<DeviceState> emit,
      ) {
   List<TestingDeviceModal> filteredDevices = event.devices.where((device) => event.query.isEmpty ||
          device.deviceName.toLowerCase().contains(event.query.toLowerCase()) ||
          (device.osVersion?.toLowerCase().contains(event.query.toLowerCase()) ?? false) ||
          (device.assignedEmployeeName?.toLowerCase().contains(event.query.toLowerCase()) ?? false) ||
          (device.operatingSystem?.toLowerCase().contains(event.query.toLowerCase()) ?? false)).toList();
    emit(state.copyWith(searchQuery: event.query,devices: filteredDevices));
  }

  void updateStatusFilter(
      UpdateStatusFilterDevice event,
      Emitter<DeviceState> emit,
      ) {
    emit(state.copyWith(selectedStatusFilter: event.status));
  }

  void clearSearch(
      ClearSearchDevice event,
      Emitter<DeviceState> emit,
      ) {
    emit(state.copyWith(searchQuery: ''));
  }


}