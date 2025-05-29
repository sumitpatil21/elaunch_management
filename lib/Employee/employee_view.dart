import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Department/department_bloc.dart';
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
                    ..add(FetchDepartments(adminId: args?.id_admin ?? "1")),
        ),
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
                                department: tempDepartmentFilter,
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
                                manager: tempManagerFilter,
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
          (employee.departmentName?.toLowerCase().contains(query) ?? false) ||
          (employee.managerName?.toLowerCase().contains(query) ?? false);
    }).toList();
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
          "Employees",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
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


          Expanded(
            child: BlocBuilder<EmployeeBloc, EmployeeState>(
              builder: (context, state) {

                final searchFilteredEmployees = searchFilteredEmployee(
                  state.filteredEmployees,
                );

                if (state.employees.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                        ElevatedButton(
                          child: const Text("Refresh"),
                          onPressed: () {
                            context.read<EmployeeBloc>().add(FetchEmployees());
                          },
                        ),
                      ],
                    ),
                  );
                }

                if (searchFilteredEmployees.isEmpty) {
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
                          onPressed: clearAllFilters,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: searchFilteredEmployees.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final employee = searchFilteredEmployees[index];
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
                              if (employee.departmentName != null)
                                Text(
                                  'Dept: ${employee.departmentName}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              if (employee.managerName != null &&
                                  employee.managerName!.isNotEmpty)
                                Text(
                                  'Manager: ${employee.managerName}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              employee.role,
                              style: TextStyle(
                                color: Colors.red[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          onTap: () {
                            showEmployeeDialog(
                              context: context,
                              bloc: context.read<EmployeeBloc>(),
                              employee: employee,
                            );
                          },
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
