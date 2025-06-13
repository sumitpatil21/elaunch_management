import 'dart:developer';

import 'package:elaunch_management/Department/department_view.dart';
import 'package:elaunch_management/Device_Testing/device_view.dart';
import 'package:elaunch_management/Employee/employee_view.dart';
import 'package:elaunch_management/SuperAdminLogin/admin_bloc.dart';
import 'package:elaunch_management/SuperAdminLogin/admin_event.dart';

import 'package:elaunch_management/System/system_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Department/department_bloc.dart';
import '../Device_Testing/device_bloc.dart';
import '../Device_Testing/device_event.dart';
import '../Employee/employee_bloc.dart';

import '../Leave/leave_view.dart';

import '../SuperAdminLogin/admin_state.dart';
import '../SuperAdminLogin/admin_view.dart';
import '../System/system_event.dart';
import '../System/system_state.dart';
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
        BlocProvider(create: (context) => EmployeeBloc()..add(LoadEmployees())),
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
    super.initState();
    _initializeData();
  }

  void _initializeData() {

    context.read<EmployeeBloc>().add(LoadEmployees());
    context.read<DepartmentBloc>().add(FetchDepartments());
    context.read<SystemBloc>().add(FetchSystem());
    context.read<DeviceBloc>().add(FetchDevice());


  }

  void refreshData() {
    context.read<AdminBloc>().add(AdminFetch());
    context.read<EmployeeBloc>().add(LoadEmployees());
    context.read<DepartmentBloc>().add(FetchDepartments());
    context.read<SystemBloc>().add(FetchSystem());
    context.read<DeviceBloc>().add(FetchDevice());
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
              drawer: isMobile ? drawer(context, user) : null,
              body: Row(
                children: [
                  if (!isMobile)
                    SizedBox(width: 240, child: drawer(context, user)),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            welcomeSection(context, user, isMobile),
                            managementSection(context, user, isMobile),
                            SizedBox(height: 24),
                            overviewSection(context, user, isMobile),
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
      title: Text(
        "dashboard",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
          onPressed: refreshData,
          icon: Icon(Icons.refresh, color: Colors.white),
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

  String userName(SelectRole user) {
    if (user.employeeModal != null) {
      return user.employeeModal!.name;
    } else if (user.adminModal != null) {
      return user.adminModal!.name;
    }
    return 'User';
  }

  String userRole(SelectRole user) {
    if (user.employeeModal != null) {
      return 'employee';
    } else if (user.adminModal != null) {
      return 'Admin';
    }
    return 'User';
  }

  String userEmail(SelectRole user) {
    if (user.employeeModal != null) {
      return user.employeeModal!.email;
    } else if (user.adminModal != null) {
      return user.adminModal!.email;
    }
    return 'user@example.com';
  }

  Widget welcomeSection(BuildContext context, SelectRole user, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        "Welcome ${userRole(user)}, ${userName(user)} 👋",
        style: TextStyle(
          fontSize: isMobile ? 20 : 24,
          fontWeight: FontWeight.bold,
          color:
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
        ),
      ),
    );
  }

  Widget managementSection(
    BuildContext context,
    SelectRole user,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        GridView.count(
          crossAxisCount: isMobile ? 2 : 3,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          childAspectRatio: isMobile ? 1 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: managementCards(context, user),
        ),
      ],
    );
  }

  List<Widget> managementCards(BuildContext context, SelectRole user) {
    final cards = [
      ManagementCardData(
        title: 'Departments',
        icon: Icons.business,
        color: Colors.blue,
        route: DepartmentScreen.routeName,
        selectRole: user,
        builder:
            (context, state) => BlocBuilder<DepartmentBloc, DepartmentState>(
              builder:
                  (context, state) => Text(
                    '${state.departments.length}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
            ),
      ),
      ManagementCardData(
        title: 'Employees',
        icon: Icons.group,
        color: Colors.red,
        route: EmployeeScreen.routeName,
        selectRole: user,
        builder:
            (context, state) => BlocBuilder<EmployeeBloc, EmployeeState>(
              builder:
                  (context, state) => Text(
                    '${state.employees.length}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
            ),
      ),
      ManagementCardData(
        title: 'Systems',
        icon: Icons.computer_outlined,
        color: Colors.orange,
        route: SystemView.routeName,
        selectRole: user,
        builder:
            (context, state) => BlocBuilder<SystemBloc, SystemState>(
              builder:
                  (context, state) => Text(
                    '${state.systems.length}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
            ),
      ),
      ManagementCardData(
        title: 'Devices',
        icon: Icons.phone_android_outlined,
        color: Colors.purple,
        route: DeviceView.routeName,
        selectRole: user,
        builder:
            (context, state) => BlocBuilder<DeviceBloc, DeviceState>(
              builder:
                  (context, state) => Text(
                    '${state.devices.length}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
            ),
      ),
      ManagementCardData(
        title: 'Leaves',
        icon: Icons.leave_bags_at_home_outlined,
        color: Colors.green,
        route: LeaveView.routeName,
        selectRole: user,
        builder:
            (context, state) => BlocBuilder<DeviceBloc, DeviceState>(
              builder:
                  (context, state) => Text(
                    '${state.devices.length}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
            ),
      ),
    ];

    return cards.map((cardData) => hoverCard(context, cardData, user)).toList();
  }

  Widget hoverCard(
    BuildContext context,
    ManagementCardData cardData,
    SelectRole user,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        child: InkWell(
          onTap:
              () =>
                  Navigator.pushNamed(context, cardData.route, arguments: user),
          onHover: (isHovered) {},
          borderRadius: BorderRadius.circular(8),
          child: Card(
            elevation: 4,
            color: cardData.color,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: cardData.color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(cardData.icon, size: 32, color: Colors.white),
                    SizedBox(height: 8),
                    Text(
                      cardData.title,
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    SizedBox(height: 8),
                    cardData.builder(context, null),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget overviewSection(BuildContext context, SelectRole user, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          mobileOverview(context, user)
        else
          desktopOverview(context, user),
      ],
    );
  }

  Widget mobileOverview(BuildContext context, SelectRole user) {
    return Column(
      children: [
        overviewCard(
          context,
          'department Overview',
          Colors.blue,
          Icons.business,
          DepartmentScreen.routeName,
          user,
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
                children: [
                  ...state.departments
                      .take(3)
                      .map(
                        (dept) => listTile(
                          dept.name,
                          'department',
                          Icons.business,
                          Colors.blue,
                          () => Navigator.pushNamed(
                            context,
                            DepartmentScreen.routeName,
                            arguments: user,
                          ),
                        ),
                      ),
                  if (state.departments.length > 3)
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Center(
                        child: Text(
                          '+ ${state.departments.length - 3} more',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        SizedBox(height: 16),
        overviewCard(
          context,
          'employee Overview',
          Colors.red,
          Icons.group,
          EmployeeScreen.routeName,
          user,
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
                children: [
                  ...state.employees
                      .take(3)
                      .map(
                        (emp) => listTile(
                          emp.name,
                          'employee',
                          null,
                          Colors.red,
                          () => Navigator.pushNamed(
                            context,
                            EmployeeScreen.routeName,
                            arguments: user,
                          ),
                          empName: emp.name,
                        ),
                      ),
                  if (state.employees.length > 3)
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Center(
                        child: Text(
                          '+ ${state.employees.length - 3} more',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        if (user.employeeModal != null)
          Card(
            elevation: 2,

            child: ListTile(
              tileColor: Colors.grey,
              leading: Icon(Icons.calendar_today, color: Colors.white),
              title: Text(
                'Calendar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, LeaveView.routeName);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Calendar feature coming soon!')),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget desktopOverview(BuildContext context, SelectRole user) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      childAspectRatio: 2.2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        fullOverviewCard(
          context,
          'department Overview',
          Colors.blue,
          DepartmentScreen.routeName,
          user,
          BlocBuilder<DepartmentBloc, DepartmentState>(
            builder: (context, state) {
              if (state.departments.isEmpty) {
                return Center(child: Text("No Departments"));
              }
              return ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: state.departments.length,
                itemBuilder:
                    (context, index) => listTile(
                      state.departments[index].name,
                      'department',
                      Icons.business,
                      Colors.blue,
                      () => Navigator.pushNamed(
                        context,
                        DepartmentScreen.routeName,
                        arguments: user,
                      ),
                    ),
              );
            },
          ),
        ),
        fullOverviewCard(
          context,
          'employee Overview',
          Colors.red,
          EmployeeScreen.routeName,
          user,
          BlocBuilder<EmployeeBloc, EmployeeState>(
            builder: (context, state) {
              if (state.employees.isEmpty) {
                return Center(child: Text("No Employees"));
              }
              return ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: state.employees.length,
                itemBuilder:
                    (context, index) => listTile(
                      state.employees[index].name,
                      'employee',
                      null,
                      Colors.red,
                      () => Navigator.pushNamed(
                        context,
                        EmployeeScreen.routeName,
                        arguments: user,
                      ),
                      empName: state.employees[index].name,
                    ),
              );
            },
          ),
        ),
        fullOverviewCard(
          context,
          'system Overview',
          Colors.orange,
          SystemView.routeName,
          user,
          BlocBuilder<SystemBloc, SystemState>(
            builder: (context, state) {
              if (state.systems.isEmpty) {
                return Center(child: Text("No Systems"));
              }
              return ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: state.systems.length,
                itemBuilder:
                    (context, index) => listTile(
                      state.systems[index].systemName,
                      'system',
                      Icons.computer_outlined,
                      Colors.orange,
                      () => Navigator.pushNamed(
                        context,
                        SystemView.routeName,
                        arguments: user,
                      ),
                    ),
              );
            },
          ),
        ),
        fullOverviewCard(
          context,
          'Device Overview',
          Colors.purple,
          DeviceView.routeName,
          user,
          BlocBuilder<DeviceBloc, DeviceState>(
            builder: (context, state) {
              if (state.devices.isEmpty) {
                return Center(child: Text("No Devices"));
              }
              return ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: state.devices.length,
                itemBuilder:
                    (context, index) => listTile(
                      state.devices[index].deviceName,
                      'Device',
                      Icons.phone_android_outlined,
                      Colors.purple,
                      () => Navigator.pushNamed(
                        context,
                        DeviceView.routeName,
                        arguments: user,
                      ),
                    ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget overviewCard(
    BuildContext context,
    String title,
    Color color,
    IconData icon,
    String route,
    SelectRole user,
    Widget content,
  ) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            color: color,
            width: double.infinity,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          content,
        ],
      ),
    );
  }

  Widget fullOverviewCard(
    BuildContext context,
    String title,
    Color color,
    String route,
    SelectRole user,
    Widget content,
  ) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            color: color,
            width: double.infinity,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(child: content),
        ],
      ),
    );
  }

  Widget listTile(
    String title,
    String subtitle,
    IconData? icon,
    Color color,
    VoidCallback onTap, {
    String? empName,
  }) {
    return ListTile(
      trailing: GestureDetector(
        onTap: onTap,
        child: Icon(Icons.arrow_forward_ios_rounded, size: 17),
      ),
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child:
            icon != null
                ? Icon(icon, size: 16)
                : Text(empName?[0].toUpperCase() ?? 'E'),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle),
    );
  }

  Drawer drawer(BuildContext context, SelectRole user) {
    final drawerItems = [
      DrawerItem("dashboard", Icons.dashboard, () {}),
      DrawerItem(
        "department",
        Icons.business,
        () => Navigator.pushNamed(
          context,
          DepartmentScreen.routeName,
          arguments: user,
        ),
      ),
      DrawerItem(
        "employee",
        Icons.group,
        () => Navigator.pushNamed(
          context,
          EmployeeScreen.routeName,
          arguments: user,
        ),
      ),
      DrawerItem(
        "system",
        Icons.computer_outlined,
        () =>
            Navigator.pushNamed(context, SystemView.routeName, arguments: user),
      ),
      DrawerItem(
        "Device",
        Icons.phone_android_outlined,
        () =>
            Navigator.pushNamed(context, DeviceView.routeName, arguments: user),
      ),
      DrawerItem(
        "leave",
        Icons.leave_bags_at_home_outlined,
        () =>
            Navigator.pushNamed(context, LeaveView.routeName, arguments: user),
      ),
    ];

    return Drawer(
      width: 240,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            currentAccountPicture: CircleAvatar(
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
            accountName: Text(
              userName(user),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(userEmail(user)),
          ),
          ...drawerItems.map(
            (item) => ListTile(
              leading: Icon(item.icon),
              title: Text(item.title),
              onTap: item.onTap,
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () {
              context.read<AdminBloc>().add(AdminLogout());
              Navigator.of(context).pushReplacementNamed(AdminView.routeName);
            },
          ),
        ],
      ),
    );
  }
}

class ManagementCardData {
  final String title;
  final IconData icon;
  final Color color;
  final String route;
  final SelectRole selectRole;
  final Widget Function(BuildContext, dynamic) builder;

  ManagementCardData({
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
    required this.selectRole,
    required this.builder,
  });
}

class DrawerItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  DrawerItem(this.title, this.icon, this.onTap);
}
