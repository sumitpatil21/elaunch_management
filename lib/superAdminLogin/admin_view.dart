import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Dashboard/dashboard_view.dart';
import '../Employee/employee_bloc.dart';
import '../SuperAdminLogin/admin_event.dart';
import '../SuperAdminLogin/admin_state.dart';
import 'admin_bloc.dart';

class AdminView extends StatefulWidget {
  static String routeName = "/admin";

  const AdminView({super.key});

  static Widget builder(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AdminBloc()),
        BlocProvider(create: (context) => EmployeeBloc()),
      ],
      child: const AdminView(),
    );
  }

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> with TickerProviderStateMixin {
  late TabController tabController;
  final loginFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();
  final registerNameController = TextEditingController();
  final registerEmailController = TextEditingController();
  final registerPasswordController = TextEditingController();
  final registerConfirmPasswordController = TextEditingController();
  final registerCompanyNameController = TextEditingController();
  final registerFieldController = TextEditingController();
  final registerPhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      context.read<AdminBloc>().add(
        ChangeTabIndex(tabIndex: tabController.index),
      );
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    loginEmailController.dispose();
    loginPasswordController.dispose();
    registerNameController.dispose();
    registerEmailController.dispose();
    registerPasswordController.dispose();
    registerConfirmPasswordController.dispose();
    registerCompanyNameController.dispose();
    registerFieldController.dispose();
    registerPhoneController.dispose();
    super.dispose();
  }

  void showSnackBar(String message, {bool isError = true}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: Duration(seconds: isError ? 4 : 2),
        ),
      );
    }
  }
  void loginLogic() {
    final adminBloc = context.read<AdminBloc>();
    final employeeBloc = context.read<EmployeeBloc>();

    if (loginFormKey.currentState!.validate()) {
      final email = loginEmailController.text.trim();
      final password = loginPasswordController.text;
      log('User login with : ${adminBloc.state.selectedRole}');

      if (adminBloc.state.selectedRole == 'Admin'&&email =="admin123@gmail.com") {
        log('Admin login with email: $email');
        adminBloc.add(AdminLogin(email: email, password: password));
      } else if (adminBloc.state.selectedRole == 'Employee') {
        log('Employee login with email: $email');
        employeeBloc.add(EmployeeLogin(email: email, password: password));
      }
      else {
        showSnackBar('Invalid credentials');
      }
    }
  }


  void forgotPasswordLogic() {
    if (loginEmailController.text.trim().isEmpty) {
      showSnackBar('Please enter your email address first');
      return;
    }

    context.read<AdminBloc>().add(
      AdminForgotPassword(email: loginEmailController.text.trim()),
    );
  }

  void clearRegisterForm() {
    registerNameController.clear();
    registerEmailController.clear();
    registerPasswordController.clear();
    registerConfirmPasswordController.clear();
    registerCompanyNameController.clear();
    registerFieldController.clear();
    registerPhoneController.clear();
  }

  bool get isMobile => MediaQuery.of(context).size.width < 600;
  bool get isDesktop => MediaQuery.of(context).size.width >= 600;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AdminBloc, AdminState>(
          listener: (context, state) {
            if (state.isLogin && state.adminModal != null) {
              log('Admin login successful: ${state.adminModal!.name}');
              Navigator.pushReplacementNamed(context, DashboardView.routeName,arguments: SelectRole(adminModal: state.adminModal,selectedRole: "Admin"));
            }
            if (tabController.index != state.currentTabIndex) {
              tabController.animateTo(state.currentTabIndex);
            }
          },
        ),
        BlocListener<EmployeeBloc, EmployeeState>(
          listener: (context, state) {
            if (state.isLogin && state.loggedInEmployee != null) {
              log('Employee login successful: ${state.loggedInEmployee!.name}');
              Navigator.pushReplacementNamed(context, DashboardView.routeName,arguments: SelectRole(employeeModal: state.loggedInEmployee,selectedRole: "Employee"));
            }

          },
        ),
      ],
      child: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, adminState) {
          return BlocBuilder<EmployeeBloc, EmployeeState>(
            builder: (context, employeeState) {
              final isLoading = adminState.isLoading || employeeState.isLoading;

              return Scaffold(
                body: SafeArea(
                  child:
                      isDesktop
                          ? desktopLayout(adminState, isLoading)
                          : _buildMobileLayout(adminState, isLoading),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget desktopLayout(AdminState state, bool isLoading) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF283653),
                  const Color(0xFF283653).withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.business_center,
                      size: 80,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'eLaunch Management',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Streamline your business operations with our comprehensive management platform',
                      style: TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                    const SizedBox(height: 40),
                    _buildFeatureList(),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Right side - Auth forms
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: _buildAuthContent(state, isLoading),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(AdminState state, bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildMobileHeader(state),
          const SizedBox(height: 30),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: _buildAuthContent(state, isLoading),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureList() {
    final features = [
      '🚀 Launch Management',
      '👥 Team Collaboration',
      '📊 Analytics dashboard',
      '🔒 Secure Authentication',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          features
              .map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    feature,
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _buildMobileHeader(AdminState state) {
    return Column(
      children: [
        Container(
          width: 100,

          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade600, Colors.blue.shade800],
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.business_center,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'eLaunch Management',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          state.currentTabIndex == 0 ? 'Welcome Back!' : 'Create Account',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildAuthContent(AdminState state, bool isLoading) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonFormField<String>(
            value: state.selectedRole,
            decoration: const InputDecoration(
              labelText: 'Login As',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              prefixIcon: Icon(Icons.person_outline),
            ),
            items:
                ['Admin', 'Employee'].map((role) {
                  return DropdownMenuItem(value: role, child: Text(role));
                }).toList(),
            onChanged: (value) {
              if (value != null) {
                context.read<AdminBloc>().add(ChangeRole(role: value));
              }
            },
          ),
        ),
        const SizedBox(height: 24),

        SizedBox(
          height: state.currentTabIndex == 0 ? 320 : 600,
          child: _buildLoginForm(state, isLoading),
        ),
      ],
    );
  }

  Widget _buildLoginForm(AdminState state, bool isLoading) {
    return Form(
      key: loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: loginEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: loginPasswordController,
            obscureText: state.obscureLoginPassword,
            decoration: InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  state.obscureLoginPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () {
                  context.read<AdminBloc>().add(
                    ToggleObscurePassword(passwordType: 'login'),
                  );
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          if (state.selectedRole == 'Admin')
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: forgotPasswordLogic,
                child: const Text('Forgot Password?'),
              ),
            ),
          const SizedBox(height: 24),

          // Login Button
          ElevatedButton(
            onPressed: isLoading ? null : loginLogic,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF283653),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child:
                isLoading
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : Text(
                      'Login as ${state.selectedRole}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
