import 'package:equatable/equatable.dart';

import '../Service/device_modal.dart';

class DeviceEvent extends Equatable {
  const DeviceEvent();

  @override
  List<Object?> get props => [];
}

class FetchDevice extends DeviceEvent {

  final String? employeeId;

  const FetchDevice({ this.employeeId});

  @override
  List<Object?> get props => [ employeeId];
}

class AddDevice extends DeviceEvent {
  final TestingDeviceModal device;

  const AddDevice(this.device);

  @override
  List<Object?> get props => [device];
}

class UpdateDevice extends DeviceEvent {
  final TestingDeviceModal device;

  const UpdateDevice(this.device);

  @override
  List<Object?> get props => [device];
}

class DeleteDevice extends DeviceEvent {
  final String id;
  final String? adminId;

  const DeleteDevice({required this.id, this.adminId});

  @override
  List<Object?> get props => [id, adminId];
}
