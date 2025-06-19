import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Employee/employee_bloc.dart';
import '../SuperAdminLogin/admin_bloc.dart';
import '../SuperAdminLogin/admin_event.dart';
import '../SuperAdminLogin/admin_view.dart';

import 'dashboard_view.dart';

class SplashScreen extends StatefulWidget {
  static String routeName = "/";

  const SplashScreen({super.key});

  static Widget builder(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AdminBloc()),
        BlocProvider(create: (context) => EmployeeBloc()),
      ],
      child: SplashScreen(),
    );
  }

  _SplashScreenState createState() {
    return _SplashScreenState();
  }
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> scale;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    scale = Tween<double>(begin: 0.5, end: 1.0).animate(animationController);
    animationController.forward();

    Timer(Duration(seconds: 3), () {
      checkLoginStatus();
    });
  }

  void checkLoginStatus() {
    Future.delayed(Duration(milliseconds: 500), () {
      if (!mounted) return;

      final adminBloc = context.read<AdminBloc>().state;
      final employeeBloc = context.read<EmployeeBloc>().state;

      log(
        'Admin login status: ${adminBloc.isLogin}, Employee login status: ${employeeBloc.isLogin}',
      );

      if (adminBloc.isLogin && adminBloc.adminModal != null) {
        Navigator.of(context).pushReplacementNamed(
          DashboardView.routeName,
          arguments: SelectRole(
            adminModal: adminBloc.adminModal!,
            selectedRole: "Admin",
          ),
        );
      } else if (employeeBloc.isLogin &&
          employeeBloc.loggedInEmployee != null) {
        Navigator.of(context).pushReplacementNamed(
          DashboardView.routeName,
          arguments: SelectRole(
            employeeModal: employeeBloc.loggedInEmployee!,
            selectedRole: "Employee",
          ),
        );
      } else {
        Navigator.of(context).pushReplacementNamed(AdminView.routeName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF283653), Color(0xFF283653).withOpacity(0.2)],
          ),
        ),
        child: AnimatedBuilder(
          animation: animationController,
          builder: (context, child) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: NetworkImage(
                      'assest/image/Elaunch Letter E Logo.png',
                    ),
                    height: 50,
                  ),
                  SizedBox(height: 30),
                  Text(
                    'eLaunch',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Launch Your Success',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 50),
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    strokeWidth: 2,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
