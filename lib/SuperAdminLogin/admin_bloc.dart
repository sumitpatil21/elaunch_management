import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:elaunch_management/Service/admin_modal.dart';
import 'package:elaunch_management/Service/firebaseDatabase.dart';
import 'package:equatable/equatable.dart';

import '../Service/employee_modal.dart';

part 'admin_event.dart';
part 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  AdminBloc() : super(const AdminState()) {
    on<AdminInsert>(insertIntoAdmin);
    on<AdminFetch>(fetchAdmin);
    on<AdminLogin>(loginAdmin);
    on<AdminLogout>(logoutAdmin);
    on<AdminLoginCheck>(adminLoginCheck);
    on<SelectRole>(selectRole);
  }

  Future<void> loginAdmin(AdminLogin event, Emitter<AdminState> emit) async {
    emit(state.copyWith(isLoading: true));

    final admins = await FirebaseDbHelper.firebase.getAdminByEmail(event.email);

    if (admins.isEmpty || admins.first.pass != event.password) {
      emit(state.copyWith(adminList: [], isLoading: false));
      return;
    }

    await FirebaseDbHelper.firebase.updateAdminStatus(
      admins.first.email,
      "isLogin",
    );

    emit(
      state.copyWith(
        adminList: admins,
        isLogin: true,
        adminModal: admins.first,
        selectedRole: "Admin",
        isLoading: false,
      ),
    );
  }

  Future<void> logoutAdmin(AdminLogout event, Emitter<AdminState> emit) async {
    if (event.email != null) {
      await FirebaseDbHelper.firebase.updateAdminStatus(
        event.email!,
        "isLogout",
      );
    }
    emit(
      state.copyWith(
        adminList: [],
        isLogin: false,
        adminModal: null,
        employeeModal: null,
        selectedRole: null,
      ),
    );
  }

  Future<void> insertIntoAdmin(
    AdminInsert event,
    Emitter<AdminState> emit,
  ) async {
    await FirebaseDbHelper.firebase.createAdmin(
      AdminModal(
        id: event.id,
        name: event.name,
        email: event.email,
        pass: event.pass,
        check: "isLogout",
        companyName: event.companyName,
        field: event.field,
      ),
    );

    emit(
      state.copyWith(
        adminList: [
          AdminModal(
            id: event.id,
            name: event.name,
            email: event.email,
            pass: event.pass,
            check: "isLogout",
            companyName: event.companyName,
            field: event.field,
          ),
        ],
      ),
    );
  }

  Future<void> fetchAdmin(AdminFetch event, Emitter<AdminState> emit) async {
    final allAdmins = await FirebaseDbHelper.firebase.getAllAdmins();
    emit(state.copyWith(adminList: allAdmins));
  }

  adminLoginCheck(AdminLoginCheck event, Emitter<AdminState> emit) {
    emit(state.copyWith(isLogin: event.isLogin));
  }

  selectRole(SelectRole event, Emitter<AdminState> emit) {
    emit(
      state.copyWith(
        selectedRole: event.selectedRole,
        adminModal: event.adminModal,
        employeeModal: event.employeeModal,
      ),
    );
  }
}
