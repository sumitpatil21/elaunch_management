import 'package:elaunch_management/Service/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'Device_Testing/device_view.dart';
import 'Leave/leave_view.dart';
import 'System/system_view.dart';
import 'firebase_options.dart';
import 'package:elaunch_management/Dashboard/splaceScreen.dart';
import 'package:elaunch_management/Department/department_view.dart';
import 'package:elaunch_management/SuperAdminLogin/admin_view.dart';
import 'package:flutter/material.dart';

import 'Dashboard/dashboard_view.dart';
import 'Employee/employee_view.dart';
import 'Service/db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Only use emulator in debug mode
    if (kDebugMode) {
      await FirebaseAuth.instance.useAuthEmulator('10.0.2.2', 9099);
    }

    // Initialize database
    // await DbHelper.dbHelper.createDatabase();

    runApp(const MyApp());
  } catch (e) {
    print('Firebase initialization error: $e');
    // Handle error appropriately
  }
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
    EmployeeScreen.routeName:EmployeeScreen.builder,
    SystemView.routeName:SystemView.builder,
    DeviceView.routeName:DeviceView.builder,
    LeaveView.routeName:LeaveView.builder,
  };
}
