part of 'device_bloc.dart';

class DeviceState extends Equatable {
  final List<TestingDeviceModal> devices;
  final String searchQuery;
  final String selectedStatusFilter;
  final bool isDialogVisible;

  final bool isLoading;
  final String? errorMessage;

  const DeviceState({
    this.devices = const [],
    this.searchQuery = '',
    this.selectedStatusFilter = 'all',
    this.isDialogVisible = false,

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

      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }



  @override
  List<Object?> get props => [
    devices,
    searchQuery,
    selectedStatusFilter,
    isDialogVisible,

    isLoading,
    errorMessage,
  ];
}