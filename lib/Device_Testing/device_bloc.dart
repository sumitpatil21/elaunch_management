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

    final devices = await FirebaseDbHelper.firebase.getDevices(event.adminId??"");
    emit(DeviceState(devices: devices));
  }

  Future<void> _insertDeviceData(AddDevice event, Emitter<DeviceState> emit) async {
    await FirebaseDbHelper.firebase.createDevice(event.device);

    add(FetchDevice(adminId: event.device.adminId ?? ""));
  }

  Future<void> _updateDeviceData(UpdateDevice event, Emitter<DeviceState> emit) async {
    await FirebaseDbHelper.firebase.updateDevice(event.device);
    add(FetchDevice(adminId: event.device.adminId ?? ""));
  }


  Future<void> _deleteDeviceData(DeleteDevice event, Emitter<DeviceState> emit) async {
    await FirebaseDbHelper.firebase.deleteDevice(event.id);

    add(FetchDevice(adminId: event.adminId));
  }
}

