import 'package:elaunch_management/service/firebase_notifications.dart';
import 'package:firebase_core/firebase_core.dart';

import 'Device_Testing/device_view.dart';
import 'Leave/leave_view.dart';
import 'System/system_view.dart';
import 'employee_chat/chat_view.dart';
import 'firebase_options.dart';
import 'package:elaunch_management/Dashboard/splaceScreen.dart';
import 'package:elaunch_management/Department/department_view.dart';
import 'package:elaunch_management/SuperAdminLogin/admin_view.dart';
import 'package:flutter/material.dart';
import 'Dashboard/dashboard_view.dart';
import 'Employee/employee_view.dart';
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Firebase Messaging
  final messagingService = FirebaseMessagingService();
  await messagingService.initialize();

  runApp(MyApp(messagingService: messagingService));
}

class MyApp extends StatelessWidget {
  final FirebaseMessagingService messagingService;

  const MyApp({super.key, required this.messagingService});

  @override
  Widget build(BuildContext context) {
    // Set up notification tap handler
    messagingService.onNotificationTap = (data) {
      if (data['type'] == 'chat') {
        Navigator.pushNamed(
          context,
          ChatScreen.routeName,
          arguments: {
            'otherUserId': data['senderId'],
            'otherUserName': data['senderName'],
            'roomId': data['roomId'],
          },
        );
      }
    };

    return MaterialApp(
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      routes: routes,
      initialRoute: SplashScreen.routeName,
    );
  }


  Map<String, WidgetBuilder> get routes => {
    SplashScreen.routeName: SplashScreen.builder,
    AdminView.routeName: AdminView.builder,
    DashboardView.routeName: DashboardView.builder,
    DepartmentScreen.routeName: DepartmentScreen.builder,
    EmployeeScreen.routeName: EmployeeScreen.builder,
    SystemView.routeName: SystemView.builder,
    DeviceView.routeName: DeviceView.builder,
    LeaveView.routeName: LeaveView.builder,
    ChatScreen.routeName: ChatScreen.builder,
  };
}
