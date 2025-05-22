import 'dart:developer';


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../Manager/manager_bloc.dart';
import '../Manager/manager_view.dart';
import '../Service/admin_modal.dart';
import '../Service/department_modal.dart';
import 'department_bloc.dart';

class DepartmentScreen extends StatefulWidget {
  static const routeName = "/dept";
  const DepartmentScreen({super.key});

  static Widget builder(BuildContext context) {
    late AdminModal admin =
        ModalRoute.of(context)!.settings.arguments as AdminModal;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (_) =>
                  DepartmentBloc(DepartmentState())
                    ..add(FetchDepartments(adminId: admin.id)),
        ),
      ],
      child: const DepartmentScreen(),
    );
  }

  @override
  State<DepartmentScreen> createState() => _DepartmentScreenState();
}

class _DepartmentScreenState extends State<DepartmentScreen> {
  @override
  void initState() {
    super.initState();
    // TODO: implement initState
    context.read<DepartmentBloc>().add(NetworkDepartment(connect: false));
  }
  @override
  Widget build(BuildContext context) {
    late AdminModal admin =
        ModalRoute.of(context)!.settings.arguments as AdminModal;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.withOpacity(0.2),
        title: const Text("Departments"),
      ),
      body: BlocBuilder<DepartmentBloc, DepartmentState>(
        builder: (context, state) {
          if (state.departments.isEmpty) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            log("${state.connect}");
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.departments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final dept = state.departments[index];
                return Dismissible(
                  key: Key(dept.id.toString()),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Confirm"),
                          content: Text(
                            "Are you sure you want to delete ${dept.name}?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text(
                                "Delete",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (_) {
                    context.read<DepartmentBloc>().add(
                      DeleteDepartment(id: dept.id, adminId: admin.id),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${dept.name} deleted")),
                    );
                  },

                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.withOpacity(0.2),
                        child: Icon(Icons.business, size: 16),
                      ),
                      title: Text(
                        state.departments[index].name,
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              _showDepartmentDialog(dept: state.departments[index]);

                            },
                            icon: Icon(Icons.edit),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                ManagerScreen.routeName,
                                arguments: ManagerScreenArguments(adminId: state.departments[index].id_admin, departmentId:state.departments[index].id,department: state.departments[index],departmentList: state.departments),
                              );

                            },
                            icon: Icon(Icons.arrow_forward_ios_rounded),
                          ),
                        ],
                      ),
                      subtitle: Text('Department'),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.withOpacity(0.2),
        onPressed: () => _showDepartmentDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDepartmentDialog({DepartmentModal? dept}) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == null || args is! AdminModal) return;
    final admin = args;

    final _formKey = GlobalKey<FormState>();
    final TextEditingController nameController = TextEditingController(text: dept?.name ?? '');
    final TextEditingController dobController = TextEditingController(text: dept?.date ?? '');

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(dept != null ? 'Edit Department' : 'Add Department'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Please enter a department name' : null,
                  decoration: const InputDecoration(
                    labelText: "Department Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: dobController,
                  decoration: const InputDecoration(
                    labelText: "Department Field or Date",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text(dept != null ? "Update" : "Add"),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  if (dept != null) {
                    context.read<DepartmentBloc>().add(
                      UpdateDepartment(
                        id: dept.id,
                        departmentName: nameController.text,
                        dob: dobController.text,
                        adminId: admin.id,
                      ),
                    );
                  } else {
                    context.read<DepartmentBloc>().add(
                      AddDepartment(
                        departmentName: nameController.text,
                        dob: dobController.text,
                        id: admin.id??1,
                      ),
                    );
                  }
                  Navigator.pop(context);
                  context.read<DepartmentBloc>().add(FetchDepartments(adminId: admin.id));
                }
              },
            ),
          ],
        );
      },
    );
  }

}
