part of 'device_bloc.dart';

class DeviceState extends Equatable {
  final List<TestingDeviceModal> devices;
  final String searchQuery;
  final String selectedStatusFilter;
  final bool isDialogVisible;
  final TestingDeviceModal? dialogDevice;
  final Map<String, dynamic> dialogData;
  final bool isLoading;
  final String? errorMessage;

  const DeviceState({
    this.devices = const [],
    this.searchQuery = '',
    this.selectedStatusFilter = 'all',
    this.isDialogVisible = false,
    this.dialogDevice,
    this.dialogData = const {},
    this.isLoading = false,
    this.errorMessage,
  });

  DeviceState copyWith({
    List<TestingDeviceModal>? devices,
    String? searchQuery,
    String? selectedStatusFilter,
    bool? isDialogVisible,
    TestingDeviceModal? dialogDevice,
    Map<String, dynamic>? dialogData,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DeviceState(
      devices: devices ?? this.devices,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatusFilter: selectedStatusFilter ?? this.selectedStatusFilter,
      isDialogVisible: isDialogVisible ?? this.isDialogVisible,
      dialogDevice: dialogDevice ?? this.dialogDevice,
      dialogData: dialogData ?? this.dialogData,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  List<TestingDeviceModal> get filteredDevices {
    return devices.where((device) {
      final matchesSearch = searchQuery.isEmpty ||
          device.deviceName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          (device.osVersion?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
          (device.assignedEmployeeName?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
          (device.operatingSystem?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false);

      final matchesStatus = selectedStatusFilter == 'all' ||
          (device.status ?? 'available') == selectedStatusFilter;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  List<Object?> get props => [
    devices,
    searchQuery,
    selectedStatusFilter,
    isDialogVisible,
    dialogDevice,
    dialogData,
    isLoading,
    errorMessage,
  ];
}