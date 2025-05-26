import 'package:bloc/bloc.dart';
import 'package:elaunch_management/Service/employee_modal.dart';
import 'package:equatable/equatable.dart';

import '../Department/department_bloc.dart';
import '../Service/db_helper.dart';
import '../Service/department_modal.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc(super.initialState) {
    on<FetchEmployee>(fetchEmployeeData);
    on<FetchDepartment>(fetchDepartmentData);
  }

  Future<void> fetchEmployeeData(
    FetchEmployee event,
    Emitter<DashboardState> emit,
  ) async {
    // final employees = await DbHelper.dbHelper.employeeFetch();
    // emit(DashboardState(employee: employees, department: state.department));
    // }
  }
    Future<void> fetchDepartmentData(FetchDepartment event,
        Emitter<DashboardState> emit,) async {
      // final departments = await DbHelper.dbHelper.departmentFetch(event.adminId);
      // emit(DashboardState(employee: state.employee, department: departments));
      }
    }

