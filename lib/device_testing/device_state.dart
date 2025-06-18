part of 'device_bloc.dart';

class DeviceState extends Equatable {
  final List<TestingDeviceModal> devices;
  final List<TestingDeviceModal> filteredDevices;
  final String searchQuery;
  final String statusFilter;
  final Map<String, Color> statusColors;


  const DeviceState({
    this.devices = const [],
    this.filteredDevices = const [],
    this.searchQuery = '',
    this.statusFilter = 'all',
    this.statusColors = const {},

  });

  DeviceState copyWith({
    List<TestingDeviceModal>? allDevices,
    List<TestingDeviceModal>? filteredDevices,
    String? searchQuery,
    String? statusFilter,
    Map<String, Color>? statusColors,
    bool? isLoading,
  }) {
    return DeviceState(
      devices: allDevices ?? this.devices,
      filteredDevices: filteredDevices ?? this.filteredDevices,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      statusColors: statusColors ?? this.statusColors,

    );
  }

  @override
  List<Object?> get props => [
    devices,
    filteredDevices,
    searchQuery,
    statusFilter,
    statusColors,

  ];
}