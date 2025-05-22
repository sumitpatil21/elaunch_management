import 'package:bloc/bloc.dart';
import 'package:elaunch_management/Service/device_modal.dart';
import 'package:equatable/equatable.dart';

import '../Service/db_helper.dart';
import '../Service/system_modal.dart';
import 'device_event.dart';


part 'device_state.dart';

class DeviceBloc extends Bloc<DeviceEvent, DeviceState> {
  DeviceBloc(super.initialState) {
    on<FetchDevice>(fetchDeviceData);
    on<AddDevice>(insertDeviceData);
    on<DeleteDevice>(deleteDeviceData);
  }

  Future<void> fetchDeviceData(
    FetchDevice event,
    Emitter<DeviceState> emit,
  ) async {
    final systems = await DbHelper.dbHelper.fetchAllTestingDevices(
      adminId: event.adminId
    );

    emit(DeviceState(devices: systems));
  }

  Future<void> insertDeviceData(
    AddDevice event,
    Emitter<DeviceState> emit,
  ) async {
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
    add(FetchDevice(adminId: event.device.adminId, employeeId: event.device.assignedToEmployeeId));
  }



  Future<void> deleteDeviceData(
    DeleteDevice event,
    Emitter<DeviceState> emit,
  ) async {
    await DbHelper.dbHelper.deleteSystem(event.id);
    add(
      FetchDevice(
       adminId: event.id,
      ),
    );
  }
}
