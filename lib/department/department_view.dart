import 'package:elaunch_management/Employee/employee_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../Service/admin_modal.dart';
import '../Service/department_modal.dart';

import '../SuperAdminLogin/admin_event.dart';
import 'department_bloc.dart';

class DepartmentScreen extends StatefulWidget {
  static const routeName = "/dept";
  const DepartmentScreen({super.key});

  static Widget builder(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => DepartmentBloc()..add(FetchDepartments())),
      ],
      child: const DepartmentScreen(),
    );
  }

  @override
  State<DepartmentScreen> createState() => _DepartmentScreenState();
}

class _DepartmentScreenState extends State<DepartmentScreen> {
  @override
  Widget build(BuildContext context) {
    final SelectRole user =
        ModalRoute.of(context)?.settings.arguments as SelectRole;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.withOpacity(0.2),
        title: Text("Departments"),
        leading: Center(),
      ),
      body: BlocBuilder<DepartmentBloc, DepartmentState>(
        builder: (context, state) {
          if (state.departments.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          } else {
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
                    if (!isAdmin(user)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Only admins can delete departments"),
                        ),
                      );
                      return false;
                    }

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
                      DeleteDepartment(id: dept.id),
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
                        child: const Icon(Icons.business, size: 16),
                      ),
                      title: Text(
                        dept.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        'Department • ',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Only show edit button for admins
                          if (isAdmin(user))
                            IconButton(
                              onPressed:
                                  () => showDepartmentDialog(
                                    dept: dept,
                                    user: user,
                                  ),
                              icon: const Icon(Icons.edit),
                            ),
                          IconButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                EmployeeScreen.routeName,
                                arguments: user,
                              );
                            },
                            icon: const Icon(Icons.arrow_forward_ios_rounded),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      // Only show add button for admins
      floatingActionButton:
          isAdmin(user)
              ? FloatingActionButton(
                backgroundColor: Colors.blue.withOpacity(0.2),
                onPressed: () => showDepartmentDialog(user: user),
                child: const Icon(Icons.add),
              )
              : null,
    );
  }

  bool isAdmin(SelectRole? user) {
    if (user == null) return false;
    return user.selectedRole == "Admin" && user.adminModal != null;
  }

  String getUserTitle(SelectRole? user) {
    if (user == null) return " - Unknown User";

    if (isAdmin(user)) {
      return " - Admin (${user.adminModal!.name})";
    } else if (user.selectedRole == "Employee" && user.employeeModal != null) {
      return " - Employee (${user.employeeModal!.name})";
    }

    return " - ${user.selectedRole}";
  }

  void showDepartmentDialog({DepartmentModal? dept, SelectRole? user}) {
    if (!isAdmin(user)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Only admins can add or edit departments"),
        ),
      );
      return;
    }

    if (user!.adminModal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Admin information not available")),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    final TextEditingController nameController = TextEditingController(
      text: dept?.name ?? '',
    );
    final TextEditingController fieldController = TextEditingController(
      text: dept?.field ?? '',
    );
    final TextEditingController idController = TextEditingController(
      text: dept?.id.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(dept != null ? 'Edit Department' : 'Add Department'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (dept == null)
                  TextFormField(
                    controller: idController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a department ID';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: "Department ID",
                      border: OutlineInputBorder(),
                    ),
                  ),
                if (dept == null) const SizedBox(height: 12),
                TextFormField(
                  controller: nameController,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Please enter a department name'
                              : null,
                  decoration: const InputDecoration(
                    labelText: "Department Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: fieldController,
                  decoration: const InputDecoration(
                    labelText: "Department Field",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(dialogContext),
            ),
            ElevatedButton(
              child: Text(dept != null ? "Update" : "Add"),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  try {
                    if (dept != null) {
                      context.read<DepartmentBloc>().add(
                        UpdateDepartment(
                          departmentModal: DepartmentModal(
                            id: dept.id,
                            name: nameController.text.trim(),
                            field: fieldController.text.trim(),
                          ),
                        ),
                      );
                    } else {
                      final departmentId = int.tryParse(idController.text);
                      if (departmentId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Invalid department ID"),
                          ),
                        );
                        return;
                      }

                      context.read<DepartmentBloc>().add(
                        AddDepartment(
                          departmentName: nameController.text.trim(),
                          dob: fieldController.text.trim(),
                          id: departmentId,
                        ),
                      );
                    }

                    Navigator.pop(dialogContext);

                    context.read<DepartmentBloc>().add(FetchDepartments());

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          dept != null
                              ? "Department updated successfully"
                              : "Department added successfully",
                        ),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: ${e.toString()}")),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}
