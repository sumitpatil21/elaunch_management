

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Department/department_bloc.dart';
import '../Employee/employee_bloc.dart';
import '../Employee/employee_event.dart';
import '../Employee/employee_state.dart';
import '../Employee/employee_view.dart';
import '../Service/department_modal.dart';

import '../SuperAdminLogin/admin_bloc.dart';
import '../SuperAdminLogin/admin_event.dart';
import '../SuperAdminLogin/admin_state.dart';
import '../service/employee_modal.dart';
import 'employee_dialog.dart';

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
                  backgroundColor: Colors.red.withOpacity(0.2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child:  Text(
                  'Apply Filters',
                  style: TextStyle(
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
                  side:  BorderSide(color: Colors.red.withOpacity(0.2)),
                ),
                child: const Text(
                  'Reset All',
                  style: TextStyle(
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
                      UpdateSearchQuery(value),
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
                    ? webLayout(displayEmployees, context, user)
                    : mobileLayout(displayEmployees, context, user);
              },
            ),
          ),
        ],
      ),

      floatingActionButton:
          isAdmin(user)
              ? FloatingActionButton.extended(
                backgroundColor: Colors.red.withOpacity(0.2),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (dialogContext) => MultiBlocProvider(
                          providers: [
                            BlocProvider.value(
                              value: context.read<EmployeeBloc>(),
                            ),
                            BlocProvider.value(
                              value: context.read<DepartmentBloc>(),
                            ),
                            BlocProvider.value(
                              value: context.read<AdminBloc>(),
                            ),
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
              )
              : null,
    );
  }
}

Widget mobileLayout(
  List<EmployeeModal> employees,
  BuildContext context,
  SelectRole user,
) {
  return ListView.separated(
    padding: const EdgeInsets.all(16),
    itemCount: employees.length,
    separatorBuilder: (_, __) => const SizedBox(height: 8),
    itemBuilder: (context, index) {
      final employee = employees[index];
      return employeeCard(employee, false, context, user);
    },
  );
}

Widget webLayout(
  List<EmployeeModal> employees,
  BuildContext context,
  SelectRole user,
) {
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
      return employeeCard(employee, true, context, user);
    },
  );
}

Widget employeeCard(
  EmployeeModal employee,
  bool isWeb,
  BuildContext context,
  SelectRole user,
) {
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
          if (isAdmin(user)) {
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



bool isAdmin(SelectRole? user) {
  if (user == null) return false;
  return user.selectedRole == "Admin" && user.adminModal != null;
}