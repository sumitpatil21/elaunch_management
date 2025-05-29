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
  bool isLoading = false;



  void clearText() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    companyController.clear();
    fieldController.clear();
    idController.clear();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminBloc, AdminState>(
      listener: (context, state) {
        setState(() {
          isLoading = false;
        });

        if (state.adminList?.isNotEmpty == true) {
          if (state.isLogin) {
            Navigator.of(context).pushReplacementNamed(
              DashboardView.routeName,
              arguments: state.adminList!.first,
            );
          } else {
            _showSnackBar("Registered Successfully");
            clearText();
            context.read<AdminBloc>().add(AdminLoginCheck(isLogin: true));
          }
        } else if (state.adminList?.isEmpty == true && isLoading == false) {
          _showSnackBar(
            state.isLogin ? "Invalid email or password" : "Registration failed",
            isError: true,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              state.isLogin ? 'Super Admin Login' : 'Super Admin Register',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.blue[600],
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  constraints: BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(

                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),

                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            state.isLogin ? Icons.login : Icons.person_add,
                            size: 64,
                            color: Colors.blue[600],
                          ),
                          SizedBox(height: 16),
                          Text(
                            state.isLogin ? 'Welcome Back!' : 'Create Account',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),

                          SizedBox(height: 32),

                          if (!state.isLogin) ...[
                            TextFormField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'User ID',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: Icon(
                                  Icons.perm_identity,
                                  color: Colors.blue[600],
                                ),
                                filled: true,

                              ),
                              controller: idController,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Please enter user ID';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),

                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Full Name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: Colors.blue[600],
                                ),
                                filled: true,
                              ),
                              controller: nameController,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),
                          ],

                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: Icon(
                                Icons.email,
                                color: Colors.blue[600],
                              ),
                              filled: true,

                            ),
                            controller: emailController,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter email';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),

                          TextFormField(

                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Colors.blue[600],
                              ),
                              filled: true,
                            ),
                            controller: passwordController,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter password';
                              }
                              if (!state.isLogin && value!.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),

                          if (!state.isLogin) ...[
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Company Name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: Icon(
                                  Icons.business,
                                  color: Colors.blue[600],
                                ),
                                filled: true,

                              ),
                              controller: companyController,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Please enter company name';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),

                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Field/Industry',

                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: Icon(
                                  Icons.work,
                                  color: Colors.blue[600],
                                ),
                                filled: true,

                              ),
                              controller: fieldController,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Please enter field';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 24),
                          ] else ...[
                            SizedBox(height: 8),
                          ],

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed:
                                  isLoading
                                      ? null
                                      : () async {
                                        if (formKey.currentState!.validate()) {
                                          setState(() {
                                            isLoading = true;
                                          });

                                          if (state.isLogin) {
                                            context.read<AdminBloc>().add(
                                              AdminLogin(
                                                email:
                                                    emailController.text.trim(),
                                                password:
                                                    passwordController.text,
                                              ),
                                            );
                                          } else {
                                            context.read<AdminBloc>().add(
                                              AdminInsert(
                                                id: idController.text.trim(),
                                                name:
                                                    nameController.text.trim(),
                                                email:
                                                    emailController.text.trim(),
                                                pass: passwordController.text,
                                                companyName:
                                                    companyController.text
                                                        .trim(),
                                                field:
                                                    fieldController.text.trim(),
                                                check: "isLogout",
                                              ),
                                            );
                                          }
                                        }
                                      },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[600],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child:
                                  isLoading
                                      ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                      : Text(
                                        state.isLogin
                                            ? 'Sign In'
                                            : 'Create Account',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                            ),
                          ),
                          SizedBox(height: 24),

                          TextButton(
                            onPressed:
                                isLoading
                                    ? null
                                    : () {
                                      clearText();
                                      context.read<AdminBloc>().add(
                                        AdminLoginCheck(
                                          isLogin: !state.isLogin,
                                        ),
                                      );
                                    },
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                                children: [
                                  TextSpan(
                                    text:
                                        state.isLogin
                                            ? 'Don\'t have an account? '
                                            : 'Already have an account? ',
                                  ),
                                  TextSpan(
                                    text:
                                        state.isLogin ? 'Register' : 'Sign In',
                                    style: TextStyle(
                                      color: Colors.blue[600],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
