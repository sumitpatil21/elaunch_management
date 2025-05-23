import 'package:bloc/bloc.dart';
import 'package:elaunch_management/Service/device_modal.dart';
import 'package:equatable/equatable.dart';

import '../Service/db_helper.dart';
import 'device_event.dart';

part 'device_state.dart';

class DeviceBloc extends Bloc<DeviceEvent, DeviceState> {
  DeviceBloc(super.initialState) {
    on<FetchDevice>(fetchDeviceData);
    on<AddDevice>(insertDeviceData);
    on<UpdateDevice>(updateDeviceData);
    on<DeleteDevice>(deleteDeviceData);
  }

  Future<void> fetchDeviceData(
      FetchDevice event,
      Emitter<DeviceState> emit,
      ) async {
    try {
      final devices = await DbHelper.dbHelper.fetchAllTestingDevices(
          adminId: event.adminId
      );
      emit(DeviceState(devices: devices));
    } catch (e) {
      emit(DeviceState(devices: [], error: e.toString()));
    }
  }

  Future<void> insertDeviceData(
      AddDevice event,
      Emitter<DeviceState> emit,
      ) async {
    try {
      await DbHelper.dbHelper.insertIntoTestingDevice(
        deviceName: event.device.deviceName,
        osVersion: event.device.osVersion ?? "",
        adminId: event.device.adminId,
        assignedToEmployeeId: event.device.assignedToEmployeeId,
        lastCheckInDate: event.device.lastCheckInDate,
        lastCheckOutDate: event.device.lastCheckOutDate,
        operatingSystem: event.device.operatingSystem,
        status: event.device.status,
      );

      // Refresh the device list
      add(FetchDevice(adminId: event.device.adminId));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> updateDeviceData(
      UpdateDevice event,
      Emitter<DeviceState> emit,
      ) async {
    try {
      await DbHelper.dbHelper.updateTestingDevice(
        id: event.device.id!,
        deviceName: event.device.deviceName,
        osVersion: event.device.osVersion ?? "",
        adminId: event.device.adminId,
        assignedToEmployeeId: event.device.assignedToEmployeeId,
        lastCheckInDate: event.device.lastCheckInDate,
        lastCheckOutDate: event.device.lastCheckOutDate,
        operatingSystem: event.device.operatingSystem,
        status: event.device.status,
      );

      // Refresh the device list
      add(FetchDevice(adminId: event.device.adminId));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> deleteDeviceData(
      DeleteDevice event,
      Emitter<DeviceState> emit,
      ) async {
    try {
      await DbHelper.dbHelper.deleteTestingDevice(event.id);

      // Refresh the device list
      add(FetchDevice(adminId: event.adminId));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}