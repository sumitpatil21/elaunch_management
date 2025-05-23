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

  @override
  List<Object?> get props => [adminId, employeeId];
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
  final int id;
  final int? adminId;

  const DeleteDevice({required this.id, this.adminId});

  @override
  List<Object?> get props => [id, adminId];
}