import 'dart:developer';
import 'package:elaunch_management/Service/firebase_database.dart';
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

class _AdminViewState extends State<AdminView> with TickerProviderStateMixin {
  late TabController tabController;
  final loginFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();

  // Login Controllers
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();

  // Register Controllers
  final registerNameController = TextEditingController();
  final registerEmailController = TextEditingController();
  final registerPasswordController = TextEditingController();
  final registerConfirmPasswordController = TextEditingController();
  final registerCompanyNameController = TextEditingController();
  final registerFieldController = TextEditingController();
  final registerPhoneController = TextEditingController();

  bool isLoading = false;
  bool obscureLoginPassword = true;
  bool obscureRegisterPassword = true;
  bool obscureConfirmPassword = true;
  String selectedRole = 'Admin';
  int currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      setState(() {
        currentTabIndex = tabController.index;
      });
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
    if (loginFormKey.currentState!.validate()) {
      setState(() => isLoading = true);
      final email = loginEmailController.text.trim();
      final password = loginPasswordController.text;

      if (selectedRole == 'Admin') {
        log('Admin login with email: $email');
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

  void registerLogic() {
    if (registerFormKey.currentState!.validate()) {
      setState(() => isLoading = true);

      final name = registerNameController.text.trim();
      final email = registerEmailController.text.trim();
      final password = registerPasswordController.text;
      final companyName = registerCompanyNameController.text.trim();
      final field = registerFieldController.text.trim();
      final phone = registerPhoneController.text.trim();

      if (selectedRole == 'Admin') {
        context.read<AdminBloc>().add(
          AdminRegister(
            name: name,
            email: email,
            password: password,
            companyName: companyName,
            field: field,
            phone: phone,
          ),
        );

      } else {
        // context.read<EmployeeBloc>().add(
        // EmployeeRegister(
        // name: name,
        // email: email,
        // password: password,
        // companyName: companyName,
        // field: field,
        // phone: phone,
        // ),
        // );
      }
    }
  }

  void forgotPasswordLogic() {
    if (loginEmailController.text.trim().isEmpty) {
      showSnackBar('Please enter your email first');
      return;
    }

    setState(() => isLoading = true);
    context.read<AdminBloc>().add(
      AdminForgotPassword(email: loginEmailController.text.trim()),
    );
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

            if (state.isLogin && state.adminModal != null) {
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
        // BlocListener<EmployeeBloc, EmployeeState>(
        //   listener: (context, state) {
        //     setState(() => isLoading = false);
        //
        //     if (state.errorMessage != null) {
        //       showSnackBar(state.errorMessage!);
        //     } else if (state.loggedInEmployee != null) {
        //       log('Employee login successful: ${state.loggedInEmployee!.name}');
        //       Navigator.pushReplacementNamed(
        //         context,
        //         DashboardView.routeName,
        //         arguments: SelectRole(
        //           employeeModal: state.loggedInEmployee,
        //           selectedRole: "Employee",
        //         ),
        //       );
        //     } else if (state.isRegistrationSuccess) {
        //       showSnackBar('Registration successful! Please login.', isError: false);
        //       _tabController.animateTo(0); // Switch to login tab
        //       _clearRegisterForm();
        //     }
        //   },
        // ),
      ],
      child: Scaffold(
        body: SafeArea(
          child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Left side - Branding
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
                    child: _buildAuthContent(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildMobileHeader(),
          const SizedBox(height: 30),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: _buildAuthContent(),
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
      '📊 Analytics Dashboard',
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

  Widget _buildMobileHeader() {
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
          currentTabIndex == 0 ? 'Welcome Back!' : 'Create Account',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildAuthContent() {
    return Column(
      children: [
        // Role Selection
        Container(
          decoration: BoxDecoration(

            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedRole,
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
                setState(() => selectedRole = value);
              }
            },
          ),
        ),
        const SizedBox(height: 24),

        // Tab Bar
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF283653),
                const Color(0xFF283653).withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: tabController,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              // color: Theme.of(context).primaryColor,
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey[600],
            dividerColor: Colors.transparent,
            tabs: const [
              SizedBox(width: 100, child: Tab(text: 'Login')),
              SizedBox(width: 100, child: Tab(text: 'Register')),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Tab Content
        SizedBox(
          height: currentTabIndex == 0 ? 320 : 600,
          child: TabBarView(
            controller: tabController,
            children: [_buildLoginForm(), _buildRegisterForm()],
          ),
        ),
      ],
    );
  }


  Widget _buildLoginForm() {
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
              // FIX: Changed from "value.isEmpty" to "|| value.isEmpty"
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: loginPasswordController,
            obscureText: obscureLoginPassword,
            decoration: InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureLoginPassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() => obscureLoginPassword = !obscureLoginPassword);
                },
              ),
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
          const SizedBox(height: 8),

          // Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: isLoading ? null : forgotPasswordLogic,
              child: const Text('Forgot Password?'),
            ),
          ),
          const SizedBox(height: 16),

          // Login Button
          ElevatedButton(
            onPressed: isLoading ? null : loginLogic,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
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

// 2. CRITICAL FIX: Register form validator syntax errors
  Widget _buildRegisterForm() {
    return Form(
      key: registerFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: registerNameController,
            decoration: InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.person_outline),
            ),
            validator: (value) {
              // FIX: Changed from "value.trim().isEmpty" to "|| value.trim().isEmpty"


              if (value == null || value.trim().isEmpty) {
              return 'Please enter your full name';
              }
              if (value.trim().length < 2) {
              return 'Name must be at least 2 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: registerEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            validator: (value) {
              // FIX: Changed from "value.isEmpty" to "|| value.isEmpty"
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: registerPhoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.phone_outlined),
            ),
            validator: (value) {
              // FIX: Changed from "value.trim().isEmpty" to "|| value.trim().isEmpty"
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your phone number';
              }
              if (value.trim().length < 10) {
                return 'Please enter a valid phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: registerCompanyNameController,
            decoration: InputDecoration(
              labelText: 'Company Name',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.business_outlined),
            ),
            validator: (value) {
              // FIX: Changed from "value.trim().isEmpty" to "|| value.trim().isEmpty"
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your company name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: registerFieldController,
            decoration: InputDecoration(
              labelText: 'Field/Industry',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.work_outline),
            ),
            validator: (value) {
              // FIX: Changed from "value.trim().isEmpty" to "|| value.trim().isEmpty"
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your field/industry';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: registerPasswordController,
            obscureText: obscureRegisterPassword,
            decoration: InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureRegisterPassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() => obscureRegisterPassword = !obscureRegisterPassword);

                },
              ),
            ),
            validator: (value) {
              // FIX: Changed from "value.isEmpty" to "|| value.isEmpty"
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: registerConfirmPasswordController,
            obscureText: obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() => obscureConfirmPassword = !obscureConfirmPassword);
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != registerPasswordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Register Button
          ElevatedButton(
            onPressed: isLoading ? null : registerLogic,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: isLoading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
                : const Text('Create Account', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _clearRegisterForm() {
    registerNameController.clear();
    registerEmailController.clear();
    registerPasswordController.clear();
    registerConfirmPasswordController.clear();
    registerCompanyNameController.clear();
    registerFieldController.clear();
    registerPhoneController.clear();
  }
}
