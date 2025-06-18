// device_event.dart - Updated Events
import 'dart:ui';

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


class LoadStatusColors extends DeviceEvent {
  const LoadStatusColors();
}

class UpdateStatusColor extends DeviceEvent {
  final String status;
  final Color color;

  const UpdateStatusColor(this.status, this.color);

  @override
  List<Object> get props => [status, color];
}

class FilterSystems extends DeviceEvent {
  final String statusFilter;

  const FilterSystems({required this.statusFilter});

  @override
  List<Object> get props => [statusFilter];
}

class SearchSystems extends DeviceEvent {
  final String searchQuery;

  const SearchSystems({required this.searchQuery});

  @override
  List<Object> get props => [searchQuery];
}


class ClearSearch extends DeviceEvent {
  const ClearSearch();
  @override
  List<Object> get props => [];

}
