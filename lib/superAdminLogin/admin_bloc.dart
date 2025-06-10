import 'package:elaunch_management/Service/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer';
import '../Service/admin_modal.dart';
import '../Service/firebase_auth.dart';
import 'admin_event.dart';
import 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  AdminBloc() : super(const AdminState()) {
    on<AdminFetch>(adminFetch);
    on<AdminLogin>(adminLogin);
    on<AdminRegister>(adminRegister);
    on<AdminForgotPassword>(adminForgotPassword);
    on<AdminLogout>(adminLogout);
    on<AdminLoginCheck>(adminLoginCheck);
    on<SelectRole>(selectRole);
  }

  Future<void> adminFetch(AdminFetch event, Emitter<AdminState> emit) async {
    var currentUser = AuthServices.authServices.getCurrentUser();
    AdminModal? adminModal;
    if (currentUser != null) {
      adminModal = AdminModal(
        id: currentUser.uid,
        name: currentUser.displayName ?? '',
        email: currentUser.email ?? '',
        companyName: '',
        field: '',
        phone: '',
      );
      emit(state.copyWith(adminModal: adminModal));
    }
  }

  Future<void> adminLogin(AdminLogin event, Emitter<AdminState> emit) async {
    log('Admin login with email: ${event.email}');
    await AuthServices.authServices.signInWithEmailAndPassword(
      email: event.email,
      password: event.password,
    );
    add(AdminFetch());
  }

  Future<void> adminRegister(
    AdminRegister event,
    Emitter<AdminState> emit,
  ) async {
    log('Admin registration with email: ${event.email}');
    AuthServices.authServices.createAccountWithEmailAndPassword(
      email: event.email,
      password: event.password,
    );
    final adminModal = AdminModal(
      name: event.name,
      email: event.email,
      companyName: event.companyName,
      field: event.field,
      phone: event.phone,
      id: '',
    );
    FirebaseDbHelper.firebase.createAdmin(adminModal);
    add(AdminFetch());
  }

  Future<void> adminForgotPassword(
    AdminForgotPassword event,
    Emitter<AdminState> emit,
  ) async {
    AuthServices.authServices.forgotPassword(event.email);
    log('Forgot password email sent to ${event.email}');
    add(AdminFetch());
  }

  Future<void> adminLogout(AdminLogout event, Emitter<AdminState> emit) async {
    await AuthServices.authServices.signOut();
    emit(const AdminState());
  }

  Future<void> adminLoginCheck(
    AdminLoginCheck event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(isLogin: event.isLogin));
  }

  Future<void> selectRole(SelectRole event, Emitter<AdminState> emit) async {
    emit(
      state.copyWith(
        selectedRole: event.selectedRole,
        adminModal: event.adminModal,
        employeeModal: event.employeeModal,
      ),
    );
  }
}
