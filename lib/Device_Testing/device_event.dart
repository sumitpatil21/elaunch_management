import 'package:equatable/equatable.dart';

import '../Service/device_modal.dart';

 class DeviceEvent extends Equatable {
  const DeviceEvent();

  @override
  List<Object?> get props => [];
}

class FetchDevice extends DeviceEvent {
  final int? adminId;
  final int? employeeId;

  const FetchDevice({this.adminId, this.employeeId});
}

class AddDevice extends DeviceEvent {
  final TestingDeviceModal device;

  const AddDevice(this.device);
}

class UpdateDevice extends DeviceEvent {
  final TestingDeviceModal device;

  const UpdateDevice(this.device);
}

class DeleteDevice extends DeviceEvent {
  final int id;

  const DeleteDevice(this.id);
}