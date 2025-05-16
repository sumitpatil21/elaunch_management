import 'dart:developer';

import 'package:elaunch_management/Dashboard/dashboard_bloc.dart';
import 'package:elaunch_management/Dashboard/splaceScreen.dart';
import 'package:elaunch_management/Department/department_view.dart';
import 'package:elaunch_management/Employee/employee_view.dart';
import 'package:elaunch_management/Manager/manager_view.dart';
import 'package:elaunch_management/SuperAdminLogin/admin_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Department/department_bloc.dart';
import '../Employee/employee_bloc.dart';
import '../Manager/manager_bloc.dart';
import '../Service/admin_modal.dart';
import '../SuperAdminLogin/admin_view.dart';

class DashboardView extends StatefulWidget {
  static String routeName = "/dash";

  const DashboardView({super.key});

  static Widget builder(BuildContext context) {
    late AdminModal admin =
        ModalRoute.of(context)!.settings.arguments as AdminModal;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) =>
                  DashboardBloc(DashboardState())
                    ..add(FetchDepartment(admin.id ?? 1)),
        ),
        BlocProvider(create: (context) => AdminBloc(AdminState())),
        BlocProvider(create: (context) => DepartmentBloc(DepartmentState())),
        BlocProvider(create: (context) => EmployeeBloc(EmployeeState())),
        BlocProvider(create: (context) => ManagerBloc(ManagerState())),
      ],
      child: DashboardView(),
    );
  }

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    context.read<AdminBloc>().add(AdminFetch());
    context.read<ManagerBloc>().add(FetchManagers());
    context.read<EmployeeBloc>().add(FetchEmployees());
    context.read<DashboardBloc>().add(FetchEmployee());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    late AdminModal admin =
        ModalRoute.of(context)!.settings.arguments as AdminModal;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          "Dashboard",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 12, left: 10, right: 13),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: Text(
                admin.name[0],
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        width: 240,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: BlocBuilder<AdminBloc, AdminState>(
                  builder: (context, state) {
                    if (state.adminList.isNotEmpty) {
                      return Text(
                        state.adminList.first.name.toString()[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      );
                    } else {
                      return Icon(
                        Icons.person,
                        color: Theme.of(context).primaryColor,
                      );
                    }
                  },
                ),
              ),
              accountName: BlocBuilder<AdminBloc, AdminState>(
                builder: (context, state) {
                  if (state.adminList.isNotEmpty) {
                    return Text(
                      state.adminList.first.name.toString(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    );
                  } else {
                    return Text("No user logged in");
                  }
                },
              ),
              accountEmail: BlocBuilder<AdminBloc, AdminState>(
                builder: (context, state) {
                  if (state.adminList.isNotEmpty) {
                    return Text(state.adminList.first.email.toString());
                  } else {
                    return Text("");
                  }
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text("Dashboard"),
              selected: true,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.business),
              title: Text("Department"),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  DepartmentScreen.routeName,
                  arguments: context.read<AdminBloc>().state.adminList.first,
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Manager"),
              onTap: () {
                Navigator.pushNamed(context, ManagerScreen.routeName);
              },
            ),
            ListTile(
              leading: Icon(Icons.group),
              title: Text("Employee"),
              onTap: () {
                Navigator.pushReplacementNamed(
                  context,
                  EmployeeScreen.routeName,
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () {
                context.read<AdminBloc>().add(
                  AdminLogin(
                    email:
                        context.read<AdminBloc>().state.adminList.first.email,
                    check: "Logout",
                  ),
                );
                context.read<AdminBloc>().add(AdminLogout());
                Navigator.of(context).pushNamed(AdminView.routeName);
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome, ${admin.name}",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Management Section
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                "Management",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              height: 130,
              child: Row(
                children: [
                  // Department Card
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          DepartmentScreen.routeName,
                          arguments:
                              context.read<AdminBloc>().state.adminList.first,
                        );
                      },
                      child: Card(
                        elevation: 4,
                        color: Colors.blue,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.business,
                                size: 32,
                                color: Colors.white,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Departments',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              BlocBuilder<DashboardBloc, DashboardState>(
                                builder: (context, state) {
                                  if (state.department.isEmpty) {
                                    return SizedBox(
                                      height: 15,
                                      width: 15,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    );
                                  } else {
                                    return Text(
                                      '${state.department.length}',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Manager Card
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          ManagerScreen.routeName,
                          arguments: ManagerScreenArguments(
                            adminId: admin.id ?? 1,
                            departmentId: 0,
                          ),
                        );
                      },
                      child: Card(
                        elevation: 4,
                        color: Colors.green,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person, size: 32, color: Colors.white),
                              SizedBox(height: 8),
                              Text(
                                'Managers',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              BlocBuilder<ManagerBloc, ManagerState>(
                                builder: (context, state) {
                                  if (state.managers.isEmpty) {
                                    return SizedBox(
                                      height: 15,
                                      width: 15,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    );
                                  } else {
                                    return Text(
                                      '${state.managers.length}',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Employee Card
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, EmployeeScreen.routeName);
                      },
                      child: Card(
                        elevation: 4,
                        color: Colors.red,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.group, size: 32, color: Colors.white),
                              SizedBox(height: 8),
                              Text(
                                'Employees',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              BlocBuilder<EmployeeBloc, EmployeeState>(
                                builder: (context, state) {
                                  if (state.employees.isEmpty) {
                                    return SizedBox(
                                      height: 15,
                                      width: 15,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    );
                                  } else {
                                    return Text(
                                      '${state.employees.length}',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Overview Section
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                "Overview",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            // Overview Cards
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Department Overview Card
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          DepartmentScreen.routeName,
                          arguments:
                              context.read<AdminBloc>().state.adminList.first,
                        );
                      },
                      child: Container(
                        width: 250,
                        height: 350,
                        child: Card(
                          elevation: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                color: Colors.blue,
                                width: double.infinity,
                                child: Text(
                                  'Department Overview',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                child:
                                    BlocBuilder<DashboardBloc, DashboardState>(
                                      builder: (context, state) {
                                        if (state.department.isEmpty) {
                                          return Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        } else if (state
                                            .department
                                            .isNotEmpty) {
                                          return ListView.builder(
                                            padding: EdgeInsets.zero,
                                            itemCount: state.department.length,
                                            itemBuilder: (context, index) {
                                              return ListTile(
                                                leading: CircleAvatar(
                                                  backgroundColor: Colors.blue
                                                      .withOpacity(0.2),
                                                  child: Icon(
                                                    Icons.business,
                                                    size: 16,
                                                  ),
                                                ),
                                                title: Text(
                                                  state.department[index].name,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                subtitle: Text('Department'),
                                              );
                                            },
                                          );
                                        } else {
                                          return Center(
                                            child: Text('No departments found'),
                                          );
                                        }
                                      },
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          ManagerScreen.routeName,
                          arguments: ManagerScreenArguments(
                            adminId: admin.id ?? 1,
                            departmentId: 0,
                          ),
                        );
                      },
                      child: Container(
                        width: 250,
                        height: 350,
                        child: Card(
                          elevation: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                color: Colors.green,
                                width: double.infinity,
                                child: Text(
                                  'Manager Overview',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                child: BlocBuilder<ManagerBloc, ManagerState>(
                                  builder: (context, state) {
                                    if (state.managers.isEmpty) {
                                      return Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    } else if (state.managers.isNotEmpty) {
                                      return ListView.builder(
                                        padding: EdgeInsets.zero,
                                        itemCount: state.managers.length,
                                        itemBuilder: (context, index) {
                                          return ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: Colors.green
                                                  .withOpacity(0.2),
                                              child: Text(
                                                state
                                                    .managers[index]
                                                    .managerName[0]
                                                    .toUpperCase(),
                                              ),
                                            ),
                                            title: Text(
                                              state.managers[index].managerName,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            subtitle: Text('Manager'),
                                          );
                                        },
                                      );
                                    } else {
                                      return Center(
                                        child: Text('No managers found'),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),

                    // Employee Overview Card
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, EmployeeScreen.routeName);
                      },
                      child: Container(
                        width: 250,
                        height: 350,
                        child: Card(
                          elevation: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                color: Colors.red,
                                width: double.infinity,
                                child: Text(
                                  'Employee Overview',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                child: BlocBuilder<EmployeeBloc, EmployeeState>(
                                  builder: (context, state) {
                                    if (state.employees.isEmpty) {
                                      return Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    } else if (state.employees.isNotEmpty) {
                                      return ListView.builder(
                                        padding: EdgeInsets.zero,
                                        itemCount: state.employees.length,
                                        itemBuilder: (context, index) {
                                          return ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: Colors.red
                                                  .withOpacity(0.2),
                                              child: Text(
                                                state.employees[index].name[0]
                                                    .toUpperCase(),
                                              ),
                                            ),
                                            title: Text(
                                              state.employees[index].name,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            subtitle: Text('Employee'),
                                          );
                                        },
                                      );
                                    } else {
                                      return Center(
                                        child: Text('No employees found'),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
