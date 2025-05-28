//
//
//
// import 'dart:developer';
//
// import 'package:bloc/bloc.dart';
// import 'package:equatable/equatable.dart';
// import '../Service/department_modal.dart';
// import '../Service/manger_modal.dart';
// import '../Service/firebaseDatabase.dart';
//
// part 'manager_event.dart';
// part 'manager_state.dart';
//
// class ManagerBloc extends Bloc<ManagerEvent, ManagerState> {
//   ManagerBloc() : super(const ManagerState()){
//     on<AddManager>(_insertManagerData);
//     on<FetchManagers>(fetchManagersData);
//     on<UpdateManager>(_updateManagerData);
//     on<DeleteManager>(_deleteManagerData);
//   }
//
//   Future<void> _insertManagerData(
//       AddManager event,
//       Emitter<ManagerState> emit,
//       ) async {
//     try {
//       final manager = MangerModal(
//         id: event.id,
//         managerName: event.name,
//         email: event.email,
//         address: event.address,
//         dob: event.dob,
//         departmentId: event.departmentId,
//         departmentName: event.departmentName,
//         adminId: event.adminId??1,
//       );
//       await FirebaseDbHelper.firebaseDbHelper.insertManager(manager);
//       add(FetchManagers(
//         departmentId: event.departmentId,
//         adminId: event.adminId ?? 1,
//       ));
//     } catch (e) {
//       log("Insert Manager Error: $e");
//     }
//   }
//
//
//   Future<void> fetchManagersData(
//       FetchManagers event,
//       Emitter<ManagerState> emit,
//       ) async {
//     try {
//       final managers = await FirebaseDbHelper.firebaseDbHelper.fetchManagers(
//         adminId: "${event.adminId}",
//         departmentId: "${event.departmentId}",
//       );
//       log("Fetch Managers: $managers");
//       emit(state.copyWith(managers: managers));
//     } catch (e) {
//       log("Fetch Managers Error: $e");
//     }
//   }
//
//
//   Future<void> _updateManagerData(
//       UpdateManager event,
//       Emitter<ManagerState> emit,
//       ) async {
//     try {
//       final manager = MangerModal(
//         id: event.id,
//         managerName: event.name,
//         email: event.email,
//         address: event.address,
//         dob: event.dob,
//         departmentId: event.departmentId,
//         adminId:event.adminId??1,
//       );
//       await FirebaseDbHelper.firebaseDbHelper.updateManager("${event.id}", manager);
//       add(FetchManagers(
//         departmentId: event.departmentId,
//         adminId: event.adminId ?? 1,
//       ));
//     } catch (e) {
//       log("Update Manager Error: $e");
//     }
//   }
//
//
//   Future<void> _deleteManagerData(
//       DeleteManager event,
//       Emitter<ManagerState> emit,
//       ) async {
//     try {
//       // await DbHelper.dbHelper.deleteManager(event.id);
//       await FirebaseDbHelper.firebaseDbHelper.deleteManager(event.id);
//       add(FetchManagers(
//         departmentId: event.departmentId,
//         adminId: event.adminId ?? 1,
//       ));
//     } catch (e) {
//       log("Delete Manager Error: $e");
//     }
//   }
// }