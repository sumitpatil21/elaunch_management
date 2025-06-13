


import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Service/admin_modal.dart';
import '../Service/firebase_auth.dart';
import '../Service/firebase_database.dart';
import '../SuperAdminLogin/admin_event.dart';
import '../SuperAdminLogin/admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  static const String loginKey = 'is_login';
  static const String roleKey = 'user_role';
  static const String idKey = 'user_id';

  AdminBloc() : super(const AdminState()) {
    on<AdminFetch>(adminFetch);
    on<AdminLogin>(adminLogin);
    on<AdminRegister>(adminRegister);
    on<AdminForgotPassword>(adminForgotPassword);
    on<AdminLogout>(adminLogout);
    on<AdminLoginCheck>(adminLoginCheck);

    on<ToggleObscurePassword>(toggleObscurePassword);
    on<ChangeRole>(changeRole);
    on<ChangeTabIndex>(changeTabIndex);
    loginGet();
  }

  Future<void> loginGet() async {
    final prefs = await SharedPreferences.getInstance();
    final isLogin = prefs.getBool(loginKey) ?? false;
    final userRole = prefs.getString(roleKey) ?? 'Admin';

    if (isLogin) {
      add(AdminLoginCheck(isLogin: true));
      add(ChangeRole(role: userRole));
      add(AdminFetch());
    }
  }

  Future<void> saveLogin(
    bool isLogin,
    String role,
    String? userId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(loginKey, isLogin);
    await prefs.setString(roleKey, role);
    if (userId != null) {
      await prefs.setString(idKey, userId);
    }
  }

  Future<void> clearLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(loginKey);
    await prefs.remove(roleKey);
    await prefs.remove(idKey);
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
      emit(state.copyWith(adminModal: adminModal, isLogin: true ));
    }
  }

  Future<void> adminLogin(AdminLogin event, Emitter<AdminState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    log('Admin login with email: ${event.email}');
    await AuthServices.authServices.signInWithEmailAndPassword(
      email: event.email,
      password: event.password,
    );

    await saveLogin(true, state.selectedRole, null);

    emit(
      state.copyWith(
        isLoading: false,
        isLogin: true,
        successMessage: 'Login successful!',
      ),
    );

    add(AdminFetch());
  }

  Future<void> adminRegister(
    AdminRegister event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    log('Admin registration with email: ${event.email}');
    await AuthServices.authServices.createAccountWithEmailAndPassword(
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

    await FirebaseDbHelper.firebase.createAdmin(adminModal);

    emit(
      state.copyWith(
        isLoading: false,
        isRegistrationSuccess: true,
        successMessage: 'Registration successful! Please login.',
      ),
    );

    add(ChangeTabIndex(tabIndex: 0)); // Switch to login tab
  }

  Future<void> adminForgotPassword(
    AdminForgotPassword event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    await AuthServices.authServices.forgotPassword(event.email);
    log('Forgot password email sent to ${event.email}');

    emit(
      state.copyWith(
        isLoading: false,
        successMessage: 'Password reset email sent!',
      ),
    );
  }

  Future<void> adminLogout(AdminLogout event, Emitter<AdminState> emit) async {
    await AuthServices.authServices.signOut();
    await clearLogin();

    emit(const AdminState()); // Reset to initial state

    log('User logged out successfully');
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

      ),
    );
  }

  Future<void> toggleObscurePassword(
    ToggleObscurePassword event,
    Emitter<AdminState> emit,
  ) async {
    switch (event.passwordType) {
      case 'login':
        emit(state.copyWith(obscureLoginPassword: !state.obscureLoginPassword));
        break;
      case 'register':
        emit(
          state.copyWith(
            obscureRegisterPassword: !state.obscureRegisterPassword,
          ),
        );
        break;
    }
  }

  Future<void> changeRole(ChangeRole event, Emitter<AdminState> emit) async {
    emit(state.copyWith(selectedRole: event.role));
  }

  Future<void> changeTabIndex(
    ChangeTabIndex event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(currentTabIndex: event.tabIndex));
  }
}
