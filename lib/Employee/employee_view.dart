import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Dashboard/dashboard_bloc.dart';
import '../Department/department_bloc.dart';
import '../Manager/manager_bloc.dart';
import '../Employee/employee_bloc.dart';

import '../Service/manger_modal.dart';
import '../Service/employee_modal.dart';

class EmployeeScreen extends StatefulWidget {
  static String routeName = "/emp";
  const EmployeeScreen({super.key});

  static Widget builder(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final manager = args is MangerModal ? args : null;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) => EmployeeBloc(EmployeeState())..add(
                manager != null
                    ? FetchEmployees(
                      departmentId: manager.id  ,
                      managerName: manager.managerName,
                      departmentName: manager.departmentName,
                    )
                    : const FetchEmployees(),
              ),
        ),
        BlocProvider(
          create: (_) => ManagerBloc(ManagerState())..add(FetchManagers()),
        ),
        BlocProvider(
          create:
              (_) => DepartmentBloc(DepartmentState())..add(FetchDepartments()),
        ),
        BlocProvider(create: (context) => DashboardBloc(DashboardState())),
      ],
      child: const EmployeeScreen(),
    );
  }

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  int? currentDepartmentId;
  String? currentManagerName;
  String? currentDepartmentName;

  final TextEditingController searchController = TextEditingController();
  String searchText = '';

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {
        context.read<EmployeeBloc>().add(FetchEmployees(
          departmentId: currentDepartmentId,
          managerName: currentManagerName,
          departmentName: currentDepartmentName,
        ));
        searchText = searchController.text;
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _refreshData() {
    context.read<EmployeeBloc>().add(
      FetchEmployees(
        departmentId: currentDepartmentId,
        managerName: currentManagerName,
        departmentName: currentDepartmentName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final manager = args is MangerModal ? args : null;

    if (manager != null && currentDepartmentId == null) {
      currentDepartmentId = manager.id;
      currentManagerName = manager.managerName;
      currentDepartmentName = manager.departmentName;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red.withOpacity(0.2),
        elevation: 2,
        title: Text(
          currentManagerName != null
              ? "$currentManagerName's Team"
              : currentDepartmentName != null
              ? "$currentDepartmentName Employees"
              : "All Employees",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (manager != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list),
              tooltip: "Filter employees",
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: "department",
                      child: Text("Filter by Department"),
                    ),
                    const PopupMenuItem(
                      value: "manager",
                      child: Text("Filter by Manager"),
                    ),
                    const PopupMenuItem(
                      value: "reset",
                      child: Text("Reset Filters"),
                    ),
                  ],
              onSelected: (value) async {
                if (value == "reset") {
                  context.read<EmployeeBloc>().add(
                    FetchEmployees(
                      departmentId: manager.id,
                      managerName: manager.managerName,
                      departmentName: manager.departmentName,
                    ),
                  );
                  setState(() {
                    currentDepartmentId = manager.id;
                    currentManagerName = manager.managerName;
                    currentDepartmentName = manager.departmentName;
                  });
                  return;
                }

                var departments =
                    context.read<DepartmentBloc>().state.departments;
                var managers = context.read<ManagerBloc>().state.managers;

                if (value == "department" && departments.isNotEmpty) {
                  final selected = await showDialog<Map<String, dynamic>>(
                    context: context,
                    builder:
                        (_) => AlertDialog(
                          title: const Text("Select Department"),
                          content: SizedBox(
                            width: double.maxFinite,
                            height: 300,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: departments.length,
                              itemBuilder:
                                  (_, index) => ListTile(
                                    leading: const Icon(Icons.business),
                                    title: Text(departments[index].name),
                                    onTap:
                                        () => Navigator.pop(context, {
                                          'name': departments[index].name,
                                          'id': departments[index].id,
                                        }),
                                  ),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("CANCEL"),
                            ),
                          ],
                        ),
                  );

                  if (selected != null) {
                    context.read<EmployeeBloc>().add(
                      FetchEmployees(
                        departmentId: selected['id'],
                        departmentName: selected['name'],
                      ),
                    );
                    setState(() {
                      currentDepartmentId = selected['id'];
                      currentDepartmentName = selected['name'];
                      currentManagerName = null;
                    });
                  }
                } else if (value == "manager" && managers.isNotEmpty) {
                  final selected = await showDialog<Map<String, dynamic>>(
                    context: context,
                    builder:
                        (_) => AlertDialog(
                          title: const Text("Select Manager"),
                          content: SizedBox(
                            width: double.maxFinite,
                            height: 300,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: managers.length,
                              itemBuilder:
                                  (_, index) => ListTile(
                                    leading: const Icon(Icons.person),
                                    title: Text(managers[index].managerName),
                                    subtitle: Text(
                                      managers[index].departmentName ??
                                          'No Department',
                                    ),
                                    onTap:
                                        () => Navigator.pop(context, {
                                          'name': managers[index].managerName,
                                          'id': managers[index].id,
                                        }),
                                  ),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("CANCEL"),
                            ),
                          ],
                        ),
                  );

                  if (selected != null) {
                    context.read<EmployeeBloc>().add(
                      FetchEmployees(
                        departmentId: selected['id'],
                        managerName: selected['name'],
                      ),
                    );
                    setState(() {
                      currentManagerName = selected['name'];
                      currentDepartmentName = currentDepartmentName;
                    });
                  }
                }
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search employees...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    searchText.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => searchController.clear(),
                        )
                        : null,
                filled: true,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 1),
                ),
              ),
            ),
          ),

          // Active filters display
          if (currentManagerName != null || currentDepartmentName != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Text(
                    "Active filters: ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (currentDepartmentName != null)
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Chip(
                                label: Text(currentDepartmentName!),
                                avatar: const Icon(Icons.business, size: 16),
                                deleteIcon: const Icon(Icons.close, size: 16),
                                onDeleted: () {
                                  setState(() {
                                    currentDepartmentName = null;
                                    currentDepartmentId = null;
                                  });
                                  _refreshData();
                                },
                              ),
                            ),
                          if (currentManagerName != null)
                            Chip(
                              label: Text(currentManagerName!),
                              avatar: const Icon(Icons.person, size: 16),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () {
                                setState(() {
                                  currentManagerName = null;
                                });
                                _refreshData();
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Employee list
          Expanded(
            child: BlocBuilder<EmployeeBloc, EmployeeState>(
              builder: (context, state) {
                if (state.employees.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.supervised_user_circle,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "No employees found",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currentManagerName != null
                              ? "No employees under $currentManagerName"
                              : currentDepartmentName != null
                              ? "No employees in $currentDepartmentName"
                              : "Try adding some employees",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text("Refresh"),
                          onPressed: _refreshData,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Filter employees based on search text
                final filteredEmployees =
                    searchText.isEmpty
                        ? state.employees
                        : state.employees
                            .where(
                              (employee) =>
                                  employee.name.toLowerCase().contains(
                                    searchText.toLowerCase(),
                                  ) ||
                                  (employee.email.toLowerCase().contains(
                                        searchText.toLowerCase(),
                                      ) ??
                                      false) ||
                                  (employee.departmentName
                                          ?.toLowerCase()
                                          .contains(searchText.toLowerCase()) ??
                                      false) ||
                                  (employee.managerName?.toLowerCase().contains(
                                        searchText.toLowerCase(),
                                      ) ??
                                      false),
                            )
                            .toList();

                if (filteredEmployees.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No results for \"$searchText\"",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => searchController.clear(),
                          child: const Text("Clear Search"),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredEmployees.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final employee = filteredEmployees[index];

                    return Dismissible(
                      key: Key(employee.id.toString()),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.shade700,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.endToStart,
                      confirmDismiss:
                          (_) => showDialog(
                            context: context,
                            builder:
                                (_) => AlertDialog(
                                  title: const Text("Confirm Delete"),
                                  content: Text(
                                    "Are you sure you want to delete ${employee.name}?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, false),
                                      child: const Text("CANCEL"),
                                    ),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      onPressed:
                                          () => Navigator.pop(context, true),
                                      child: const Text("DELETE"),
                                    ),
                                  ],
                                ),
                          ),
                      onDismissed: (_) {
                        context.read<EmployeeBloc>().add(
                          DeleteEmployee(
                            id: employee.id!,
                            departmentId: currentDepartmentId,
                            managerName: currentManagerName,
                            departmentName: currentDepartmentName,
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("${employee.name} deleted"),
                            behavior: SnackBarBehavior.floating,
                            action: SnackBarAction(
                              label: "UNDO",
                              onPressed: () {
                                // Would need to implement undo functionality
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Undo feature not implemented",
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.red.withOpacity(0.2),
                            child: Text(
                              state.employees[index].name[0].toUpperCase(),
                            ),
                          ),
                          title: Text(
                            state.employees[index].name,
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text('Employee'),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.red.withOpacity(0.2),
        onPressed:
            () => showEmployeeDialog(
              context: context,
              manager: manager,
              bloc: context.read<EmployeeBloc>(),
              currentDepartmentId: currentDepartmentId,
              currentManagerName: currentManagerName,
              currentDepartmentName: currentDepartmentName,
            ),
        icon: const Icon(Icons.add),
        label: const Text("Add Employee"),
      ),
    );
  }
}

void showEmployeeDialog({
  required BuildContext context,
  MangerModal? manager,
  EmployeeBloc? bloc,
  EmployeeModal? employee,
  int? currentDepartmentId,
  String? currentManagerName,
  String? currentDepartmentName,
}) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: employee?.name ?? '');
  final emailController = TextEditingController(text: employee?.email ?? '');
  final addressController = TextEditingController(
    text: employee?.address ?? '',
  );
  final dobController = TextEditingController(text: employee?.dob ?? '');

  // Pick date function
  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.blue),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      dobController.text = "${picked.day}/${picked.month}/${picked.year}";
    }
  }

  showDialog(
    context: context,
    builder:
        (_) => AlertDialog(
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
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Enter email';
                      }

                    },
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
                  TextFormField(
                    controller: dobController,
                    decoration: InputDecoration(
                      labelText: 'Date of Birth',
                      prefixIcon: const Icon(Icons.calendar_today),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_month),
                        onPressed: () => pickDate(context),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () => pickDate(context),
                  ),
                  const SizedBox(height: 24),
                  if (manager != null ||
                      currentManagerName != null ||
                      currentDepartmentName != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Assignment Details",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Divider(),
                          if (currentManagerName != null ||
                              manager?.managerName != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  const Icon(Icons.person, size: 16),
                                  const SizedBox(width: 8),
                                  const Text("Manager:"),
                                  const SizedBox(width: 8),
                                  Text(
                                    currentManagerName ??
                                        manager?.managerName ??
                                        '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (currentDepartmentName != null ||
                              manager?.departmentName != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  const Icon(Icons.business, size: 16),
                                  const SizedBox(width: 8),
                                  const Text("Department:"),
                                  const SizedBox(width: 8),
                                  Text(
                                    currentDepartmentName ??
                                        manager?.departmentName ??
                                        '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
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
                  int managerId = manager?.id ?? 0;
                  int departmentId = currentDepartmentId ?? manager?.id ?? 0;
                  String managerName =
                      currentManagerName ?? manager?.managerName ?? '';
                  String departmentName =
                      currentDepartmentName ?? manager?.departmentName ?? '';

                  if (employee != null) {
                    bloc?.add(
                      UpdateEmployee(
                        id: employee.id!,
                        managerId: managerId,
                        departmentId: departmentId,
                        name: nameController.text,
                        email: emailController.text,
                        address: addressController.text,
                        dob: dobController.text,
                        managerName: managerName,
                        department: departmentName,
                      ),
                    );
                  } else {
                    bloc?.add(
                      AddEmployee(
                        id: 0,
                        managerId: managerId,
                        departmentId: departmentId,
                        name: nameController.text,
                        email: emailController.text,
                        address: addressController.text,
                        dob: dobController.text,
                        managerName: managerName,
                        department: departmentName,
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
