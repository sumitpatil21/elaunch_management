
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../Service/firebaseDatabase.dart';
import '../Service/system_modal.dart';

part 'system_event.dart';
part 'system_state.dart';

class SystemBloc extends Bloc<SystemEvent, SystemState> {
  SystemBloc() : super(const SystemState()) {
    on<FetchSystem>(_fetchSystemData);
    on<AddSystem>(_insertSystemData);
    on<UpdateSystem>(_updateSystemData);
    on<DeleteSystem>(_deleteSystemData);
  }


  Future<void> _fetchSystemData(FetchSystem event, Emitter<SystemState> emit) async {
    try {
      // Commented out local DB fetching:
      // final systems = await DbHelper.dbHelper.fetchSystems(
      //   employeeId: event.employeeId,
      //   adminId: event.adminId,
      // );


      final systems = await FirebaseDbHelper.firebaseDbHelper.fetchSystems(
        adminId: event.adminId,
        employeeId: event.employeeId,
      );

      emit(SystemState(systems: systems));
    } catch (e) {
      // handle error, maybe emit error state
      print("Error fetching systems: $e");
      emit(const SystemState(systems: []));
    }
  }

  Future<void> _insertSystemData(AddSystem event, Emitter<SystemState> emit) async {
    try {
      // Commented out local DB insert:
      // await DbHelper.dbHelper.insertIntoSystem(
      //   systemName: event.systemName,
      //   version: event.version ?? "",
      //   operatingSystem: event.operatingSystem ?? "",
      //   status: event.status ?? "available",
      //   adminId: event.adminId,
      //   managerId: event.managerId,
      //   employeeId: event.employeeId,
      //   employeeName: event.employeeName,
      // );


      await FirebaseDbHelper.firebaseDbHelper.insertSystem(
        system: SystemModal(
          systemName: event.systemName,
          version: event.version ?? "",
          operatingSystem: event.operatingSystem ?? "",
          status: event.status ?? "available",
          adminId: event.adminId,
          managerId: event.managerId,
          employeeId: event.employeeId,
          employeeName: event.employeeName,
        ),
      );

      add(FetchSystem(adminId: event.adminId, employeeId: event.employeeId));
    } catch (e) {
      print("Error inserting system: $e");
    }
  }


  Future<void> _updateSystemData(UpdateSystem event, Emitter<SystemState> emit) async {
    try {
      // Commented out local DB update:
      // await DbHelper.dbHelper.updateSystem(
      //   id: event.id,
      //   systemName: event.systemName,
      //   version: event.version ?? "",
      //   operatingSystem: event.operatingSystem ?? "",
      //   status: event.status ?? "available",
      //   adminId: event.adminId,
      //   managerId: event.managerId,
      //   employeeId: event.employeeId,
      // );


      await FirebaseDbHelper.firebaseDbHelper.updateSystem(
        system: SystemModal(
          id: event.id,
          systemName: event.systemName,
          version: event.version ?? "",
          operatingSystem: event.operatingSystem ?? "",
          status: event.status ?? "available",
          adminId: event.adminId,
          managerId: event.managerId,
          employeeId: event.employeeId,
        ),
      );

      add(FetchSystem(adminId: event.adminId, employeeId: event.employeeId));
    } catch (e) {
      print("Error updating system: $e");
    }
  }


  Future<void> _deleteSystemData(DeleteSystem event, Emitter<SystemState> emit) async {
    try {
      // Commented out local DB delete:
      // await DbHelper.dbHelper.deleteSystem(event.id);

      await FirebaseDbHelper.firebaseDbHelper.deleteSystem("${event.id}");

    add(FetchSystem(adminId: event.adminId, employeeId: event.employeeId));
    } catch (e) {
    print("Error deleting system: $e");
    }
  }
}