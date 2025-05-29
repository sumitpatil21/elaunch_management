import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../SuperAdminLogin/admin_bloc.dart';
import '../SuperAdminLogin/admin_view.dart';
import 'dashboard_view.dart';

class SplashScreen extends StatefulWidget {
  static String routeName = "/";
  static Widget builder(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (context) => AdminBloc())],
      child: SplashScreen(),
    );
  }

  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    final adminBloc = context.read<AdminBloc>();
    adminBloc.add(AdminFetch());
    Future.delayed(Duration(seconds: 2)).then((_) {
      if (adminBloc.state.adminList!.isNotEmpty==true) {
        Navigator.of(context).pushReplacementNamed(DashboardView.routeName,arguments: adminBloc.state.adminList?.first);
      } else {
        Navigator.of(context).pushReplacementNamed(AdminView.routeName);
   }
      });
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Icon(Icons.manage_accounts),
      ),
    );
  }
}

