import 'dart:developer';

import 'package:elaunch_management/Dashboard/dashboard_bloc.dart';
import 'package:elaunch_management/Department/department_view.dart';
import 'package:elaunch_management/Device_Testing/device_bloc.dart';
import 'package:elaunch_management/Device_Testing/device_view.dart';
import 'package:elaunch_management/Employee/employee_view.dart';
import 'package:elaunch_management/Manager/manager_view.dart';
import 'package:elaunch_management/SuperAdminLogin/admin_bloc.dart';
import 'package:elaunch_management/System/system_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Department/department_bloc.dart';
import '../Device_Testing/device_event.dart';
import '../Employee/employee_bloc.dart';

import '../Manager/manager_bloc.dart';
import '../Service/admin_modal.dart';
import '../SuperAdminLogin/admin_view.dart';
import '../System/system_view.dart';

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
        BlocProvider(
          create:
              (context) =>
                  SystemBloc(SystemState())
                    ..add(FetchSystem(adminId: admin.id)),
        ),
        BlocProvider(
          create: (context) => DeviceBloc(DeviceState())..add(FetchDevice()),
        ),
        BlocProvider(
          create:
              (context) =>
                  EmployeeBloc(EmployeeState())
                    ..add(FetchEmployees(adminId: admin.id)),
        ),
        BlocProvider(
          create:
              (context) =>
                  ManagerBloc(ManagerState())
                    ..add(FetchManagers(adminId: admin.id ?? 1)),
        ),
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
          IconButton(
            onPressed: () {
              context.read<AdminBloc>().add(AdminFetch());
              context.read<EmployeeBloc>().add(
                FetchEmployees(adminId: admin.id),
              );
              context.read<ManagerBloc>().add(
                FetchManagers(adminId: admin.id ?? 1),
              );
              context.read<DashboardBloc>().add(FetchDepartment(admin.id ?? 1));
              context.read<DashboardBloc>().add(FetchEmployee());
            },
            icon: Icon(Icons.refresh),
          ),
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
                Navigator.pushNamed(
                  context,
                  ManagerScreen.routeName,
                  arguments: ManagerScreenArguments(
                    adminId: admin.id ?? 1,
                    departmentId: 0,
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.group),
              title: Text("Employee"),
              onTap: () {
                final dept = context.read<DashboardBloc>().state.department;
                Navigator.pushNamed(
                  context,
                  EmployeeScreen.routeName,
                  arguments: ManagerScreenArguments(
                    adminId: admin.id ?? 1,
                    departmentId: 0,
                    departmentList: dept,
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.phone_android_outlined),
              title: Text("Device"),
              onTap: () {
                log("${admin.id}");
                Navigator.pushNamed(
                  context,
                  DeviceView.routeName,
                  arguments: admin,
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.computer_outlined),
              title: Text("System"),
              onTap: () {
                log("${admin.id}");
                Navigator.pushNamed(
                  context,
                  SystemView.routeName,
                  arguments: admin,
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
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
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
                      "Welcome, ${admin.name} 👋",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color:
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                  ),
                ),
              ),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                childAspectRatio: 3.5 / 4.7,
                crossAxisSpacing: 1,
                mainAxisSpacing: 1,

                children: [
                  GestureDetector(
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
                            Icon(Icons.business, size: 32, color: Colors.white),
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
                                      valueColor: AlwaysStoppedAnimation<Color>(
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

                  // Manager Card
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
                                      valueColor: AlwaysStoppedAnimation<Color>(
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

                  // Employee Card
                  GestureDetector(
                    onTap: () {
                      final dept =
                          context.read<DashboardBloc>().state.department;
                      Navigator.pushNamed(
                        context,
                        EmployeeScreen.routeName,
                        arguments: ManagerScreenArguments(
                          adminId: admin.id ?? 1,
                          departmentId: 0,
                          departmentList: dept,
                        ),
                      );
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
                                      valueColor: AlwaysStoppedAnimation<Color>(
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
                  // system Card
                  GestureDetector(
                    onTap: () {
                      log("${admin.id}");
                      Navigator.pushNamed(
                        context,
                        SystemView.routeName,
                        arguments: admin,
                      );
                    },
                    child: Card(
                      elevation: 4,
                      color: Colors.yellow,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.computer_outlined,
                              size: 32,
                              color: Colors.white,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'System',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            BlocBuilder<SystemBloc, SystemState>(
                              builder: (context, state) {
                                if (state.systems.isEmpty) {
                                  return SizedBox(
                                    height: 15,
                                    width: 15,
                                    child: Text("0"),
                                  );
                                } else {
                                  return Text(
                                    '${state.systems.length}',
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
                  //Device Card
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, DeviceView.routeName);
                    },
                    child: Card(
                      elevation: 4,
                      color: Colors.purple,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.phone_android_outlined,
                              size: 32,
                              color: Colors.white,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Device',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            BlocBuilder<DeviceBloc, DeviceState>(
                              builder: (context, state) {
                                if (state.devices.isEmpty) {
                                  return SizedBox(
                                    height: 15,
                                    width: 15,
                                    child: Text("0"),
                                  );
                                } else {
                                  return Text(
                                    '${state.devices.length}',
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
                ],
              ),

              SizedBox(height: 16),

              // Overview Section
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  "Overview",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                  ),
                ),
              ),

              // Overview Cards
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .7,
                      height: MediaQuery.of(context).size.height * 0.32,
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
                              child: BlocBuilder<DashboardBloc, DashboardState>(
                                builder: (context, state) {
                                  if (state.department.isEmpty) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else if (state.department.isNotEmpty) {
                                    return ListView.builder(
                                      padding: EdgeInsets.zero,
                                      itemCount: state.department.length,
                                      itemBuilder: (context, index) {
                                        return ListTile(
                                          trailing: GestureDetector(
                                            onTap: () {
                                              Navigator.pushNamed(
                                                context,
                                                ManagerScreen.routeName,
                                                arguments:
                                                    ManagerScreenArguments(
                                                      adminId:
                                                          state
                                                              .department[index]
                                                              .id_admin,
                                                      departmentId:
                                                          state
                                                              .department[index]
                                                              .id,
                                                      department:
                                                          state
                                                              .department[index],
                                                      departmentList:
                                                          state.department,
                                                    ),
                                              );
                                            },
                                            child: Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              size: 17,
                                            ),
                                          ),
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
                    SizedBox(width: 10),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .7,
                      height: MediaQuery.of(context).size.height * 0.32,
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
                                          trailing: GestureDetector(
                                            onTap: () {
                                              Navigator.pushNamed(
                                                context,
                                                EmployeeScreen.routeName,
                                                arguments:
                                                    ManagerScreenArguments(
                                                      departmentList:
                                                          context
                                                              .read<
                                                                DashboardBloc
                                                              >()
                                                              .state
                                                              .department,
                                                      manager:
                                                          state.managers[index],
                                                    ),
                                              );
                                            },
                                            child: Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              size: 17,
                                            ),
                                          ),
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
                    SizedBox(width: 10),

                    // Employee Overview Card
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .7,
                      height: MediaQuery.of(context).size.height * 0.32,
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
                                          trailing: GestureDetector(
                                            onTap: () {
                                              final dept =
                                                  context
                                                      .read<DashboardBloc>()
                                                      .state
                                                      .department;
                                              Navigator.pushNamed(
                                                context,
                                                EmployeeScreen.routeName,
                                                arguments:
                                                    ManagerScreenArguments(
                                                      adminId: admin.id ?? 1,
                                                      departmentId: 0,
                                                      departmentList: dept,
                                                    ),
                                              );
                                            },
                                            child: Icon(
                                              Icons.arrow_forward_ios_outlined,
                                              size: 17,
                                            ),
                                          ),
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

                    SizedBox(width: 10),

                    // system Overview Card
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .7,
                      height: MediaQuery.of(context).size.height * 0.32,
                      child: Card(
                        elevation: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              color: Colors.yellow,
                              width: double.infinity,
                              child: Text(
                                'System Overview',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              child: BlocBuilder<SystemBloc, SystemState>(
                                builder: (context, state) {
                                  if (state.systems.isEmpty) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else if (state.systems.isNotEmpty) {
                                    return ListView.builder(
                                      padding: EdgeInsets.zero,
                                      itemCount: state.systems.length,
                                      itemBuilder: (context, index) {
                                        return ListTile(
                                          trailing: GestureDetector(
                                            onTap: () {
                                              final dept =
                                                  context
                                                      .read<DashboardBloc>()
                                                      .state
                                                      .department;
                                              Navigator.pushNamed(
                                                context,
                                                EmployeeScreen.routeName,
                                                arguments:
                                                    ManagerScreenArguments(
                                                      adminId: admin.id ?? 1,
                                                      departmentId: 0,
                                                      departmentList: dept,
                                                    ),
                                              );
                                            },
                                            child: Icon(
                                              Icons.arrow_forward_ios_outlined,
                                              size: 17,
                                            ),
                                          ),
                                          leading: CircleAvatar(
                                            backgroundColor: Colors.yellow
                                                .withOpacity(0.2),
                                            child: Icon(
                                              Icons.computer_outlined,
                                            ),
                                          ),
                                          title: Text(
                                            state.systems[index].systemName,
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
                    SizedBox(width: 10),

                    // system Overview Card
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .7,
                      height: MediaQuery.of(context).size.height * 0.32,
                      child: Card(
                        elevation: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              color: Colors.purple,
                              width: double.infinity,
                              child: Text(
                                'Device Overview',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              child: BlocBuilder<DeviceBloc, DeviceState>(
                                builder: (context, state) {
                                  if (state.devices.isEmpty) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else if (state.devices.isNotEmpty) {
                                    return ListView.builder(
                                      padding: EdgeInsets.zero,
                                      itemCount: state.devices.length,
                                      itemBuilder: (context, index) {
                                        return ListTile(
                                          trailing: GestureDetector(
                                            onTap: () {
                                              final dept =
                                                  context
                                                      .read<DashboardBloc>()
                                                      .state
                                                      .department;
                                              Navigator.pushNamed(
                                                context,
                                                EmployeeScreen.routeName,
                                                arguments:
                                                    ManagerScreenArguments(
                                                      adminId: admin.id ?? 1,
                                                      departmentId: 0,
                                                      departmentList: dept,
                                                    ),
                                              );
                                            },
                                            child: Icon(
                                              Icons.arrow_forward_ios_outlined,
                                              size: 17,
                                            ),
                                          ),
                                          leading: CircleAvatar(
                                            backgroundColor: Colors.purple
                                                .withOpacity(0.2),
                                            child: Icon(
                                              Icons.phone_android_outlined,
                                            ),
                                          ),
                                          title: Text(
                                            state.devices[index].deviceName,
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
