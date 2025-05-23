import 'package:elaunch_management/Dashboard/dashboard_view.dart';
import 'package:elaunch_management/SuperAdminLogin/admin_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminView extends StatefulWidget {
  static String routeName = "/admin";
  const AdminView({super.key});

  static Widget builder(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminBloc(),
      child: AdminView(),
    );
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

  @override
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLogin ? 'Super Admin Login' : 'Super Admin Register'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLogin ? 'Welcome Back!' : 'Register Now!',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  if (!isLogin)
                    TextFormField(
                      keyboardType: TextInputType.numberWithOptions(),
                      decoration: InputDecoration(
                        labelText: 'User ID',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.perm_identity),
                      ),
                      controller: idController,
                    ),
                    SizedBox(height: 20),
                  if (!isLogin)
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      controller: nameController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    controller: emailController,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.visibility),
                      ),
                    ),
                    validator: (value) {
                      if (!isLogin && value!.isEmpty) {
                        return 'Please enter your field';
                      }
                      return null;
                    },
                    controller: passwordController,
                  ),
                  SizedBox(height: 20),
                  !isLogin
                      ? TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Company Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.business),
                        ),
                        controller: companyController,
                      )
                      : SizedBox(height: 20),

                  SizedBox(height: 20),

                  !isLogin
                      ? TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Field',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.work),
                        ),
                        controller: fieldController,
                      )
                      : SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        if (isLogin) {
                          context.read<AdminBloc>().add(
                            AdminLogin(
                              email: emailController.text,
                              check: "isLogin",
                            ),
                          );
                          context.read<AdminBloc>().stream.listen((state) {
                            if (state.adminList.isNotEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Login Done")),
                              );
                              Navigator.of(context).pushReplacementNamed(
                                DashboardView.routeName,
                                arguments: state.adminList.first,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Login fail")),
                              );
                            }
                          });
                        } else {
                          context.read<AdminBloc>().add(
                            AdminInsert(
                              id: int.parse(idController.text),
                              name: nameController.text,
                              email: emailController.text,
                              pass: passwordController.text,
                              check: "Logout",
                              companyName: companyController.text,
                              field: fieldController.text,
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Registered Successfully")),
                          );
                          setState(() {
                            nameController.clear();
                            emailController.clear();
                            passwordController.clear();
                            companyController.clear();
                            fieldController.clear();
                            isLogin = true;
                          });
                        }
                      }
                    },
                    child: Text(isLogin ? 'Login' : 'Register'),
                  ),

                  TextButton(
                    onPressed: () {
                      setState(() {
                        isLogin = !isLogin;
                      });
                    },
                    child: Text(
                      isLogin
                          ? 'Don\'t have an account? Register'
                          : 'Already have an account? Login',
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
}
