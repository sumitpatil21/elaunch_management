import 'package:bloc/bloc.dart';
import 'package:elaunch_management/Service/device_modal.dart';
import 'package:equatable/equatable.dart';

import '../Service/firebase_database.dart';
import 'device_event.dart';

part 'device_state.dart';

class DeviceBloc extends Bloc<DeviceEvent, DeviceState> {
  DeviceBloc() : super(const DeviceState()) {
    on<FetchDevice>(_fetchDeviceData);
    on<AddDevice>(_insertDeviceData);
    on<UpdateDevice>(_updateDeviceData);
    on<DeleteDevice>(_deleteDeviceData);
    on<UpdateSearchQuery>(_updateSearchQuery);
    on<UpdateStatusFilter>(_updateStatusFilter);
    on<ClearSearch>(_clearSearch);
    on<ShowDeviceDialog>(_showDeviceDialog);
    on<HideDeviceDialog>(_hideDeviceDialog);
    on<UpdateDialogField>(_updateDialogField);
  }

  Future<void> _fetchDeviceData(
      FetchDevice event,
      Emitter<DeviceState> emit,
      ) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));

      final devices = await FirebaseDbHelper.firebase.getDevices();

      emit(state.copyWith(
        devices: devices,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to fetch devices: ${e.toString()}',
      ));
    }
  }

  Future<void> _insertDeviceData(
      AddDevice event,
      Emitter<DeviceState> emit,
      ) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));

      await FirebaseDbHelper.firebase.createDevice(event.device);

      // Hide dialog after successful creation
      emit(state.copyWith(
        isDialogVisible: false,
        dialogDevice: null,
        dialogData: {},
      ));

      // Fetch updated data
      add(FetchDevice());
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to add device: ${e.toString()}',
      ));
    }
  }

  Future<void> _updateDeviceData(
      UpdateDevice event,
      Emitter<DeviceState> emit,
      ) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));

      await FirebaseDbHelper.firebase.updateDevice(event.device);

      // Hide dialog after successful update
      emit(state.copyWith(
        isDialogVisible: false,
        dialogDevice: null,
        dialogData: {},
      ));

      // Fetch updated data
      add(FetchDevice());
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update device: ${e.toString()}',
      ));
    }
  }

  Future<void> _deleteDeviceData(
      DeleteDevice event,
      Emitter<DeviceState> emit,
      ) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));

      await FirebaseDbHelper.firebase.deleteDevice(event.id);

      // Fetch updated data
      add(FetchDevice());
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to delete device: ${e.toString()}',
      ));
    }
  }

  void _updateSearchQuery(
      UpdateSearchQuery event,
      Emitter<DeviceState> emit,
      ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void _updateStatusFilter(
      UpdateStatusFilter event,
      Emitter<DeviceState> emit,
      ) {
    emit(state.copyWith(selectedStatusFilter: event.status));
  }

  void _clearSearch(
      ClearSearch event,
      Emitter<DeviceState> emit,
      ) {
    emit(state.copyWith(searchQuery: ''));
  }

  void _showDeviceDialog(
      ShowDeviceDialog event,
      Emitter<DeviceState> emit,
      ) {
    final dialogData = <String, dynamic>{};

    if (event.device != null) {
      // Pre-populate dialog data for editing
      dialogData.addAll({
        'deviceName': event.device!.deviceName,
        'operatingSystem': event.device!.operatingSystem ?? 'Android',
        'osVersion': event.device!.osVersion ?? '',
        'status': event.device!.status ?? 'available',
        'assignedToEmployeeId': event.device!.assignedToEmployeeId,
        'assignedEmployeeName': event.device!.assignedEmployeeName,
      });
    } else {
      // Default values for new device
      dialogData.addAll({
        'deviceName': '',
        'operatingSystem': 'Android',
        'osVersion': '',
        'status': 'available',
        'assignedToEmployeeId': null,
        'assignedEmployeeName': null,
      });
    }

    emit(state.copyWith(
      isDialogVisible: true,
      dialogDevice: event.device,
      dialogData: dialogData,
    ));
  }

  void _hideDeviceDialog(
      HideDeviceDialog event,
      Emitter<DeviceState> emit,
      ) {
    emit(state.copyWith(
      isDialogVisible: false,
      dialogDevice: null,
      dialogData: {},
    ));
  }

  void _updateDialogField(
      UpdateDialogField event,
      Emitter<DeviceState> emit,
      ) {
    final updatedDialogData = Map<String, dynamic>.from(state.dialogData);
    updatedDialogData[event.field] = event.value;

    emit(state.copyWith(dialogData: updatedDialogData));
  }
}