import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Department/department_bloc.dart';
import '../Employee/employee_bloc.dart';
import '../Employee/employee_event.dart';
import '../Employee/employee_state.dart';
import '../Service/department_modal.dart';
import '../SuperAdminLogin/admin_event.dart';
import '../service/employee_modal.dart';

class EmployeeDialog extends StatefulWidget {
  static String routeName = "/emp_dialog";
  final EmployeeModal? employee;
  final SelectRole? args;

  const EmployeeDialog({super.key, this.employee, this.args});

  @override
  State<EmployeeDialog> createState() => _EmployeeDialogState();
}

class _EmployeeDialogState extends State<EmployeeDialog> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController addressController;
  late TextEditingController idController;

  String selectedRole = 'Employee';
  DepartmentModal? selectedDepartment;
  EmployeeModal? selectedManager;

  @override
  void initState() {
    super.initState();
    final employee = widget.employee;
    nameController = TextEditingController(text: employee?.name ?? '');
    emailController = TextEditingController(text: employee?.email ?? '');
    passwordController = TextEditingController(text: employee?.password ?? '');
    addressController = TextEditingController(text: employee?.address ?? '');
    idController = TextEditingController(text: employee?.id ?? '');
    selectedRole = employee?.role ?? 'Employee';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmployeeBloc, EmployeeState>(
      builder: (context, employeeState) {
        final departments = context.read<DepartmentBloc>().state.departments;
        final managers =
        employeeState.employees
            .where((emp) => emp.role == 'Manager')
            .toList();

        return AlertDialog(
          title: Text(
            widget.employee != null ? 'Edit Employee' : 'Add Employee',
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person),

                      border: OutlineInputBorder(),
                    ),
                    validator:
                        (val) =>
                    val == null || val.isEmpty
                        ? 'Enter name'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    validator:
                        (val) =>
                    val == null || val.isEmpty
                        ? 'Enter email'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                    validator:
                        (val) =>
                    val == null || val.isEmpty
                        ? 'Enter password'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(
                      labelText: "Employee Role",
                      border: OutlineInputBorder(),
                    ),
                    items:
                    ['Employee', 'Manager', 'Human Resource']
                        .map(
                          (role) => DropdownMenuItem(
                        value: role,
                        child: Text(role),
                      ),
                    )
                        .toList(),
                    onChanged: (value) {
                      selectedRole = value ?? 'Employee';
                      if (selectedRole != 'Employee') {
                        selectedManager = null;
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<DepartmentModal>(
                    value: selectedDepartment,
                    decoration: const InputDecoration(
                      labelText: "Select Department",
                      border: OutlineInputBorder(),
                    ),
                    items:
                    departments
                        .map(
                          (dept) => DropdownMenuItem(
                        value: dept,
                        child: Text(dept.name),
                      ),
                    )
                        .toList(),
                    onChanged: (value) {
                      selectedDepartment = value;
                    },
                    validator:
                        (value) =>
                    value == null
                        ? 'Please select a department'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  if (selectedRole == 'Employee' && managers.isNotEmpty)
                    DropdownButtonFormField<EmployeeModal>(
                      value: selectedManager,
                      decoration: const InputDecoration(
                        labelText: "Select Manager (Optional)",
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<EmployeeModal>(
                          value: null,
                          child: Text('No Manager'),
                        ),
                        ...managers.map(
                              (manager) => DropdownMenuItem(
                            value: manager,
                            child: Text(manager.name),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        selectedManager = value;
                      },
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            ElevatedButton.icon(
              icon: Icon(widget.employee != null ? Icons.save : Icons.add),
              label: Text(widget.employee != null ? 'UPDATE' : 'ADD'),
              onPressed: submitForm,
            ),
          ],
        );
      },
    );
  }

  void submitForm() {
    if (formKey.currentState!.validate()) {
      final employeeBloc = context.read<EmployeeBloc>();

      if (widget.employee != null) {
        employeeBloc.add(
          UpdateEmployee(
            adminId: widget.args?.adminModal?.id,
            id: widget.employee!.id,
            role: selectedRole,
            name: nameController.text.trim(),
            email: emailController.text.trim(),
            password: passwordController.text,
            address: addressController.text.trim(),
            departmentId: selectedDepartment?.id ?? "",
            departmentName: selectedDepartment?.name,
            managerName: selectedManager?.name??"",
            managerId: selectedManager?.id??"",
          ),
        );
      } else {
        employeeBloc.add(
          AddEmployee(
            adminId: widget.args?.adminModal?.id,
            id:
            idController.text.trim().isEmpty
                ? DateTime.now().millisecondsSinceEpoch.toString()
                : idController.text.trim(),
            role: selectedRole,
            name: nameController.text.trim(),
            email: emailController.text.trim(),
            password: passwordController.text,
            address: addressController.text.trim(),
            departmentId: selectedDepartment?.id ?? "",
            departmentName: selectedDepartment?.name,
            managerId: selectedManager?.id??"",
            managerName: selectedManager?.name??"",
          ),
        );
      }
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    addressController.dispose();
    idController.dispose();
    super.dispose();
  }
}
