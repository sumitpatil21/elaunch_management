import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:elaunch_management/Service/admin_modal.dart';
import 'package:elaunch_management/Service/employee_modal.dart';
import 'package:elaunch_management/Service/system_modal.dart';
import 'package:elaunch_management/SuperAdminLogin/admin_bloc.dart';
import 'package:elaunch_management/System/system_bloc.dart';
import '../Employee/employee_bloc.dart';

class SystemView extends StatefulWidget {
  static String routeName = "/system";
  const SystemView({super.key});

  static Widget builder(BuildContext context) {
    AdminModal? args =
        ModalRoute.of(context)!.settings.arguments as AdminModal?;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) => SystemBloc()..add(FetchSystem()),
        ),
        BlocProvider(
          create: (context) => EmployeeBloc()..add(FetchEmployees()),
        ),
        BlocProvider(create: (context) => AdminBloc()..add(AdminFetch())),
      ],
      child: const SystemView(),
    );
  }

  @override
  State<SystemView> createState() => _SystemViewState();
}

class _SystemViewState extends State<SystemView> {
  final TextEditingController searchController = TextEditingController();
  String selectedStatusFilter = 'all'; // Default to show all

  final List<String> statusFilters = [
    'all',
    'available',
    'assigned',
    'maintenance',
    'retired',
  ];

  @override
  Widget build(BuildContext context) {
    AdminModal? args =
        ModalRoute.of(context)!.settings.arguments as AdminModal?;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow.withOpacity(0.2),
        title: const Text("System"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.yellow.withOpacity(0.2),
        onPressed: () {
          showSystemDialog(
            context,
            employeeBloc: context.read<EmployeeBloc>()..add(FetchEmployees()),
            systemBloc: context.read<SystemBloc>(),
            adminId: args?.id,
          );
        },
        label: const Text("Add System"),
        icon: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Search",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    setState(() {});
                  },
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),

          // Status Filter Chips
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: statusFilters.length,
              itemBuilder: (context, index) {
                final status = statusFilters[index];
                final isSelected = selectedStatusFilter == status;

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(
                      status == 'all' ? 'All' : status.toUpperCase(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,

                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedStatusFilter = status;
                      });
                    },
                    backgroundColor: getStatusColor(status),
                    selectedColor: getStatusColor(status),
                    checkmarkColor: Colors.white,
                    elevation: isSelected ? 4 : 1,
                    pressElevation: 2,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Systems List
          Expanded(
            child: BlocBuilder<SystemBloc, SystemState>(
              builder: (context, state) {
                final query = searchController.text.toLowerCase();

                final filteredSystems =
                    state.systems.where((system) {
                      final matchesSearch =
                          system.systemName.toLowerCase().contains(query) ||
                          (system.version?.toLowerCase().contains(query) ??
                              false) ||
                          (system.employeeName?.toLowerCase().contains(query) ??
                              false) ||
                          (system.operatingSystem?.toLowerCase().contains(
                                query,
                              ) ??
                              false);

                      final matchesStatus =
                          selectedStatusFilter == 'all' ||
                          (system.status ?? 'available') ==
                              selectedStatusFilter;

                      return matchesSearch && matchesStatus;
                    }).toList();

                if (filteredSystems.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.computer_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          searchController.text.isNotEmpty ||
                                  selectedStatusFilter != 'all'
                              ? 'No systems match your filters'
                              : 'No systems found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (searchController.text.isNotEmpty ||
                            selectedStatusFilter != 'all')
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  searchController.clear();
                                  selectedStatusFilter = 'all';
                                });
                              },
                              child: const Text('Clear Filters'),
                            ),
                          ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredSystems.length,
                  itemBuilder: (context, index) {
                    final system = filteredSystems[index];
                    return Dismissible(
                      key: Key(system.id.toString()),
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
                          (_) => showDialog<bool>(
                            context: context,
                            builder:
                                (_) => AlertDialog(
                                  title: const Text("Confirm Delete"),
                                  content: Text(
                                    "Are you sure you want to delete ${system.systemName}?",
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
                        context.read<SystemBloc>().add(
                          DeleteSystem(
                            id: system.id ?? "1",
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("${system.systemName} deleted"),
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
                            backgroundColor: getStatusColor(
                              system.status ?? 'available',
                            ),
                            child: const Icon(
                              Icons.computer_outlined,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            system.systemName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${system.operatingSystem ?? ''} ${system.version ?? ''}",
                              ),
                              Text(
                                "Assigned to: ${system.employeeName ?? 'Unassigned'}",
                              ),
                              Row(
                                children: [
                                  const Text("Status: "),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: getStatusColor(
                                        system.status ?? 'available',
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      (system.status ?? 'available')
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  showSystemDialog(
                                    context,
                                    system: system,
                                    employeeBloc:
                                        context.read<EmployeeBloc>()
                                          ..add(FetchEmployees()),
                                    systemBloc: context.read<SystemBloc>(),
                                    adminId: args?.id,
                                  );
                                },
                              ),
                            ],
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
    );
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'assigned':
        return Colors.blue;
      case 'maintenance':
        return Colors.orange;
      case 'retired':
        return Colors.red;
      default:
        return Colors.yellow.withOpacity(0.2);
    }
  }

  void showSystemDialog(
    BuildContext context, {
    SystemModal? system,
    required EmployeeBloc employeeBloc,
    required SystemBloc systemBloc,
    String? adminId,
  }) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final versionController = TextEditingController();

    final unassignedEmployee = EmployeeModal(
      id: '-1',
      name: "Unassigned",
      email: '',
      password: '',
      address: '',
      dob: '',
      role: "",
      departmentName: "",
      managerName: "",
      departmentId: "1",
      adminId: "",
    );

    EmployeeModal? selectedEmployee = unassignedEmployee;
    String selectedStatus = 'available';
    String selectedOS = 'Windows';


    if (system != null) {
      nameController.text = system.systemName;
      versionController.text = system.version ?? '';
      selectedStatus = system.status ?? 'available';
      selectedOS = system.operatingSystem ?? 'Windows';

      if (system.employeeId != null) {
        selectedEmployee = employeeBloc.state.employees.firstWhere(
          (emp) => emp.id == system.employeeId,
          orElse: () => unassignedEmployee,
        );
      }
    }

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(system != null ? 'Edit System' : 'Add System'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Please enter a System name'
                                    : null,
                        decoration: const InputDecoration(
                          labelText: "System Name",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedOS,
                        decoration: const InputDecoration(
                          labelText: "Operating System",
                          border: OutlineInputBorder(),
                        ),
                        items:
                            ['Windows', 'macOS', 'Linux']
                                .map(
                                  (os) => DropdownMenuItem(
                                    value: os,
                                    child: Text(os),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedOS = value ?? 'Windows';
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: versionController,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Please enter a System Version'
                                    : null,
                        decoration: const InputDecoration(
                          labelText: "Version",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedStatus,
                        decoration: const InputDecoration(
                          labelText: "Status",
                          border: OutlineInputBorder(),
                        ),
                        items:
                            ['available', 'assigned', 'maintenance', 'retired']
                                .map(
                                  (status) => DropdownMenuItem(
                                    value: status,
                                    child: Text(status),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedStatus = value ?? 'available';
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      const Text("Select Employee (Optional)"),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<EmployeeModal>(
                        value: selectedEmployee,
                        decoration: const InputDecoration(
                          labelText: "Employee",
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem<EmployeeModal>(
                            value: unassignedEmployee,
                            child: const Text("Unassigned"),
                          ),
                          ...employeeBloc.state.employees.map((emp) {
                            return DropdownMenuItem<EmployeeModal>(
                              value: emp,
                              child: Text(emp.name),
                            );
                          }).toList(),
                        ],
                        onChanged: (emp) {
                          setState(() {
                            selectedEmployee = emp ?? unassignedEmployee;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  child: Text(system != null ? "Update" : "Add"),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      if (system != null) {
                        systemBloc.add(
                          UpdateSystem(
                            id: system.id!,
                            systemName: nameController.text,
                            version: versionController.text,
                            status: selectedStatus,
                            operatingSystem: selectedOS,
                            employeeId:
                                selectedEmployee?.id == '-1'
                                    ? null
                                    : selectedEmployee?.id,
                            adminId: adminId,
                          ),
                        );
                      } else {
                        systemBloc.add(
                          AddSystem(
                            systemName: nameController.text,
                            version: versionController.text,
                            status: selectedStatus,
                            operatingSystem: selectedOS,
                            employeeName:
                                selectedEmployee?.id == '-1'
                                    ? null
                                    : selectedEmployee?.name,
                            employeeId:
                                selectedEmployee?.id == '-1'
                                    ? null
                                    : selectedEmployee?.id,
                            adminId: adminId,
                          ),
                        );
                      }

                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
