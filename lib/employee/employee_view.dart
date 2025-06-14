import 'package:elaunch_management/employee/employee_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Department/department_bloc.dart';

import '../Department/department_view.dart';
import '../Device_Testing/device_view.dart';

import '../Service/admin_modal.dart';
import '../Service/department_modal.dart';
import '../SuperAdminLogin/admin_bloc.dart';

import '../SuperAdminLogin/admin_event.dart';
import '../SuperAdminLogin/admin_view.dart';
import '../System/system_view.dart';
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
    context.read<EmployeeBloc>().add(FetchEmployees());
    context.read<DepartmentBloc>().add(FetchDepartments());
    super.initState();
  }

  void clearAllFilters() {
    context.read<EmployeeBloc>().add(const ResetEmployeeFilters());
    searchController.clear();
    setState(() {});
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
          (modalContext) => StatefulBuilder(
            builder:
                (builderContext, setModalState) => Container(
                  padding: const EdgeInsets.all(20),
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
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
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                tempDepartmentFilter = null;
                                tempManagerFilter = null;
                                tempRoleFilter = 'All';
                              });
                            },
                            child: const Text('Clear All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'Filter by Role:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: tempRoleFilter,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items:
                            ['All', 'Employee', 'Manager', 'Human Resource']
                                .map(
                                  (role) => DropdownMenuItem(
                                    value: role,
                                    child: Text(role),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setModalState(() {
                            tempRoleFilter = value ?? 'All';
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'Filter by Department:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: tempDepartmentFilter,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
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
                              value: dept.name,
                              child: Text(dept.name),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setModalState(() {
                            tempDepartmentFilter = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'Filter by Manager:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: tempManagerFilter,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
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
                              value: manager.name,
                              child: Text(manager.name),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setModalState(() {
                            tempManagerFilter = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      ElevatedButton(
                        onPressed: () {
                          context.read<EmployeeBloc>().add(
                            FilterEmployeesByRole(role: tempRoleFilter),
                          );

                          if (tempDepartmentFilter != null) {
                            context.read<EmployeeBloc>().add(
                              FilterEmployeesByDepartment(
                                department: tempDepartmentFilter ?? "",
                              ),
                            );
                          } else {
                            context.read<EmployeeBloc>().add(
                              FilterEmployeesByDepartment(department: null),
                            );
                          }

                          if (tempManagerFilter != null) {
                            context.read<EmployeeBloc>().add(
                              FilterEmployeesByManager(
                                manager: tempManagerFilter ?? "",
                              ),
                            );
                          } else {
                            context.read<EmployeeBloc>().add(
                              FilterEmployeesByManager(manager: null),
                            );
                          }

                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.withOpacity(0.8),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Apply Filters'),
                      ),

                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () {
                          context.read<EmployeeBloc>().add(
                            const ResetEmployeeFilters(),
                          );
                          Navigator.pop(context);
                        },
                        child: const Text('Reset All Filters'),
                      ),

                      SizedBox(
                        height: MediaQuery.of(context).viewInsets.bottom,
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  List<EmployeeModal> searchFilteredEmployee(List<EmployeeModal> employees) {
    final query = searchController.text.toLowerCase();

    if (query.isEmpty) return employees;

    return employees.where((employee) {
      return employee.name.toLowerCase().contains(query) ||
          employee.email.toLowerCase().contains(query) ||
          (employee.departmentName.toLowerCase().contains(query) ?? false) ||
          (employee.managerName.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  Drawer buildDrawer(BuildContext context, AdminModal? admin) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 800;
    SelectRole? args = ModalRoute.of(context)!.settings.arguments as SelectRole?;
    return Drawer(
      width: isWeb ? 300 : 240,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                context.read<EmployeeBloc>().state.loggedInEmployee == null
                    ? admin?.name[0].toUpperCase() ?? ""
                    : context
                        .read<EmployeeBloc>()
                        .state
                        .loggedInEmployee!
                        .name[0]
                        .toUpperCase(),
                style: TextStyle(
                  fontSize: isWeb ? 28 : 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            accountName: Text(
              context.read<EmployeeBloc>().state.loggedInEmployee == null
                  ? admin?.name ?? ""
                  : context.read<EmployeeBloc>().state.loggedInEmployee!.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isWeb ? 16 : 14,
              ),
            ),
            accountEmail: Text(
              context.read<EmployeeBloc>().state.loggedInEmployee == null
                  ? admin?.email ?? ""
                  : context.read<EmployeeBloc>().state.loggedInEmployee!.email,
              style: TextStyle(fontSize: isWeb ? 14 : 12),
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard, size: isWeb ? 28 : 24),
            title: Text(
              "Dashboard",
              style: TextStyle(fontSize: isWeb ? 18 : 16),
            ),
            selected: true,

            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.business, size: isWeb ? 28 : 24),
            title: Text(
              "Department",
              style: TextStyle(fontSize: isWeb ? 18 : 16),
            ),
            onTap: () {
              Navigator.pushNamed(context, DepartmentScreen.routeName,arguments: args);
            },
          ),
          ListTile(
            leading: Icon(Icons.group, size: isWeb ? 28 : 24),
            title: Text(
              "Employee",
              style: TextStyle(fontSize: isWeb ? 18 : 16),
            ),
            onTap: () {
              final dept = context.read<DepartmentBloc>().state.departments;
              Navigator.pushNamed(
                context,
                EmployeeScreen.routeName,
                arguments: dept.first,
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.phone_android_outlined, size: isWeb ? 28 : 24),
            title: Text("Device", style: TextStyle(fontSize: isWeb ? 18 : 16)),
            onTap: () {
              Navigator.pushNamed(context, DeviceView.routeName,arguments: args);
            },
          ),
          ListTile(
            leading: Icon(Icons.computer_outlined, size: isWeb ? 28 : 24),
            title: Text("System", style: TextStyle(fontSize: isWeb ? 18 : 16)),
            onTap: () {
              Navigator.pushNamed(context, SystemView.routeName,arguments: args);
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.logout,
              color: Colors.red,
              size: isWeb ? 28 : 24,
            ),
            title: Text(
              "Logout",
              style: TextStyle(color: Colors.red, fontSize: isWeb ? 18 : 16),
            ),
            onTap: () {
              context.read<AdminBloc>().add(AdminLogout());
              Navigator.of(context).pushNamed(AdminView.routeName);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isWeb = screenSize.width > 800;

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
      drawer: buildDrawer(context, null),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(isWeb ? 24 : 16),
            child: TextField(
              controller: searchController,
              onChanged: (value) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search employees...',
                hintStyle: TextStyle(fontSize: isWeb ? 16 : 14),
                prefixIcon: Icon(Icons.search, size: isWeb ? 28 : 24),
                suffixIcon:
                    searchController.text.isNotEmpty
                        ? IconButton(
                          icon: Icon(Icons.clear, size: isWeb ? 28 : 24),
                          onPressed: () {
                            searchController.clear();
                            setState(() {});
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
            ),
          ),
          Expanded(
            child: BlocBuilder<EmployeeBloc, EmployeeState>(
              builder: (context, state) {
                final searchFilteredEmployees = searchFilteredEmployee(
                  state.filteredEmployees,
                );

                if (state.employees.isEmpty) {
                  context.read<EmployeeBloc>().add(FetchEmployees());
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "No employees found",
                          style: TextStyle(
                            fontSize: isWeb ? 20 : 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: isWeb ? 24 : 16),
                        const CircularProgressIndicator(),
                      ],
                    ),
                  );
                }

                if (searchFilteredEmployees.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: isWeb ? 80 : 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: isWeb ? 24 : 16),
                        Text(
                          "No employees match your filters",
                          style: TextStyle(
                            fontSize: isWeb ? 20 : 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: isWeb ? 12 : 8),
                        Text(
                          "Try adjusting your search or filters",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: isWeb ? 16 : 14,
                          ),
                        ),
                        SizedBox(height: isWeb ? 24 : 16),
                        ElevatedButton.icon(
                          icon: Icon(Icons.clear, size: isWeb ? 24 : 20),
                          label: Text(
                            "Clear Filters",
                            style: TextStyle(fontSize: isWeb ? 16 : 14),
                          ),
                          onPressed: clearAllFilters,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: isWeb ? 24 : 16,
                              vertical: isWeb ? 16 : 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return isWeb
                    ? _buildWebLayout(searchFilteredEmployees, context)
                    : _buildMobileLayout(searchFilteredEmployees, context);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.red.withOpacity(0.2),
        onPressed: () {
          showEmployeeDialog(
            context: context,
            bloc: context.read<EmployeeBloc>(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Employee"),
      ),
    );
  }
}

void showEmployeeDialog({
  required BuildContext context,
  EmployeeBloc? bloc,
  EmployeeModal? employee,
}) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: employee?.name ?? '');
  final emailController = TextEditingController(text: employee?.email ?? '');
  final passwordController = TextEditingController(
    text: employee?.password ?? '',
  );
  final addressController = TextEditingController(
    text: employee?.address ?? '',
  );

  final idController = TextEditingController(text: employee?.id ?? '')
    ..text = employee?.id?.toString() ?? '';

  final departments = context.read<DepartmentBloc>().state.departments;
  final managers =
      context
          .read<EmployeeBloc>()
          .state
          .employees
          .where((emp) => emp.role == 'Manager')
          .toList();

  SelectRole? args = ModalRoute.of(context)!.settings.arguments as SelectRole?;
  String selectedRole = employee?.role ?? 'Employee';
  DepartmentModal? selectedDepartment;
  EmployeeModal? selectedManager;

  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text(employee != null ? 'Edit Employee' : 'Add Employee'),
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
                            val == null || val.isEmpty ? 'Enter name' : null,
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
                            val == null || val.isEmpty ? 'Enter email' : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.email),
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
                  ),
                  const SizedBox(height: 16),
                  if (selectedRole == 'Employee')
                    DropdownButtonFormField<EmployeeModal>(
                      value: selectedManager,
                      decoration: const InputDecoration(
                        labelText: "Select Manager",
                        border: OutlineInputBorder(),
                      ),
                      items:
                          managers
                              .map(
                                (manager) => DropdownMenuItem(
                                  value: manager,
                                  child: Text(manager.name),
                                ),
                              )
                              .toList(),
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
              icon: Icon(employee != null ? Icons.save : Icons.add),
              label: Text(employee != null ? 'UPDATE' : 'ADD'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  if (employee != null) {
                    bloc?.add(
                      UpdateEmployee(
                        adminId: args!.adminModal?.id,
                        id: employee.id!,
                        role: selectedRole,
                        name: nameController.text,
                        email: emailController.text,
                        password: passwordController.text,
                        address: addressController.text,

                        departmentId: selectedDepartment?.id ?? "",
                      ),
                    );
                  } else {
                    bloc?.add(
                      AddEmployee(
                        adminId: args!.adminModal?.id,
                        id: idController.text,
                        role: selectedRole,
                        name: nameController.text,
                        email: emailController.text,
                        password: passwordController.text,
                        address: addressController.text,
                        departmentId: selectedDepartment?.id ?? "",
                      ),
                    );
                  }
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
  );
}

Widget _buildMobileLayout(List<EmployeeModal> employees, BuildContext context) {
  return ListView.separated(
    padding: const EdgeInsets.all(16),
    itemCount: employees.length,
    separatorBuilder: (_, __) => const SizedBox(height: 8),
    itemBuilder: (context, index) {
      final employee = employees[index];
      return _buildEmployeeCard(employee, false, context);
    },
  );
}

Widget _buildWebLayout(List<EmployeeModal> employees, BuildContext context) {
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
      return _buildEmployeeCard(employee, true, context);
    },
  );
}

Widget _buildEmployeeCard(
  EmployeeModal employee,
  bool isWeb,
  BuildContext context,
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
            if (employee.departmentName != null)
              Text(
                'Dept: ${employee.departmentName}',
                style: TextStyle(
                  color: Colors.grey[600],

                  fontSize: isWeb ? 12 : 10,
                ),
              ),
            if (employee.managerName != null &&
                employee.managerName!.isNotEmpty)
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
      ),
    ),
  );
}
