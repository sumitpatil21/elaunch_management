part of 'device_bloc.dart';

sealed class DeviceState extends Equatable {
  const DeviceState();
}

final class DeviceInitial extends DeviceState {
  @override
  List<Object> get props => [];
}
