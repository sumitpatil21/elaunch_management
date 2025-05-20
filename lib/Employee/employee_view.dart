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
    ManagerScreenArguments? args =
    ModalRoute.of(context)!.settings.arguments as ManagerScreenArguments;

    final manager = args.manager;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) => EmployeeBloc(EmployeeState())..add(
            manager != null
                ? FetchEmployees(
              adminId: args.adminId,
              departmentName: manager.departmentName,
              managerName: manager.managerName,
            )
                :  FetchEmployees(adminId: args.adminId),
          ),
        ),
        BlocProvider(
          create: (_) => ManagerBloc(ManagerState())..add(FetchManagers(adminId: args.adminId??1)),
        ),
        BlocProvider(
          create:
              (_) => DepartmentBloc(DepartmentState())..add(FetchDepartments(adminId: args.adminId)),
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

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as ManagerScreenArguments;
    final manager = args.manager;
    final departments = args.departmentList;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        backgroundColor: Colors.red.withOpacity(0.2),
        elevation: 2,
        title: Text(
          (manager?.managerName != null)
              ? "${manager?.managerName}'s Team"
              : (manager?.departmentName != null)
              ? "${manager?.departmentName}'s Employee"
              : "All Employees",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          BlocBuilder<DepartmentBloc, DepartmentState>(
            builder: (context, deptState) {
              return BlocBuilder<ManagerBloc, ManagerState>(
                builder: (context, managerState) {
                  return PopupMenuButton<String>(
                    icon: const Icon(Icons.filter_list),
                    tooltip: "Filter employees",
                    itemBuilder: (context) => [
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
                        context.read<EmployeeBloc>().add(FetchEmployees(adminId: args.adminId));
                      } else if (value == "manager" && managerState.managers.isNotEmpty) {
                        final selected = await showDialog<Map<String, dynamic>>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Select Manager"),
                            content: SizedBox(
                              width: double.maxFinite,
                              height: 300,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: managerState.managers.length,
                                itemBuilder: (_, index) => ListTile(
                                  leading: const Icon(Icons.person),
                                  title: Text(managerState.managers[index].managerName),
                                  subtitle: Text(managerState.managers[index].departmentName ?? 'No Department'),
                                  onTap: () => Navigator.pop(context, {
                                    'name': managerState.managers[index].managerName,
                                    "depart": managerState.managers[index].departmentName,
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
                              adminId: args.adminId,
                              managerName: selected['name'],
                              departmentName: selected['depart'],
                            ),
                          );
                        }
                      } else if (value == "department" && deptState.departments.isNotEmpty) {
                        // Add handler for department filtering
                        final selectedDept = await showDialog<DepartmentModal?>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Select Department"),
                            content: SizedBox(
                              width: double.maxFinite,
                              height: 300,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: deptState.departments.length,
                                itemBuilder: (_, index) => ListTile(
                                  leading: const Icon(Icons.business),
                                  title: Text(deptState.departments[index].name),
                                  onTap: () => Navigator.pop(
                                    context,
                                    deptState.departments[index],
                                  ),
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

                        if (selectedDept != null) {
                          context.read<EmployeeBloc>().add(
                            FetchEmployees(
                              adminId: args.adminId,
                              departmentName: selectedDept.name,
                            ),
                          );
                        }
                      }
                    },
                  );
                },
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search employees...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    setState(() {}); // Trigger rebuild to update the list
                  },
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
              onChanged: (value) {
                setState(() {}); // Trigger rebuild to update filtered list
              },
            ),
          ),

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
                          manager?.managerName != null
                              ? "No employees under ${manager?.managerName}"
                              : manager?.departmentName != null
                              ? "No employees in ${manager?.departmentName}"
                              : "Try adding some employees",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text("Refresh"),
                          onPressed: () {
                            context.read<EmployeeBloc>().add(
                              FetchEmployees(
                                adminId: args.adminId,
                                departmentName: manager?.departmentName,
                                managerName: manager?.managerName,
                              ),
                            );
                          },
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

                final filteredEmployees =
                searchController.text.isEmpty
                    ? state.employees
                    : state.employees
                    .where(
                      (employee) =>
                  employee.name.toLowerCase().contains(
                    searchController.text.toLowerCase(),
                  ) ||
                      (employee.email.toLowerCase().contains(
                        searchController.text.toLowerCase(),
                      ) ) ||
                      (employee.departmentName
                          ?.toLowerCase()
                          .contains(searchController.text.toLowerCase()) ??
                          false) ||
                      (employee.managerName?.toLowerCase().contains(
                        searchController.text.toLowerCase(),
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
                        Text("No results for \"${searchController.text}\""),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            searchController.clear();
                            setState(() {});
                          },
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
                            child: Text(employee.name[0].toUpperCase()),
                          ),
                          title: Text(
                            employee.name,
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(employee.email),
                              if (employee.managerName != null && employee.managerName!.isNotEmpty)
                                Text("Manager: ${employee.managerName}"),
                              if (employee.departmentName != null && employee.departmentName!.isNotEmpty)
                                Text("Department: ${employee.departmentName}"),
                            ],
                          ),
                          isThreeLine: true,
                          onTap: () {
                            // Show employee details (optional)
                            showEmployeeDialog(
                              context: context,
                              manager: manager,
                              bloc: context.read<EmployeeBloc>(),
                              employee: employee,
                              currentDepartmentName: employee.departmentName,
                              currentManagerName: employee.managerName,
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
          if(manager!=null)
          {
            showEmployeeDialog(
              context: context,
              manager: manager,
              bloc: context.read<EmployeeBloc>(),
            );
          }
          else
          {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("View Data")));
          }
        },
        icon: (manager==null)?Icon(Icons.remove_red_eye): Icon(Icons.add),
        label:  (manager==null)?Text("View Employee"):Text("Add Employee"),
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
                  return null;
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

              String managerName = currentManagerName ?? employee?.managerName ?? manager?.managerName ?? '';
              String departmentName = currentDepartmentName ?? employee?.departmentName ?? manager?.departmentName ?? '';

              if (employee != null) {
                bloc?.add(
                  UpdateEmployee(
                    adminId: 1,
                    id: employee.id!,
                    managerId: managerId??1,
                    departmentId: departmentId??1,
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
                    adminId: 1,
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