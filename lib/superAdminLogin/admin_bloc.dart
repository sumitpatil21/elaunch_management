import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer';
import '../Service/admin_modal.dart';
import '../Service/firebase_auth.dart';
import 'admin_event.dart';
import 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final FirebaseAuthHelper _authHelper = FirebaseAuthHelper();

  AdminBloc() : super(const AdminState()) {
    on<AdminFetch>(_onAdminFetch);
    on<AdminLogin>(_onAdminLogin);
    on<AdminLogout>(_onAdminLogout);
    on<AdminLoginCheck>(_onAdminLoginCheck);
    on<SelectRole>(_onSelectRole);
  }

  Future<void> _onAdminFetch(AdminFetch event, Emitter<AdminState> emit) async {
    try {
      final currentUser = _authHelper.getCurrentUser();
      if (currentUser != null) {
        // Create AdminModal from current user
        final admin = AdminModal(
          id: currentUser.uid,
          email: currentUser.email ?? '',
          name: currentUser.displayName ?? 'Admin', companyName: '', field: '',
          // Add other required fields
        );
        emit(state.copyWith(adminModal: admin, isLogin: true));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onAdminLogin(AdminLogin event, Emitter<AdminState> emit) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));

      final result = await _authHelper.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      if (result == 'Success') {
        final currentUser = _authHelper.getCurrentUser();
        if (currentUser != null) {
          final admin = AdminModal(
            id: currentUser.uid,
            email: currentUser.email ?? '',
            name: currentUser.displayName ?? 'Admin', companyName: '', field: '',
            // Add other required fields
          );

          emit(state.copyWith(
            isLogin: true,
            adminModal: admin,
            selectedRole: "Admin",
            isLoading: false,
          ));
        }
      } else {
        emit(state.copyWith(
          errorMessage: result,
          isLoading: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> _onAdminLogout(AdminLogout event, Emitter<AdminState> emit) async {
    try {
      await _authHelper.signOut();
      emit(const AdminState()); // Reset to initial state
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  void _onAdminLoginCheck(AdminLoginCheck event, Emitter<AdminState> emit) {
    emit(state.copyWith(isLogin: event.isLogin));
  }

  void _onSelectRole(SelectRole event, Emitter<AdminState> emit) {
    emit(state.copyWith(
      selectedRole: event.selectedRole,
      adminModal: event.adminModal,
      employeeModal: event.employeeModal,
    ));
  }
}
