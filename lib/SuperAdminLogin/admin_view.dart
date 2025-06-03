import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:elaunch_management/Dashboard/dashboard_view.dart';
import 'package:elaunch_management/Employee/employee_bloc.dart';
import 'package:elaunch_management/SuperAdminLogin/admin_bloc.dart';

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


  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void loginLogic() {
    if (formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      final email = emailController.text.trim();
      final password = passwordController.text;

      if (context.read<AdminBloc>().state.selectedRole == 'Admin') {
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
            if (state.isLogin &&
                state.adminModal != null &&
                state.selectedRole == "Admin") {
              log(state.adminModal?.name ?? "Data Not Found");
              setState(() => isLoading = false);
              Navigator.pushReplacementNamed(
                context,
                DashboardView.routeName,
                arguments: SelectRole(
                  adminModal: state.adminModal,
                  selectedRole: "Admin",
                ),
              );
            } else if (state.adminList?.isEmpty == true && isLoading) {
              setState(() => isLoading = false);
              showSnackBar("Invalid admin credentials");
            }
          },
        ),
        BlocListener<EmployeeBloc, EmployeeState>(
          listener: (context, state) {
            if (state.loggedInEmployee != null) {
              log(state.loggedInEmployee!.name);

              setState(() => isLoading = false);
              Navigator.pushReplacementNamed(
                context,
                DashboardView.routeName,
                arguments: SelectRole(
                  employeeModal: state.loggedInEmployee,
                  selectedRole: "Employee",
                ),
              );
            } else if (state.loggedInEmployee == null && isLoading) {
              setState(() => isLoading = false);
              showSnackBar("Invalid employee credentials");
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
        // Left
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF283653),Color(0xFF283653).withOpacity(0.2)],
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

        // Right
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(isDesktop ? 40.0 : 20.0),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!isDesktop) ...[
                            const Text(
                              'Sign In',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          DropdownButtonFormField<String>(
                            value: "Admin",
                            decoration: InputDecoration(
                              labelText: 'Login As',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: const Icon(Icons.person_outline),
                            ),
                            items:
                                ['Admin', 'Employee'].map((role) {
                                  return DropdownMenuItem(
                                    value: role,
                                    child: Text(role),
                                  );
                                }).toList(),
                            onChanged:
                                (value) =>
                                    setState(() => context.read<AdminBloc>().add(SelectRole(selectedRole: value!))),
                          ),
                          const SizedBox(height: 20),

                          TextFormField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: const Icon(Icons.email_outlined),
                            ),
                            validator:
                                (value) =>
                                    value!.isEmpty ? 'Enter email' : null,
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
                            validator:
                                (value) =>
                                    value!.length < 4
                                        ? 'Minimum 4 characters'
                                        : null,
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
                                      ),
                                    )
                                    : const Text('Sign In'),
                          ),
                        ],
                      ),
                    ),
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
              padding: EdgeInsets.all(isDesktop ? 40.0 : 20.0),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!isDesktop) ...[
                      const Text(
                        'Sign In',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    DropdownButtonFormField<String>(
                      value: "Admin",
                      decoration: InputDecoration(
                        labelText: 'Login As',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      items:
                          ['Admin', 'Employee'].map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(role),
                            );
                          }).toList(),
                      onChanged:
                          (value) => setState(() => context.read<AdminBloc>().add(SelectRole(selectedRole: value!))),
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      validator:
                          (value) => value!.isEmpty ? 'Enter email' : null,
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
                      validator:
                          (value) =>
                              value!.length < 4 ? 'Minimum 4 characters' : null,
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
                                ),
                              )
                              : const Text('Sign In'),
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
