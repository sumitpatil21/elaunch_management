import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:elaunch_management/Service/admin_modal.dart';
import 'package:elaunch_management/Service/db_helper.dart';
import 'package:elaunch_management/Service/firebaseDatabase.dart';
import 'package:equatable/equatable.dart';

part 'admin_event.dart';
part 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  AdminBloc(super.initialState) {
    on<AdminInsert>(insertIntoAdmin);
    on<AdminFetch>(fetchAdmin);
    on<AdminLogin>(loginAdmin);
    on<AdminLogout>(logoutAdmin);
  }

  loginAdmin(AdminLogin event, Emitter<AdminState> emit) async {
   await DbHelper.dbHelper.updateAdmin(email: event.email, check: event.check);
   add(AdminFetch());
  }

  logoutAdmin(AdminLogout event, Emitter<AdminState> emit) {
    emit(state.copyWith(adminList: []));
  }

  insertIntoAdmin(AdminInsert event, Emitter<AdminState> emit) async {
    try {
      await DbHelper.dbHelper.insertIntoAdmin(
        name: event.name,
        email: event.email,
        pass: event.pass,
        check: event.check,
        companyName: event.companyName,
        field: event.field,
      );
      add(AdminFetch());
    } catch (e) {
      log("Error in insertIntoAdmin: $e");
    }
  }

  fetchAdmin(AdminFetch event, Emitter<AdminState> emit) async {
    List<AdminModal> adminList = await DbHelper.dbHelper.adminFetch();
    adminList.map((e) => FirebaseDbHelper.firebaseDbHelper.insertAdmin(e),);
    List<AdminModal> data = adminList.where((element) => element.check == "isLogin").toList();
    emit(state.copyWith(adminList: data));
  }
}
