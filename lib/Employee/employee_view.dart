import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Dashboard/dashboard_bloc.dart';
import '../Department/department_bloc.dart';
import '../Manager/manager_bloc.dart';
import '../Employee/employee_bloc.dart';

import '../Service/department_modal.dart';
import '../Service/manger_modal.dart';
import '../Service/employee_modal.dart';

class EmployeeScreen extends StatefulWidget {
  static String routeName = "/emp";

  const EmployeeScreen({super.key});

  static Widget builder(BuildContext context) {
    DepartmentModal? args =
        ModalRoute.of(context)!.settings.arguments as DepartmentModal?;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => EmployeeBloc()..add(FetchEmployees()),
        ),
        BlocProvider(
          create:
              (_) =>
                  DepartmentBloc()
                    ..add(FetchDepartments(adminId: args!.id_admin)),
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
  final TextEditingController searchController = TextEditingController();

  // Filter variables
  String? selectedDepartmentFilter;
  String? selectedManagerFilter;
  String selectedRoleFilter = 'All';

  @override
  void initState() {
    context.read<EmployeeBloc>().add(FetchEmployees());
    super.initState();
  }

  void _clearAllFilters() {
    setState(() {
      selectedDepartmentFilter = null;
      selectedManagerFilter = null;
      selectedRoleFilter = 'All';
      searchController.clear();
    });
  }

  void _showFilterBottomSheet() {
    final departments = context.read<DepartmentBloc>().state.departments;
    final managers =
        context
            .read<EmployeeBloc>()
            .state
            .employees
            .where((emp) => emp.role == 'Manager')
            .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setModalState) => Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
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
                                selectedDepartmentFilter = null;
                                selectedManagerFilter = null;
                                selectedRoleFilter = 'All';
                              });
                            },
                            child: const Text('Clear All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Role Filter
                      const Text(
                        'Filter by Role:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedRoleFilter,
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
                            selectedRoleFilter = value ?? 'All';
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Department Filter
                      const Text(
                        'Filter by Department:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedDepartmentFilter,
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
                            selectedDepartmentFilter = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Manager Filter
                      const Text(
                        'Filter by Manager:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedManagerFilter,
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
                            selectedManagerFilter = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      // Apply Button
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            // Update the main state with filter values
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.withOpacity(0.8),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Apply Filters'),
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

  List<EmployeeModal> _getFilteredEmployees(List<EmployeeModal> employees) {
    final query = searchController.text.toLowerCase();

    return employees.where((employee) {
      bool matchesSearch =
          query.isEmpty ||
          employee.name.toLowerCase().contains(query) ||
          employee.email.toLowerCase().contains(query) ||
          (employee.departmentName?.toLowerCase().contains(query) ?? false) ||
          (employee.managerName?.toLowerCase().contains(query) ?? false);

      bool matchesRole =
          selectedRoleFilter == 'All' || employee.role == selectedRoleFilter;

      bool matchesDepartment =
          selectedDepartmentFilter == null ||
          employee.departmentName == selectedDepartmentFilter;

      bool matchesManager =
          selectedManagerFilter == null ||
          employee.managerName == selectedManagerFilter;

      return matchesSearch &&
          matchesRole &&
          matchesDepartment &&
          matchesManager;
    }).toList();
  }

  Widget _buildActiveFiltersChips() {
    List<Widget> chips = [];

    if (selectedRoleFilter != 'All') {
      chips.add(
        _buildFilterChip('Role: $selectedRoleFilter', () {
          setState(() => selectedRoleFilter = 'All');
        }),
      );
    }

    if (selectedDepartmentFilter != null) {
      chips.add(
        _buildFilterChip('Dept: $selectedDepartmentFilter', () {
          setState(() => selectedDepartmentFilter = null);
        }),
      );
    }

    if (selectedManagerFilter != null) {
      chips.add(
        _buildFilterChip('Manager: $selectedManagerFilter', () {
          setState(() => selectedManagerFilter = null);
        }),
      );
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: [
          ...chips,
          if (chips.isNotEmpty)
            ActionChip(
              label: const Text('Clear All'),
              onPressed: _clearAllFilters,
              backgroundColor: Colors.grey.shade200,
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onDeleted) {
    return Chip(
      label: Text(label),
      onDeleted: onDeleted,
      backgroundColor: Colors.red.withOpacity(0.1),
      deleteIconColor: Colors.red,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: Colors.red.withOpacity(0.2),
        elevation: 2,
        title: const Text(
          "All Employees",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              onChanged: (value) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search employees...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                            setState(() {});
                          },
                        )
                        : null,
                filled: true,
                border: OutlineInputBorder(
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

          // Active Filters
          _buildActiveFiltersChips(),

          // Employee List
          Expanded(
            child: BlocBuilder<EmployeeBloc, EmployeeState>(
              builder: (context, state) {
                final filteredEmployees = _getFilteredEmployees(
                  state.employees,
                );

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
                          "Try adding some employees",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text("Refresh"),
                          onPressed: () {
                            context.read<EmployeeBloc>().add(FetchEmployees());
                          },
                        ),
                      ],
                    ),
                  );
                }

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
                        const Text(
                          "No employees match your filters",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Try adjusting your search or filters",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.clear),
                          label: const Text("Clear Filters"),
                          onPressed: _clearAllFilters,
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
                      confirmDismiss:
                          (_) => showDialog<bool>(
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
                          DeleteEmployee(id: "${employee.id}"),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("${employee.name} deleted"),
                            action: SnackBarAction(
                              label: "UNDO",
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Undo feature not implemented",
                                    ),
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
                              employee.role.substring(0, 1).toUpperCase(),
                            ),
                          ),
                          title: Text(
                            employee.name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(employee.email),
                              Row(
                                children: [
                                  if (employee.role != 'Employee')
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        employee.role,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  if (employee.role != 'Employee' &&
                                      employee.departmentName != null)
                                    const SizedBox(width: 8),
                                ],
                              ),
                              if (employee.departmentName != null)
                                Text("Dept: ${employee.departmentName}"),
                              if (employee.managerName != null)
                                Text("Manager: ${employee.managerName}"),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              showEmployeeDialog(
                                context: context,
                                bloc: context.read<EmployeeBloc>(),
                                employee: employee,
                              );
                            },
                          ),
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
  final addressController = TextEditingController(
    text: employee?.address ?? '',
  );
  final dobController = TextEditingController(text: employee?.dob ?? '');
  final idController = TextEditingController(text: "${employee?.id ?? ''}")
    ..text = employee?.id?.toString() ?? '';

  final departments = context.read<DepartmentBloc>().state.departments;
  final managers =
      context
          .read<EmployeeBloc>()
          .state
          .employees
          .where((emp) => emp.role == 'Manager')
          .toList();

  DepartmentModal? args =
      ModalRoute.of(context)!.settings.arguments as DepartmentModal?;
  String selectedRole = employee?.role ?? 'Employee';
  DepartmentModal? selectedDepartment;
  EmployeeModal? selectedManager;

  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      dobController.text = "${picked.day}/${picked.month}/${picked.year}";
    }
  }

  showDialog(
    context: context,
    builder:
        (dialogContext) => StatefulBuilder(
          builder:
              (context, setState) => AlertDialog(
                title: Text(
                  employee != null ? 'Edit Employee' : 'Add Employee',
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
                            setState(() {
                              selectedRole = value ?? 'Employee';
                            });
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
                            setState(() {
                              selectedDepartment = value;
                            });
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
                              setState(() {
                                selectedManager = value;
                              });
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
                              adminId: args!.id_admin,
                              id: employee.id!,
                              role: selectedRole,
                              name: nameController.text,
                              email: emailController.text,
                              address: addressController.text,
                              dob: dobController.text,
                              managerName: selectedManager?.name ?? "",
                              department: selectedDepartment?.name ?? "",
                              departmentId: selectedDepartment?.id ?? "",
                            ),
                          );
                        } else {
                          bloc?.add(
                            AddEmployee(
                              adminId: args!.id_admin,
                              id: idController.text,
                              role: selectedRole,
                              name: nameController.text,
                              email: emailController.text,
                              address: addressController.text,
                              dob: dobController.text,
                              managerName: selectedManager?.name ?? "",
                              department: selectedDepartment?.name ?? "",
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
        ),
  );
}
