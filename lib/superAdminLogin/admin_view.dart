import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:elaunch_management/Dashboard/dashboard_view.dart';
import 'package:elaunch_management/Employee/employee_bloc.dart';
import '../SuperAdminLogin/admin_bloc.dart';
import '../SuperAdminLogin/admin_event.dart';
import '../SuperAdminLogin/admin_state.dart';

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

class _AdminViewState extends State<AdminView> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  String selectedRole = 'Admin';

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void loginLogic() {
    if (formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      final email = emailController.text.trim();
      final password = passwordController.text;

      if (selectedRole == 'Admin') {
        context.read<AdminBloc>().add(
          AdminLogin(email: email, password: password),
        );
      } else {
        context.read<EmployeeBloc>().add(
          EmployeeLogin(email: email, password: password),
        );
      }
    }
  }

  bool get isMobile => MediaQuery.of(context).size.width < 600;
  bool get isDesktop => MediaQuery.of(context).size.width >= 600;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AdminBloc, AdminState>(
          listener: (context, state) {
            setState(() => isLoading = false);

            if (state.errorMessage != null) {
              showSnackBar(state.errorMessage!);
            } else if (state.isLogin && state.adminModal != null) {
              log('Admin login successful: ${state.adminModal!.name}');
              Navigator.pushReplacementNamed(
                context,
                DashboardView.routeName,
                arguments: SelectRole(
                  adminModal: state.adminModal,
                  selectedRole: "Admin",
                ),
              );
            }
          },
        ),
        BlocListener<EmployeeBloc, EmployeeState>(
          listener: (context, state) {
            setState(() => isLoading = false);

            if (state.loggedInEmployee != null) {
              log('Employee login successful: ${state.loggedInEmployee!.name}');
              Navigator.pushReplacementNamed(
                context,
                DashboardView.routeName,
                arguments: SelectRole(
                  employeeModal: state.loggedInEmployee,
                  selectedRole: "Employee",
                ),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        body: SafeArea(child: isDesktop ? desktopLayout() : mobileLayout()),
      ),
    );
  }

  Widget desktopLayout() {
    return Row(
      children: [
        // Left side - Branding
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF283653),
                  const Color(0xFF283653).withOpacity(0.2),
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
                      size: 60,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'eLaunch Management',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Streamline your business operations',
                      style: TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Right side - Login form
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Card(
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: loginForm(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget mobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 40),
          mobileHeader(),
          const SizedBox(height: 40),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: loginForm(),
            ),
          ),
        ],
      ),
    );
  }

  Widget loginForm() {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isDesktop) ...[
            const Text(
              'Sign In',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
          ] else ...[
            const Text(
              'Welcome Back',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please sign in to your account',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
          ],

          DropdownButtonFormField<String>(
            value: selectedRole,
            decoration: InputDecoration(
              labelText: 'Login As',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(Icons.person_outline),
            ),
            items:
                ['Admin', 'Employee'].map((role) {
                  return DropdownMenuItem(value: role, child: Text(role));
                }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => selectedRole = value);
              }
            },
          ),
          const SizedBox(height: 20),

          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          TextFormField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(Icons.lock_outline),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 4) {
                return 'Password must be at least 4 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 30),

          ElevatedButton(
            onPressed: isLoading ? null : loginLogic,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child:
                isLoading
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Text('Sign In', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget mobileHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.blue.shade600,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.business_center,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'eLaunch Management',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          'Welcome Back!',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }
}
