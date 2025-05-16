
import 'package:elaunch_management/Dashboard/splaceScreen.dart';
import 'package:elaunch_management/Department/department_view.dart';
import 'package:elaunch_management/Manager/manager_view.dart';
import 'package:elaunch_management/SuperAdminLogin/admin_view.dart';
import 'package:flutter/material.dart';

import 'Dashboard/dashboard_view.dart';
import 'Employee/employee_view.dart';
import 'Service/db_helper.dart';

void main() {

  WidgetsFlutterBinding.ensureInitialized();
  DbHelper.dbHelper.createDatabase();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      routes: routes,
      initialRoute: SplashScreen.routeName,
    );
  }

  Map<String, WidgetBuilder> get routes => {
    SplashScreen.routeName:SplashScreen.builder,
    AdminView.routeName:AdminView.builder,
    DashboardView.routeName:DashboardView.builder,
    DepartmentScreen.routeName:DepartmentScreen.builder,
    ManagerScreen.routeName:ManagerScreen.builder,
    EmployeeScreen.routeName:EmployeeScreen.builder,
  };
}
