part of 'device_bloc.dart';

class DeviceState extends Equatable {
 final List<TestingDeviceModal> devices;
 final String? error;
 final bool isLoading;

 const DeviceState({
  this.devices = const [],
  this.error,
  this.isLoading = false,
 });

 DeviceState copyWith({
  List<TestingDeviceModal>? devices,
  String? error,
  bool? isLoading,
 }) {
  return DeviceState(
   devices: devices ?? this.devices,
   error: error,
   isLoading: isLoading ?? this.isLoading,
  );
 }

 @override
 List<Object?> get props => [devices, error, isLoading];
}