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

// New events for UI state management
class UpdateSearchQuery extends DeviceEvent {
  final String query;
  const UpdateSearchQuery(this.query);

  @override
  List<Object?> get props => [query];
}

class UpdateStatusFilter extends DeviceEvent {
  final String status;
  const UpdateStatusFilter(this.status);

  @override
  List<Object?> get props => [status];
}

class ClearSearch extends DeviceEvent {
  const ClearSearch();
}

class ShowDeviceDialog extends DeviceEvent {
  final TestingDeviceModal? device;
  const ShowDeviceDialog({this.device});

  @override
  List<Object?> get props => [device];
}

class HideDeviceDialog extends DeviceEvent {
  const HideDeviceDialog();
}

class UpdateDialogField extends DeviceEvent {
  final String field;
  final dynamic value;
  const UpdateDialogField(this.field, this.value);

  @override
  List<Object?> get props => [field, value];
}
