import 'package:elaunch_management/employee_chat/chat_bloc.dart';
import 'package:elaunch_management/employee_chat/chat_state.dart';
import 'package:elaunch_management/employee_chat/chat_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Department/department_bloc.dart';
import '../Department/department_view.dart';
import '../Device_Testing/device_bloc.dart';
import '../Device_Testing/device_view.dart';
import '../Employee/employee_bloc.dart';
import '../Employee/employee_state.dart';
import '../Employee/employee_view.dart';
import '../Leave/leave_bloc.dart';
import '../Leave/leave_state.dart';
import '../Leave/leave_view.dart';
import '../SuperAdminLogin/admin_bloc.dart';
import '../SuperAdminLogin/admin_event.dart';
import '../SuperAdminLogin/admin_view.dart';
import '../System/system_bloc.dart';
import '../System/system_state.dart';
import '../System/system_view.dart';

class DashboardWidgets {
  static Widget welcomeSection(
    BuildContext context,
    SelectRole user,
    bool isMobile,
  ) {
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

  static Widget managementSection(
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
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: isMobile ? 1 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: managementCards(context, user),
        ),
      ],
    );
  }

  static Widget overviewSection(
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
          _desktopOverview(context, user),
      ],
    );
  }

  static List<Widget> managementCards(BuildContext context, SelectRole user) {
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
                    style: const TextStyle(
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
                    style: const TextStyle(
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
                    style: const TextStyle(
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
                    style: const TextStyle(
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
            (context, state) => BlocBuilder<LeaveBloc, LeaveState>(
              builder:
                  (context, state) => Text(
                    '${state.leaves.length}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
            ),
      ),
      ManagementCardData(
        title: 'Chat',
        icon: Icons.chat_bubble_outline_rounded,
        color: Color(0xff1a2a4d),
        route: ChatScreen.routeName,
        selectRole: user,
        builder:
            (context, state) => BlocBuilder<ChatBloc, ChatState>(
              builder:
                  (context, state) => Text(
                    '0',
                    style: const TextStyle(
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

  static Widget hoverCard(
    BuildContext context,
    ManagementCardData cardData,
    SelectRole user,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.grab,
      child: AnimatedContainer(
        curve: Curves.bounceInOut,
        duration: const Duration(seconds: 5),
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
                    color: cardData.color.withOpacity(0.2),
                    blurRadius: 50,
                    spreadRadius: 10,
                    offset: const   Offset(1, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(cardData.icon, size: 32, color: Colors.white),
                    const SizedBox(height: 8),
                    Text(
                      cardData.title,
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
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

  static Widget mobileOverview(BuildContext context, SelectRole user) {
    return Column(
      children: [
        overviewCard(
          context,
          'Department Overview',

          Colors.blue,
          Icons.business,
          DepartmentScreen.routeName,
          user,
          BlocBuilder<DepartmentBloc, DepartmentState>(
            builder: (context, state) {
              if (state.departments.isEmpty) {
                return const Center(
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
                        (dept) => _listTile(
                          dept.name,
                          'Department',
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
                      padding: const EdgeInsets.all(8),
                      child: Center(
                        child: Text(
                          '+ ${state.departments.length - 3} more',
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        overviewCard(
          context,
          'Employee Overview',
          Colors.red,
          Icons.group,
          EmployeeScreen.routeName,
          user,
          BlocBuilder<EmployeeBloc, EmployeeState>(
            builder: (context, state) {
              if (state.employees.isEmpty) {
                return const Center(
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
                        (emp) => _listTile(
                          emp.name,
                          'Employee',
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
                      padding: const EdgeInsets.all(8),
                      child: Center(
                        child: Text(
                          '+ ${state.employees.length - 3} more',
                          style: const TextStyle(color: Colors.red),
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
              leading: const Icon(Icons.calendar_today, color: Colors.white),
              title: const Text(
                'Calendar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, LeaveView.routeName);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Calendar feature coming soon!'),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  static Widget _desktopOverview(BuildContext context, SelectRole user) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        fullOverviewCard(
          context,
          'Department Overview',
          Colors.blue,
          DepartmentScreen.routeName,
          user,
          BlocBuilder<DepartmentBloc, DepartmentState>(
            builder: (context, state) {
              if (state.departments.isEmpty) {
                return const Center(child: Text("No Departments"));
              }
              return ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: state.departments.length,
                itemBuilder:
                    (context, index) => _listTile(
                      state.departments[index].name,
                      'Department',
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
          'Employee Overview',
          Colors.red,
          EmployeeScreen.routeName,
          user,
          BlocBuilder<EmployeeBloc, EmployeeState>(
            builder: (context, state) {
              if (state.employees.isEmpty) {
                return const Center(child: Text("No Employees"));
              }
              return ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: state.employees.length,
                itemBuilder:
                    (context, index) => _listTile(
                      state.employees[index].name,
                      'Employee',
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
          'System Overview',
          Colors.orange,
          SystemView.routeName,
          user,
          BlocBuilder<SystemBloc, SystemState>(
            builder: (context, state) {
              if (state.systems.isEmpty) {
                return const Center(child: Text("No Systems"));
              }
              return ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: state.systems.length,
                itemBuilder:
                    (context, index) => _listTile(
                      state.systems[index].systemName,
                      'System',
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
                return const Center(child: Text("No Devices"));
              }
              return ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: state.devices.length,
                itemBuilder:
                    (context, index) => _listTile(
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

  static Widget overviewCard(
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
            padding: const EdgeInsets.all(8),
            color: color,
            width: double.infinity,
            child: Text(
              title,
              style: const TextStyle(
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

  static Widget fullOverviewCard(
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
            padding: const EdgeInsets.all(8),
            color: color,
            width: double.infinity,
            child: Text(
              title,
              style: const TextStyle(
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

  static Widget _listTile(
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
        child: const Icon(Icons.arrow_forward_ios_rounded, size: 17),
      ),
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child:
            icon != null
                ? Icon(icon, size: 16)
                : Text(empName?[0].toUpperCase() ?? 'E'),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle),
    );
  }

  static Drawer drawer(BuildContext context, SelectRole user) {
    final drawerItems = [
      DrawerItem("Dashboard", Icons.dashboard, () {}),
      DrawerItem(
        "Department",
        Icons.business,
        () => Navigator.pushNamed(
          context,
          DepartmentScreen.routeName,
          arguments: user,
        ),
      ),
      DrawerItem(
        "Employee",
        Icons.group,
        () => Navigator.pushNamed(
          context,
          EmployeeScreen.routeName,
          arguments: user,
        ),
      ),
      DrawerItem(
        "System",
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
        "Leave",
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
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(_userEmail(user)),
          ),
          ...drawerItems.map(
            (item) => ListTile(
              leading: Icon(item.icon),
              title: Text(item.title),
              onTap: item.onTap,
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () {
              context.read<AdminBloc>().add(AdminLogout());
              Navigator.of(context).pushReplacementNamed(AdminView.routeName);
            },
          ),
        ],
      ),
    );
  }

  // Helper methods
  static String userInitial(SelectRole user) {
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

  static String userName(SelectRole user) {
    if (user.employeeModal != null) {
      return user.employeeModal?.name??"user";
    } else if (user.adminModal != null) {
      return user.adminModal?.name??"user";
    }
    return 'User';
  }

  static String userRole(SelectRole user) {
    if (user.employeeModal != null) {
      return 'Employee';
    } else if (user.adminModal != null) {
      return 'Admin';
    }
    return 'User';
  }

  static String _userEmail(SelectRole user) {
    if (user.employeeModal != null) {
      return user.employeeModal!.email;
    } else if (user.adminModal != null) {
      return user.adminModal!.email;
    }
    return 'user@example.com';
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
