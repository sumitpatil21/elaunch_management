import 'package:elaunch_management/Department/department_view.dart';
import 'package:elaunch_management/Device_Testing/device_view.dart';
import 'package:elaunch_management/Employee/employee_view.dart';
import 'package:elaunch_management/SuperAdminLogin/admin_bloc.dart';
import 'package:elaunch_management/System/system_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Department/department_bloc.dart';
import '../Device_Testing/device_bloc.dart';
import '../Device_Testing/device_event.dart';
import '../Employee/employee_bloc.dart';
import '../Service/admin_modal.dart';
import '../SuperAdminLogin/admin_view.dart';
import '../System/system_view.dart';

class DashboardView extends StatefulWidget {
  static String routeName = "/dash";

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
    AdminModal? admin =
        ModalRoute.of(context)!.settings.arguments as AdminModal?;

    final bool isMobile = MediaQuery.of(context).size.width < 600;

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
              context.read<EmployeeBloc>().add(FetchEmployees());
              context.read<DepartmentBloc>().add(FetchDepartments());
              context.read<SystemBloc>().add(FetchSystem());
              context.read<DeviceBloc>().add(FetchDevice());
            },
            icon: Icon(Icons.refresh),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12, left: 10, right: 13),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: Text(
                context.read<EmployeeBloc>().state.loggedInEmployee != null
                    ? context
                            .read<EmployeeBloc>()
                            .state
                            .loggedInEmployee!
                            .name[0] ??
                        ''
                    : admin?.name[0] ?? '',
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
      drawer: isMobile ? buildDrawer(context, admin) : null,
      body: Row(
        children: [
          if (!isMobile)
            SizedBox(width: 240, child: buildDrawer(context, admin)),

          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome ${(context.read<EmployeeBloc>().state.loggedInEmployee != null) ? "Employee" : "Admin"},${(context.read<EmployeeBloc>().state.loggedInEmployee != null) ? context.read<EmployeeBloc>().state.loggedInEmployee!.name : admin?.name},",
                            style: TextStyle(
                              fontSize: isMobile ? 20 : 24,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.dark
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
                          fontSize: isMobile ? 18 : 20,
                          fontWeight: FontWeight.bold,
                          color:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                        ),
                      ),
                    ),

                    // Grid for management cards
                    GridView.count(
                      crossAxisCount: isMobile ? 2 : 3,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      childAspectRatio: isMobile ? 1 : 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        // Department Card
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              DepartmentScreen.routeName,
                              arguments:
                                  context
                                      .read<AdminBloc>()
                                      .state
                                      .adminList!
                                      .first,
                            );
                          },
                          child: Card(
                            elevation: 2,
                            color: Colors.blue,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
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
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  BlocBuilder<DepartmentBloc, DepartmentState>(
                                    builder: (context, state) {
                                      return Text(
                                        '${state.departments.length}',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      );
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
                                context
                                    .read<DepartmentBloc>()
                                    .state
                                    .departments;
                            Navigator.pushNamed(
                              context,
                              EmployeeScreen.routeName,
                              arguments: dept.first,
                            );
                          },
                          child: Card(
                            elevation: 4,
                            color: Colors.red,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.group,
                                    size: 32,
                                    color: Colors.white,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Employees',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  BlocBuilder<EmployeeBloc, EmployeeState>(
                                    builder: (context, state) {
                                      return Text(
                                        '${state.employees.length}',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // System Card
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, SystemView.routeName);
                          },
                          child: Card(
                            elevation: 4,
                            color: Colors.orange,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.computer_outlined,
                                    size: 32,
                                    color: Colors.white,
                                  ),
                                  SizedBox(height: 8),

                                  Text(
                                    'Systems',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  BlocBuilder<SystemBloc, SystemState>(
                                    builder: (context, state) {
                                      return Text(
                                        '${state.systems.length}',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Device Card
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, DeviceView.routeName);
                          },
                          child: Card(
                            elevation: 4,
                            color: Colors.purple,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.phone_android_outlined,
                                    size: 32,
                                    color: Colors.white,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Devices',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  BlocBuilder<DeviceBloc, DeviceState>(
                                    builder: (context, state) {
                                      return Text(
                                        '${state.devices.length}',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24),

                    // Overview Section
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        "Overview",
                        style: TextStyle(
                          fontSize: isMobile ? 18 : 20,
                          fontWeight: FontWeight.bold,
                          color:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                        ),
                      ),
                    ),

                    if (isMobile)
                      Column(
                        children: [
                          // Department Overview Card
                          Card(
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
                                BlocBuilder<DepartmentBloc, DepartmentState>(
                                  builder: (context, state) {
                                    if (state.departments.isEmpty) {
                                      return Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(16),
                                          child: Text("No Departments"),
                                        ),
                                      );
                                    }
                                    return Column(
                                      children:
                                          state.departments
                                              .take(3)
                                              .map(
                                                (dept) => ListTile(
                                                  trailing: GestureDetector(
                                                    onTap: () {
                                                      Navigator.pushNamed(
                                                        context,
                                                        DepartmentScreen
                                                            .routeName,
                                                      );
                                                    },
                                                    child: Icon(
                                                      Icons
                                                          .arrow_forward_ios_rounded,
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
                                                    dept.name,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  subtitle: Text('Department'),
                                                ),
                                              )
                                              .toList(),
                                    );
                                  },
                                ),
                                if (context
                                        .watch<DepartmentBloc>()
                                        .state
                                        .departments
                                        .length >
                                    3)
                                  Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Center(
                                      child: Text(
                                        '+ ${context.watch<DepartmentBloc>().state.departments.length - 3} more',
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          SizedBox(height: 16),

                          // Employee Overview Card
                          Card(
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
                                BlocBuilder<EmployeeBloc, EmployeeState>(
                                  builder: (context, state) {
                                    if (state.employees.isEmpty) {
                                      return Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(16),
                                          child: Text("No Employees"),
                                        ),
                                      );
                                    }
                                    return Column(
                                      children:
                                          state.employees
                                              .take(3)
                                              .map(
                                                (emp) => ListTile(
                                                  trailing: GestureDetector(
                                                    onTap: () {
                                                      final dept =
                                                          context
                                                              .read<
                                                                DepartmentBloc
                                                              >()
                                                              .state
                                                              .departments;
                                                      Navigator.pushNamed(
                                                        context,
                                                        EmployeeScreen
                                                            .routeName,
                                                        arguments: dept.first,
                                                      );
                                                    },
                                                    child: Icon(
                                                      Icons
                                                          .arrow_forward_ios_outlined,
                                                      size: 17,
                                                    ),
                                                  ),
                                                  leading: CircleAvatar(
                                                    backgroundColor: Colors.red
                                                        .withOpacity(0.2),
                                                    child: Text(
                                                      emp.name[0].toUpperCase(),
                                                    ),
                                                  ),
                                                  title: Text(
                                                    emp.name,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  subtitle: Text('Employee'),
                                                ),
                                              )
                                              .toList(),
                                    );
                                  },
                                ),
                                if (context
                                        .watch<EmployeeBloc>()
                                        .state
                                        .employees
                                        .length >
                                    3)
                                  Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Center(
                                      child: Text(
                                        '+ ${context.watch<EmployeeBloc>().state.employees.length - 3} more',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        childAspectRatio: 2.2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: [
                          // Department Overview Card
                          Card(
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
                                  child: BlocBuilder<
                                    DepartmentBloc,
                                    DepartmentState
                                  >(
                                    builder: (context, state) {
                                      if (state.departments.isEmpty) {
                                        return Center(
                                          child: Text("No Departments"),
                                        );
                                      }
                                      return ListView.builder(
                                        padding: EdgeInsets.zero,
                                        itemCount: state.departments.length,
                                        itemBuilder: (context, index) {
                                          return ListTile(
                                            trailing: GestureDetector(
                                              onTap: () {
                                                Navigator.pushNamed(
                                                  context,
                                                  DepartmentScreen.routeName,
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
                                              state.departments[index].name,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            subtitle: Text('Department'),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Employee Overview Card
                          Card(
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
                                  child: BlocBuilder<
                                    EmployeeBloc,
                                    EmployeeState
                                  >(
                                    builder: (context, state) {
                                      if (state.employees.isEmpty) {
                                        return Center(
                                          child: Text("No Employees"),
                                        );
                                      }
                                      return ListView.builder(
                                        padding: EdgeInsets.zero,
                                        itemCount: state.employees.length,
                                        itemBuilder: (context, index) {
                                          return ListTile(
                                            trailing: GestureDetector(
                                              onTap: () {
                                                final dept =
                                                    context
                                                        .read<DepartmentBloc>()
                                                        .state
                                                        .departments;
                                                Navigator.pushNamed(
                                                  context,
                                                  EmployeeScreen.routeName,
                                                  arguments: dept.first,
                                                );
                                              },
                                              child: Icon(
                                                Icons
                                                    .arrow_forward_ios_outlined,
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
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // System Overview Card
                          Card(
                            elevation: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  color: Colors.orange,
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
                                          child: Text("No Systems"),
                                        );
                                      }
                                      return ListView.builder(
                                        padding: EdgeInsets.zero,
                                        itemCount: state.systems.length,
                                        itemBuilder: (context, index) {
                                          return ListTile(
                                            trailing: GestureDetector(
                                              onTap: () {
                                                Navigator.pushNamed(
                                                  context,
                                                  SystemView.routeName,
                                                );
                                              },
                                              child: Icon(
                                                Icons
                                                    .arrow_forward_ios_outlined,
                                                size: 17,
                                              ),
                                            ),
                                            leading: CircleAvatar(
                                              backgroundColor: Colors.orange
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
                                            subtitle: Text('System'),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Device Overview Card
                          Card(
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
                                          child: Text("No Devices"),
                                        );
                                      }
                                      return ListView.builder(
                                        padding: EdgeInsets.zero,
                                        itemCount: state.devices.length,
                                        itemBuilder: (context, index) {
                                          return ListTile(
                                            trailing: GestureDetector(
                                              onTap: () {
                                                Navigator.pushNamed(
                                                  context,
                                                  DeviceView.routeName,
                                                );
                                              },
                                              child: Icon(
                                                Icons
                                                    .arrow_forward_ios_outlined,
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
                                            subtitle: Text('Device'),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Drawer buildDrawer(BuildContext context, AdminModal? admin) {
    return Drawer(
      width: 240,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                context.read<EmployeeBloc>().state.loggedInEmployee == null
                    ? admin?.name[0].toUpperCase() ?? 'A'
                    : context
                        .read<EmployeeBloc>()
                        .state
                        .loggedInEmployee!
                        .name[0]
                        .toUpperCase(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            accountName: Text(
              context.read<EmployeeBloc>().state.loggedInEmployee == null
                  ? admin?.name ?? 'Admin'
                  : context.read<EmployeeBloc>().state.loggedInEmployee!.name,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              context.read<EmployeeBloc>().state.loggedInEmployee == null
                  ? admin?.email ?? ''
                  : context.read<EmployeeBloc>().state.loggedInEmployee!.email,
            ),
          ),
          buildListTile(
            context,
            "Dashboard",
            () => Navigator.pop(context),
            Icon(Icons.dashboard),
          ),
          buildListTile(
            context,
            "Department",
            () => Navigator.pushNamed(context, DepartmentScreen.routeName),
            Icon(Icons.business),
          ),
          buildListTile(context, "Employee", () {
            final dept = context.read<DepartmentBloc>().state.departments;
            Navigator.pushNamed(
              context,
              EmployeeScreen.routeName,
              arguments: dept.first,
            );
          }, Icon(Icons.group)),
          buildListTile(context, "System", () {
            Navigator.pushNamed(context, SystemView.routeName);
          }, Icon(Icons.computer_outlined)),
          buildListTile(context, "Device", () {
            Navigator.pushNamed(context, DeviceView.routeName);
          }, Icon(Icons.phone_android_outlined)),
          Divider(),

          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () {
              context.read<AdminBloc>().add(
                AdminLogin(
                  email: context.read<AdminBloc>().state.adminList!.first.email,
                  password:
                      context.read<AdminBloc>().state.adminList!.first.pass,
                ),
              );
              context.read<AdminBloc>().add(AdminLogout());
              Navigator.of(context).pushNamed(AdminView.routeName);
            },
          ),
        ],
      ),
    );
  }

  ListTile buildListTile(
    BuildContext context,
    String text,
    GestureTapCallback fun,
    Icon icon,
  ) {
    return ListTile(
      leading: icon,
      title: Text(text),
      selected: true,
      onTap: fun,
    );
  }
}
