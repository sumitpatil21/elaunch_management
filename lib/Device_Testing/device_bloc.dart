import 'package:bloc/bloc.dart';
import 'package:elaunch_management/Service/device_modal.dart';
import 'package:equatable/equatable.dart';

import '../Service/firebaseDatabase.dart';


import 'device_event.dart';

part 'device_state.dart';

class DeviceBloc extends Bloc<DeviceEvent, DeviceState> {
  DeviceBloc() : super(const DeviceState()) {
    on<FetchDevice>(_fetchDeviceData);
    on<AddDevice>(_insertDeviceData);
    on<UpdateDevice>(_updateDeviceData);
    on<DeleteDevice>(_deleteDeviceData);
  }

  Future<void> _fetchDeviceData(FetchDevice event, Emitter<DeviceState> emit) async {
    try {
      // Local DB (commented)
      // final devices = await DbHelper.dbHelper.fetchAllTestingDevices(adminId: event.adminId);

      final devices = await FirebaseDbHelper.firebaseDbHelper.fetchDevices(adminId: event.adminId??1);
      emit(DeviceState(devices: devices));
    } catch (e) {
      emit(DeviceState(devices: [], error: e.toString()));
    }
  }

  Future<void> _insertDeviceData(AddDevice event, Emitter<DeviceState> emit) async {
    try {
      // Local DB (commented)
      // await DbHelper.dbHelper.insertIntoTestingDevice(...);

      await FirebaseDbHelper.firebaseDbHelper.insertDevice(event.device);
      add(FetchDevice(adminId: event.device.adminId));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _updateDeviceData(UpdateDevice event, Emitter<DeviceState> emit) async {
    try {
      // Local DB (commented)
      // await DbHelper.dbHelper.updateTestingDevice(...);

      await FirebaseDbHelper.firebaseDbHelper.updateDevice(event.device);
      add(FetchDevice(adminId: event.device.adminId));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _deleteDeviceData(DeleteDevice event, Emitter<DeviceState> emit) async {
    try {
      // Local DB (commented)
      // await DbHelper.dbHelper.deleteTestingDevice(event.id);

      await FirebaseDbHelper.firebaseDbHelper.deleteDevice("${event.id}");
      add(FetchDevice(adminId: event.adminId));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}