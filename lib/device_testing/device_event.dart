// device_event.dart - Updated Events
import 'package:equatable/equatable.dart';
import '../Service/device_modal.dart';

class DeviceEvent extends Equatable {
  const DeviceEvent();

  @override
  List<Object?> get props => [];
}

class FetchDevice extends DeviceEvent {
  final String? employeeId;
  const FetchDevice({this.employeeId});

  @override
  List<Object?> get props => [employeeId];
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
  const DeleteDevice(this.id);

  @override
  List<Object?> get props => [id];
}


class UpdateSearchQueryDevice extends DeviceEvent {
  final String query;
  final List<TestingDeviceModal> devices;
  const UpdateSearchQueryDevice(this.query, this.devices);

  @override
  List<Object?> get props => [query, devices];
}

class UpdateStatusFilterDevice extends DeviceEvent {
  final String status;
  const UpdateStatusFilterDevice(this.status);

  @override
  List<Object?> get props => [status];
}

class ClearSearchDevice extends DeviceEvent {
  const ClearSearchDevice();
}
