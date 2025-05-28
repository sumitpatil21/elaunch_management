import 'package:elaunch_management/Dashboard/dashboard_view.dart';
import 'package:elaunch_management/SuperAdminLogin/admin_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminView extends StatefulWidget {
  static String routeName = "/admin";
  const AdminView({super.key});

  static Widget builder(BuildContext context) {
    return BlocProvider(create: (context) => AdminBloc(), child: AdminView());
  }

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final companyController = TextEditingController();
  final fieldController = TextEditingController();
  final idController = TextEditingController();
  bool isLogin = true;
  bool passwordVisible = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    companyController.dispose();
    fieldController.dispose();
    idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLogin ? 'Super Admin Login' : 'Super Admin Register'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLogin ? 'Welcome Back!' : 'Register Now!',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 30),

                  if (!isLogin) ...[
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'User ID',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.perm_identity),
                      ),
                      controller: idController,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter user ID';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      controller: nameController,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                  ],

                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    controller: emailController,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter email';
                      }

                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  TextFormField(
                    obscureText: !passwordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            passwordVisible = !passwordVisible;
                          });
                        },
                        icon: Icon(
                          passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                    ),
                    controller: passwordController,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter password';
                      }
                      if (!isLogin && value!.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  if (!isLogin) ...[
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Company Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business),
                      ),
                      controller: companyController,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter company name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Field',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.work),
                      ),
                      controller: fieldController,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter field';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                  ],

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          if (isLogin) {
                            context.read<AdminBloc>().add(
                              AdminLogin(
                                email: emailController.text,
                                password: passwordController.text,
                              ),
                            );
                            await Future.delayed(Duration(milliseconds: 500));


                              final adminState =
                                  context.read<AdminBloc>().state;
                              if (adminState.adminList?.isNotEmpty ?? false) {
                                Navigator.of(context).pushReplacementNamed(
                                  DashboardView.routeName,
                                  arguments: adminState.adminList!.first,
                                );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Invalid email or password"),
                                  ),
                                );

                            }
                          } else {
                            context.read<AdminBloc>().add(
                              AdminInsert(
                                id: idController.text,
                                name: nameController.text.trim(),
                                email: emailController.text.trim(),
                                pass: passwordController.text,
                                companyName: companyController.text.trim(),
                                field: fieldController.text.trim(),
                                check: "isLogout",
                              ),
                            );

                            await Future.delayed(Duration(milliseconds: 500));

                            if (mounted) {
                              final adminState =
                                  context.read<AdminBloc>().state;
                              if (adminState.adminList?.isNotEmpty ?? false) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Registered Successfully"),
                                  ),
                                );
                                _clearFields();
                                setState(() {
                                  isLogin = true;
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Registration failed"),
                                  ),
                                );
                              }
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: Text(
                        isLogin ? 'Login' : 'Register',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  TextButton(
                    onPressed: () {
                      _clearFields();
                      setState(() {
                        isLogin = !isLogin;
                      });
                    },
                    child: Text(
                      isLogin
                          ? 'Don\'t have an account? Register'
                          : 'Already have an account? Login',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _clearFields() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    companyController.clear();
    fieldController.clear();
    idController.clear();
  }
}
