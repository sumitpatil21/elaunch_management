import 'package:elaunch_management/employee/employee_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Department/department_bloc.dart';

import '../Service/department_modal.dart';
import '../SuperAdminLogin/admin_bloc.dart';
import '../SuperAdminLogin/admin_event.dart';
import '../SuperAdminLogin/admin_state.dart';

import '../service/employee_modal.dart';

class EmployeeScreen extends StatefulWidget {
  static String routeName = "/emp";

  const EmployeeScreen({super.key});

  static Widget builder(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => EmployeeBloc()..add(FetchEmployees()),
        ),
        BlocProvider(create: (_) => DepartmentBloc()..add(FetchDepartments())),
        BlocProvider(create: (_) => AdminBloc()..add(AdminFetch())),
      ],
      child: const EmployeeScreen(),
    );
  }

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<EmployeeBloc>().add(FetchEmployees());
    context.read<DepartmentBloc>().add(FetchDepartments());
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void clearAllFilters() {
    context.read<EmployeeBloc>().add(const ResetEmployeeFilters());
    context.read<EmployeeBloc>().add(const ClearSearch());
    searchController.clear();
  }

  void showFilterBottomSheet() {
    final departments = context.read<DepartmentBloc>().state.departments;
    final employeeState = context.read<EmployeeBloc>().state;
    final managers =
        employeeState.employees.where((emp) => emp.role == 'Manager').toList();

    String tempRoleFilter = employeeState.roleFilter ?? 'All';
    String? tempDepartmentFilter = employeeState.departmentFilter;
    String? tempManagerFilter = employeeState.managerFilter;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (modalContext) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Employees',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Role Filter
                  const Text(
                    'Role',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: tempRoleFilter,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    items:
                        ['All', 'Employee', 'Manager', 'HR']
                            .map(
                              (role) => DropdownMenuItem(
                                value: role,
                                child: Text(role),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      tempRoleFilter = value ?? 'All';
                    },
                  ),
                  const SizedBox(height: 16),

                  // Department Filter
                  const Text(
                    'Department',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: tempDepartmentFilter,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      hintText: 'Select Department',
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('All Departments'),
                      ),
                      ...departments.map(
                        (dept) => DropdownMenuItem(
                          value: dept.id,
                          child: Text(dept.name),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      tempDepartmentFilter = value;
                    },
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Manager',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: tempManagerFilter,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      hintText: 'Select Manager',
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('All Managers'),
                      ),
                      ...managers.map(
                        (manager) => DropdownMenuItem(
                          value: manager.id,
                          child: Text(manager.name),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      tempManagerFilter = value;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Apply Button
                  ElevatedButton(
                    onPressed: () {
                      context.read<EmployeeBloc>().add(
                        FilterEmployeesByRole(role: tempRoleFilter),
                      );
                      context.read<EmployeeBloc>().add(
                        FilterEmployeesByDepartment(
                          department: tempDepartmentFilter,
                        ),
                      );
                      context.read<EmployeeBloc>().add(
                        FilterEmployeesByManager(manager: tempManagerFilter),
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Reset Button
                  OutlinedButton(
                    onPressed: () {
                      context.read<EmployeeBloc>().add(
                        const ResetEmployeeFilters(),
                      );
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: const BorderSide(color: Colors.blue),
                    ),
                    child: const Text(
                      'Reset All',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isWeb = screenSize.width > 800;
    SelectRole user = ModalRoute.of(context)?.settings.arguments as SelectRole;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red.withOpacity(0.2),
        elevation: 2,
        title: Text(
          "Employees",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isWeb ? 22 : 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, size: isWeb ? 28 : 24),
            onPressed: showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(isWeb ? 24 : 16),
            child: BlocBuilder<EmployeeBloc, EmployeeState>(
              builder: (context, state) {
                return TextField(
                  controller: searchController,
                  onChanged: (value) {
                    context.read<EmployeeBloc>().add(
                      UpdateSearchQuery(value, state.employees),
                    );
                  },
                  decoration: InputDecoration(
                    hintText: 'Search employees...',
                    hintStyle: TextStyle(fontSize: isWeb ? 16 : 14),
                    prefixIcon: Icon(Icons.search, size: isWeb ? 28 : 24),
                    suffixIcon:
                        state.searchQuery.isNotEmpty
                            ? IconButton(
                              icon: Icon(Icons.clear, size: isWeb ? 28 : 24),
                              onPressed: () {
                                searchController.clear();
                                context.read<EmployeeBloc>().add(
                                  const ClearSearch(),
                                );
                              },
                            )
                            : null,
                    filled: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isWeb ? 20 : 16,
                      vertical: isWeb ? 16 : 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red, width: 1),
                    ),
                  ),
                  style: TextStyle(fontSize: isWeb ? 16 : 14),
                );
              },
            ),
          ),

          // Employee List
          Expanded(
            child: BlocBuilder<EmployeeBloc, EmployeeState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.employees.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: isWeb ? 80 : 64,
                          color: Colors.grey,
                        ),

                        SizedBox(height: isWeb ? 24 : 16),
                        Text(
                          "No employees found",
                          style: TextStyle(
                            fontSize: isWeb ? 20 : 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: isWeb ? 12 : 8),
                        Text(
                          "Add some employees to get started",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: isWeb ? 16 : 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final displayEmployees = state.employees;
                if (state.employees.isEmpty) {
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.filter_list_off,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.employees.isEmpty
                            ? 'No employees found'
                            : 'No employees match your filters',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.employees.isEmpty
                            ? 'Add some employees to get started'
                            : 'Try adjusting your filters',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      if (state.employees.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<EmployeeBloc>().add(
                              const ResetEmployeeFilters(),
                            );
                            searchController.clear();
                          },
                          child: const Text('Clear All Filters'),
                        ),
                      ],
                    ],
                  );
                }

                return isWeb
                    ? webLayout(displayEmployees, context,user)
                    : mobileLayout(displayEmployees, context,user);
              },
            ),
          ),
        ],
      ),

      floatingActionButton: isAdmin(user)?FloatingActionButton.extended(
        backgroundColor: Colors.red.withOpacity(0.2),
        onPressed: () {
          showDialog(
            context: context,
            builder:
                (dialogContext) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: context.read<EmployeeBloc>()),
                    BlocProvider.value(value: context.read<DepartmentBloc>()),
                    BlocProvider.value(value: context.read<AdminBloc>()),
                  ],
                  child: BlocBuilder<AdminBloc, AdminState>(
                    builder: (context, adminState) {
                      return EmployeeDialog();
                    },
                  ),
                ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Employee"),
      ):null,
    );
  }
}

Widget mobileLayout(List<EmployeeModal> employees, BuildContext context,SelectRole user) {
  return ListView.separated(
    padding: const EdgeInsets.all(16),
    itemCount: employees.length,
    separatorBuilder: (_, __) => const SizedBox(height: 8),
    itemBuilder: (context, index) {
      final employee = employees[index];
      return employeeCard(employee, false, context,user);
    },
  );
}

Widget webLayout(List<EmployeeModal> employees, BuildContext context,SelectRole user) {
  return GridView.builder(
    padding: const EdgeInsets.all(24),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: 3,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
    ),
    itemCount: employees.length,
    itemBuilder: (context, index) {
      final employee = employees[index];
      return employeeCard(employee, true, context,user);
    },
  );
}

Widget employeeCard(EmployeeModal employee, bool isWeb, BuildContext context,SelectRole user) {
  return Dismissible(
    key: Key(employee.id.toString()),
    background: Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: Colors.red.shade700,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.delete, color: Colors.white, size: isWeb ? 32 : 24),
    ),
    confirmDismiss:
        (_) => showDialog<bool>(
          context: context,
          builder:
              (_) => AlertDialog(
                title: Text(
                  "Confirm Delete",
                  style: TextStyle(fontSize: isWeb ? 20 : 18),
                ),
                content: Text(
                  "Are you sure you want to delete ${employee.name}?",
                  style: TextStyle(fontSize: isWeb ? 16 : 14),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(
                      "CANCEL",
                      style: TextStyle(fontSize: isWeb ? 16 : 14),
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(
                      "DELETE",
                      style: TextStyle(fontSize: isWeb ? 16 : 14),
                    ),
                  ),
                ],
              ),
        ),
    onDismissed: (_) {
      context.read<EmployeeBloc>().add(DeleteEmployee(id: employee.id));
    },
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isWeb ? 20 : 16,
          vertical: isWeb ? 12 : 8,
        ),
        leading: CircleAvatar(
          backgroundColor: Colors.red.withOpacity(0.2),
          radius: isWeb ? 28 : 24,
          child: Text(
            employee.role.substring(0, 1).toUpperCase(),
            style: TextStyle(
              fontSize: isWeb ? 20 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          employee.name,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: isWeb ? 18 : 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(employee.email, style: TextStyle(fontSize: isWeb ? 14 : 12)),
            Text(
              'Dept: ${employee.departmentName}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: isWeb ? 12 : 10,
              ),
            ),
            if (employee.managerName.isNotEmpty)
              Text(
                'Manager: ${employee.managerName}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: isWeb ? 12 : 10,
                ),
              ),
          ],
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isWeb ? 12 : 8,
            vertical: isWeb ? 6 : 4,
          ),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            employee.role,
            style: TextStyle(
              color: Colors.red.shade700,
              fontWeight: FontWeight.w500,
              fontSize: isWeb ? 14 : 12,
            ),
          ),
        ),
        onTap: () {
          if(isAdmin(user)) {
            showDialog(
            context: context,
            builder:
                (dialogContext) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: context.read<EmployeeBloc>()),
                    BlocProvider.value(value: context.read<DepartmentBloc>()),
                    BlocProvider.value(value: context.read<AdminBloc>()),
                  ],
                  child: BlocBuilder<AdminBloc, AdminState>(
                    builder: (context, adminState) {
                      return EmployeeDialog(
                        employee: employee,
                        // args: SelectRole(adminModal: adminState.admin),
                      );
                    },
                  ),
                ),
          );
          }
        },
      ),
    ),
  );
}

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
  void didChangeDependencies() {
    super.didChangeDependencies();

    final departments = context.read<DepartmentBloc>().state.departments;
    final managers =
        context
            .read<EmployeeBloc>()
            .state
            .employees
            .where((emp) => emp.role == 'Manager')
            .toList();

    if (widget.employee != null) {
      if (widget.employee!.departmentName.isNotEmpty &&
          departments.isNotEmpty) {
        try {
          selectedDepartment = departments.firstWhere(
            (dept) => dept.name == widget.employee!.departmentName,
          );
        } catch (e) {
          selectedDepartment =
              departments.isNotEmpty ? departments.first : null;
        }
      }

      if (widget.employee!.managerName.isNotEmpty && managers.isNotEmpty) {
        try {
          selectedManager = managers.firstWhere(
            (manager) => manager.name == widget.employee!.managerName,
          );
        } catch (e) {
          selectedManager = null;
        }
      }
    } else {
      selectedDepartment = departments.isNotEmpty ? departments.first : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DepartmentBloc, DepartmentState>(
      builder: (context, departmentState) {
        return BlocBuilder<EmployeeBloc, EmployeeState>(
          builder: (context, employeeState) {
            final departments = departmentState.departments;
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
            managerName: selectedManager?.name,
            managerId: selectedManager?.id,
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
            managerId: selectedManager?.id,
            managerName: selectedManager?.name,
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
bool isAdmin(SelectRole? user) {
  if (user == null) return false;
  return user.selectedRole == "Admin" && user.adminModal != null;
}