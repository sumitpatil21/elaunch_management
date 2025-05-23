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
              (context) =>
                  SystemBloc(SystemState())
                    ..add(FetchSystem(adminId: args?.id)),
        ),
        BlocProvider(
          create:
              (context) =>
                  EmployeeBloc(EmployeeState())
                    ..add(FetchEmployees(adminId: args?.id)),
        ),
        BlocProvider(
          create: (context) => AdminBloc(AdminState())..add(AdminFetch()),
        ),
      ],
      child: const SystemView(),
    );
  }

  @override
  State<SystemView> createState() => _SystemViewState();
}

class _SystemViewState extends State<SystemView> {
  final TextEditingController searchController = TextEditingController();

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
          final employeeBloc = context.read<EmployeeBloc>();
          final systemBloc = context.read<SystemBloc>();
          if (employeeBloc.state.employees.isEmpty) {
            employeeBloc.add(FetchEmployees(adminId: args?.id ?? 1));
          }
          showManagerDialog(
            context,
            bloc: employeeBloc,
            systemBloc: systemBloc,
          );
        },
        label: const Text("Add System"),
        icon: const Icon(Icons.add),
      ),
      body: Column(
        children: [
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
          Expanded(
            child: BlocBuilder<SystemBloc, SystemState>(
              builder: (context, state) {
                final query = searchController.text.toLowerCase();
                final filteredSystems =
                    state.systems.where((system) {
                      return system.systemName.toLowerCase().contains(query) ||
                          (system.version?.toLowerCase().contains(query) ??
                              false) ||
                          (system.employeeName?.toLowerCase().contains(query) ??
                              false);
                    }).toList();

                if (filteredSystems.isEmpty) {
                  return Center(
                    child: Text(
                      searchController.text.isNotEmpty
                          ? 'No results for "${searchController.text}"'
                          : 'No System found',
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
                          (_) => showDialog(
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
                          DeleteSystem(id: system.id ?? 1),
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
                            backgroundColor: Colors.yellow.withOpacity(0.2),
                            child: const Icon(Icons.computer_outlined),
                          ),
                          title: Text(
                            system.systemName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(system.version ?? ""),
                              Text(system.employeeName ?? "N/A"),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.change_circle),
                                onPressed: () {
                                  showManagerDialog(
                                    context,
                                    system: system,
                                    bloc: context.read<EmployeeBloc>(),
                                    systemBloc: context.read<SystemBloc>(),
                                  );
                                },
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                ),
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

  void showManagerDialog(
    BuildContext context, {
    SystemModal? system,
    required EmployeeBloc bloc,
    required SystemBloc systemBloc,
  }) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(
      text: system?.systemName ?? '',
    );
    final versionController = TextEditingController(
      text: system?.version ?? '',
    );
    String selectedStatus = system?.status ?? 'available';
    String selectedOS = system?.operatingSystem ?? 'Windows';

    EmployeeModal? selectedEmployee =
        system != null && system.employeeId != null
            ? bloc.state.employees.firstWhere(
              (emp) => emp.id == system.employeeId,
              orElse:
                  () =>
                      bloc.state.employees.isNotEmpty
                          ? bloc.state.employees.first
                          : EmployeeModal(
                            id: -1,
                            name: "No employees available",
                            email: '',
                            address: '',
                            dob: '',
                          ),
            )
            : (bloc.state.employees.isNotEmpty
                ? bloc.state.employees.first
                : null);

    AdminModal? args =
        ModalRoute.of(context)!.settings.arguments as AdminModal?;

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
                      const Text("Select Employee"),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<EmployeeModal>(
                        value:
                            bloc.state.employees.contains(selectedEmployee)
                                ? selectedEmployee
                                : null,
                        decoration: const InputDecoration(
                          labelText: "Employee",
                          border: OutlineInputBorder(),
                        ),
                        items:
                            bloc.state.employees.map((emp) {
                              return DropdownMenuItem<EmployeeModal>(
                                value: emp,
                                child: Text(emp.name),
                              );
                            }).toList(),
                        onChanged: (emp) {
                          setState(() {
                            selectedEmployee = emp;
                          });
                        },
                        validator:
                            (value) =>
                                value == null
                                    ? 'Please select an employee'
                                    : null,
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
                    if (formKey.currentState!.validate() &&
                        selectedEmployee != null) {
                      if (system != null) {
                        systemBloc.add(
                          UpdateSystem(
                            id: system.id!,
                            systemName: nameController.text,
                            version: versionController.text,
                            status: selectedStatus,
                            operatingSystem: selectedOS,
                            employeeName: selectedEmployee!.name,
                            employeeId: selectedEmployee!.id,
                            adminId: args?.id ?? 1,
                          ),
                        );
                      } else {
                        systemBloc.add(
                          AddSystem(
                            systemName: nameController.text,
                            version: versionController.text,
                            status: selectedStatus,
                            operatingSystem: selectedOS,
                            employeeName: selectedEmployee!.name,
                            employeeId: selectedEmployee!.id,
                            adminId: args?.id ?? 1,
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
