part of 'device_bloc.dart';

 class DeviceState extends Equatable {
  final List<TestingDeviceModal> devices;

  const DeviceState({this.devices = const []});

  DeviceState copyWith({List<TestingDeviceModal>? devices}) {
    return DeviceState(devices: devices ?? this.devices);
  }

  List<Object> get props => [devices];
}
