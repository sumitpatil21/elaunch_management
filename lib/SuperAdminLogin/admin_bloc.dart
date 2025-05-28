import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:elaunch_management/Service/admin_modal.dart';
import 'package:elaunch_management/Service/firebaseDatabase.dart';
import 'package:equatable/equatable.dart';

part 'admin_event.dart';
part 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  AdminBloc(): super(const AdminState())  {
    on<AdminInsert>(insertIntoAdmin);
    on<AdminFetch>(fetchAdmin);
    on<AdminLogin>(loginAdmin);
    on<AdminLogout>(logoutAdmin);
  }

  Future<void> loginAdmin(AdminLogin event, Emitter<AdminState> emit) async {

      final admins = await FirebaseDbHelper.firebase.getAdminByEmail(event.email);

      if (admins.isEmpty || admins.first.pass != event.password) {
        emit(state.copyWith(adminList: []));
        return;
      }

      await FirebaseDbHelper.firebase.updateAdminStatus(
        admins.first.email,
         event.check == "isLogin" ? "isLogin" : "isLogout",
      );

      emit(state.copyWith(adminList: admins));

  }

  Future<void> logoutAdmin(AdminLogout event, Emitter<AdminState> emit) async {
    if (event.email != null) {
      await FirebaseDbHelper.firebase.updateAdminStatus(
        event.email!,
        "isLogout",
      );
    }
    emit(state.copyWith(adminList: []));
  }

  Future<void> insertIntoAdmin(AdminInsert event, Emitter<AdminState> emit) async {
    try {
      await FirebaseDbHelper.firebase.createAdmin(AdminModal(
        id: event.id,
        name: event.name,
        email: event.email,
        pass: event.pass,
        check: "isLogout",
        companyName: event.companyName,
        field: event.field,
      ));

      emit(state.copyWith(adminList: [AdminModal(
        id: event.id,
        name: event.name,
        email: event.email,
        pass: event.pass,
        check: "isLogout",
        companyName: event.companyName,
        field: event.field,
      )]));
    } catch (e) {
      log("Registration error: $e");
      emit(state.copyWith(adminList: []));
    }
  }

  Future<void> fetchAdmin(AdminFetch event, Emitter<AdminState> emit) async {
    try {
      final allAdmins = await FirebaseDbHelper.firebase.getAllAdmins();
      emit(state.copyWith(adminList: allAdmins));
    } catch (e) {
      log("Fetch error: $e");
      emit(state.copyWith(adminList: []));
    }
  }
}