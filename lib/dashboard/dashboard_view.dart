import 'package:elaunch_management/SuperAdminLogin/admin_bloc.dart';
import 'package:elaunch_management/SuperAdminLogin/admin_event.dart';
import 'package:elaunch_management/System/system_bloc.dart';
import 'package:elaunch_management/service/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Department/department_bloc.dart';
import '../Device_Testing/device_bloc.dart';
import '../Device_Testing/device_event.dart';
import '../Employee/employee_bloc.dart';
import '../Employee/employee_event.dart';
import '../Employee/employee_state.dart';
import '../Leave/leave_bloc.dart';
import '../Leave/leave_event.dart';
import '../SuperAdminLogin/admin_state.dart';

import '../System/system_event.dart';

import '../employee_chat/chat_bloc.dart';

import 'dashboard_widget.dart';

class DashboardView extends StatefulWidget {
  static String routeName = "/Dashboard";

  const DashboardView({super.key});

  static Widget builder(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AdminBloc()),
        BlocProvider(
          create: (context) => DepartmentBloc()..add(FetchDepartments()),
        ),
        BlocProvider(create: (context) => SystemBloc()..add(FetchSystem())),
        BlocProvider(create: (context) => DeviceBloc()..add(FetchDevice())),
        BlocProvider(
          create: (context) => EmployeeBloc()..add(FetchEmployees()),
        ),
        BlocProvider(create: (context) => LeaveBloc()..add(FetchLeaves())),
        BlocProvider(create: (context) => ChatBloc(firebaseDbHelper: FirebaseDbHelper.firebase)),
      ],
      child: const DashboardView(),
    );
  }

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    context.read<EmployeeBloc>().add(FetchEmployees());
    context.read<DepartmentBloc>().add(FetchDepartments());
    context.read<SystemBloc>().add(FetchSystem());
    context.read<DeviceBloc>().add(FetchDevice());
    context.read<LeaveBloc>().add(FetchLeaves());
    context.read<AdminBloc>().add(AdminFetch());
  }

  void _refreshData() {
    context.read<AdminBloc>().add(AdminFetch());
    context.read<EmployeeBloc>().add(FetchEmployees());
    context.read<DepartmentBloc>().add(FetchDepartments());
    context.read<SystemBloc>().add(FetchSystem());
    context.read<DeviceBloc>().add(FetchDevice());
    context.read<LeaveBloc>().add(FetchLeaves());
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    SelectRole user = ModalRoute.of(context)!.settings.arguments as SelectRole;

    return BlocBuilder<EmployeeBloc, EmployeeState>(
      builder: (context, state) {
        return BlocBuilder<AdminBloc, AdminState>(
          builder: (context, adminState) {
            return Scaffold(
              appBar: buildAppBar(context, user),
              drawer: isMobile ? DashboardWidgets.drawer(context, user) : null,
              body: Row(
                children: [
                  if (!isMobile)
                    SizedBox(
                      width: 240,
                      child: DashboardWidgets.drawer(context, user),
                    ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            DashboardWidgets.welcomeSection(
                              context,
                              user,
                              isMobile,
                            ),
                            DashboardWidgets.managementSection(
                              context,
                              user,
                              isMobile,
                            ),
                            const SizedBox(height: 24),
                            DashboardWidgets.overviewSection(
                              context,
                              user,
                              isMobile,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  AppBar buildAppBar(BuildContext context, SelectRole user) {
    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      title: const Text(
        "Dashboard",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
          onPressed: _refreshData,
          icon: const Icon(Icons.refresh, color: Colors.white),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12, left: 10, right: 13),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white,
            child: Text(
              userInitial(user),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String userInitial(SelectRole user) {
    if (user.employeeModal != null) {
      return user.employeeModal!.name.isNotEmpty
          ? user.employeeModal!.name[0].toUpperCase()
          : 'E';
    } else if (user.adminModal != null) {
      return user.adminModal!.name.isNotEmpty
          ? user.adminModal!.name[0].toUpperCase()
          : 'A';
    }
    return 'U';
  }
}
