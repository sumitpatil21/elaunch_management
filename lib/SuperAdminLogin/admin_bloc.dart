import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:elaunch_management/Service/admin_modal.dart';
// import 'package:elaunch_management/Service/db_helper.dart'; // Local DB commented
import 'package:elaunch_management/Service/firebaseDatabase.dart';
import 'package:equatable/equatable.dart';

part 'admin_event.dart';
part 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  // AdminBloc(super.initialState) {
  AdminBloc(): super(const AdminState())  {
    on<AdminInsert>(insertIntoAdmin);
    on<AdminFetch>(fetchAdmin);
    on<AdminLogin>(loginAdmin);
    on<AdminLogout>(logoutAdmin);
  }

  Future<void> loginAdmin(AdminLogin event, Emitter<AdminState> emit) async {
    // await DbHelper.dbHelper.updateAdmin(email: event.email, check: event.check); // Local DB
    await FirebaseDbHelper.firebaseDbHelper.updateAdmin(
      email: event.email,
      check: event.check,
    );
    add(AdminFetch());
  }

  Future<void> logoutAdmin(AdminLogout event, Emitter<AdminState> emit) async {
    if (event.email != null) {
      await FirebaseDbHelper.firebaseDbHelper.updateAdmin(
        email: event.email!,
        check: "isLogout",
      );
    }
    emit(state.copyWith(adminList: []));
  }

  Future<void> insertIntoAdmin(AdminInsert event, Emitter<AdminState> emit) async {
    try {
      // await DbHelper.dbHelper.insertIntoAdmin(
      //   name: event.name,
      //   email: event.email,
      //   pass: event.pass,
      //   check: event.check,
      //   companyName: event.companyName,
      //   field: event.field,
      // ); // Local DB

      final admin = AdminModal(
        id: event.id,
        name: event.name,
        email: event.email,
        pass: event.pass,
        check: event.check,
        companyName: event.companyName,
        field: event.field,
      );
      await FirebaseDbHelper.firebaseDbHelper.insertAdmin(admin);

      add(AdminFetch());
    } catch (e) {
      log("Error in insertIntoAdmin: $e");
    }
  }

  Future<void> fetchAdmin(AdminFetch event, Emitter<AdminState> emit) async {
    // List<AdminModal> adminList = await DbHelper.dbHelper.adminFetch(); // Local DB
    // adminList.map((e) => FirebaseDbHelper.firebaseDbHelper.insertAdmin(e)); // Initial migration
    final allAdmins = await FirebaseDbHelper.firebaseDbHelper.fetchAdmins();
    final data = allAdmins.where((element) => element.check == "isLogin").toList();
    log(data.toString());
    emit(state.copyWith(adminList: data));
  }
}