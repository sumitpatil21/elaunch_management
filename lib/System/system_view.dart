import 'dart:developer';

import 'package:elaunch_management/System/system_event.dart';
import 'package:elaunch_management/System/system_state.dart';
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) =>
                  SystemBloc()
                    ..add(const FetchSystem())
                    ..add(const FetchRequests()),
        ),
        BlocProvider(
          create: (context) => EmployeeBloc()..add(const FetchEmployees()),
        ),
        BlocProvider(create: (context) => AdminBloc()..add(const AdminFetch())),
      ],
      child: const SystemView(),
    );
  }

  @override
  State<SystemView> createState() => _SystemViewState();
}

class _SystemViewState extends State<SystemView> {
  final TextEditingController searchController = TextEditingController();
  String selectedStatusFilter = 'all';

  final List<String> statusFilters = [
    'all',
    'available',
    'assigned',
    'maintenance',
    'retired',
  ];

  @override
  Widget build(BuildContext context) {
    SelectRole? loginEmployee =
        ModalRoute.of(context)!.settings.arguments as SelectRole?;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow.withOpacity(0.2),
        title: const Text("System"),
        actions: [
          if (loginEmployee?.adminModal != null)
            BlocBuilder<SystemBloc, SystemState>(
              builder: (context, state) {
                final requestCount = state.requests.length;
                return Stack(
                  children: [
                    TextButton(
                      onPressed: () {
                        context.read<SystemBloc>().add(const FetchRequests());
                        log('Requests: ${state.requests.toString()}');
                        showRequestDialog(
                          context,
                          state.requests,
                          context.read<SystemBloc>(),
                          loginEmployee?.employeeModal,
                        );
                      },
                      child: const Text(
                        "Requests",
                        style: TextStyle(color: Colors.yellow),
                      ),
                    ),
                    if (requestCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$requestCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
      floatingActionButton:
          loginEmployee?.adminModal != null
              ? FloatingActionButton.extended(
                backgroundColor: Colors.yellow.withOpacity(0.2),
                onPressed: () {
                  showSystemDialog(
                    context,
                    employeeBloc:
                        context.read<EmployeeBloc>()
                          ..add(const FetchEmployees()),
                    systemBloc: context.read<SystemBloc>(),
                    adminId: loginEmployee?.adminModal?.id,
                  );
                },
                label: const Text("Add System"),
                icon: const Icon(Icons.add),
              )
              : null,
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
                  ),
                );
              },
            ),
          ),

          // Systems List
          Expanded(
            child: BlocBuilder<SystemBloc, SystemState>(
              builder: (context, state) {
                List<SystemModal> filteredSystems =
                    state.systems.where((system) {
                      final matchesSearch = system.systemName
                          .toLowerCase()
                          .contains(searchController.text.toLowerCase());
                      final matchesStatus =
                          selectedStatusFilter == 'all' ||
                          system.status == selectedStatusFilter;
                      return matchesSearch && matchesStatus;
                    }).toList();

                if (filteredSystems.isEmpty) {
                  return const Center(child: Text('No systems found'));
                }

                return ListView.builder(
                  itemCount: filteredSystems.length,
                  itemBuilder: (context, index) {
                    final system = filteredSystems[index];

                    final isAlreadyRequested =
                        system.isRequested == true &&
                        system.requestId == loginEmployee?.employeeModal?.id;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(
                          system.systemName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("OS: ${system.operatingSystem ?? 'Unknown'}"),
                            Text("Version: ${system.version ?? 'Unknown'}"),
                            Text(
                              "Employee: ${system.employeeName ?? 'Unassigned'}",
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
                                      fontSize: 8,
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

                            if (loginEmployee?.employeeModal != null &&
                                (system.status == 'available' ||
                                    isAlreadyRequested))
                              ElevatedButton(
                                onPressed:
                                    isAlreadyRequested
                                        ? () {
                                          // Cancel request
                                          context.read<SystemBloc>().add(
                                            CancelRequest(
                                              requestId:
                                                  loginEmployee!
                                                      .employeeModal!
                                                      .id ??
                                                  "",
                                              systemId: system.id!,
                                            ),
                                          );
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Request cancelled successfully!',
                                              ),
                                            ),
                                          );
                                        }
                                        : () {
                                          // Submit request
                                          context.read<SystemBloc>().add(
                                            RequestSystem(
                                              system: SystemModal(
                                                id: system.id,
                                                systemName: system.systemName,
                                                version: system.version,
                                                status: system.status,
                                                employeeName:
                                                    system.employeeName,
                                                employeeId: system.employeeId,
                                                adminId: system.adminId,
                                                isRequested: true,
                                                requestId:
                                                    loginEmployee
                                                        ?.employeeModal
                                                        ?.id,
                                                requestedByName:
                                                    loginEmployee
                                                        ?.employeeModal
                                                        ?.name,
                                                requestedAt: DateTime.now(),
                                                requestStatus: 'pending',
                                                operatingSystem:
                                                    system.operatingSystem,
                                              ),
                                            ),
                                          );
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Request submitted successfully!',
                                              ),
                                            ),
                                          );
                                        },
                                child: Text(
                                  isAlreadyRequested ? "Cancel" : "Apply",
                                  style: TextStyle(
                                    color:
                                        isAlreadyRequested
                                            ? Colors.red
                                            : Colors.green,
                                  ),
                                ),
                              )
                            else if (loginEmployee?.adminModal != null)
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  showSystemDialog(
                                    context,
                                    system: system,
                                    employeeBloc:
                                        context.read<EmployeeBloc>()
                                          ..add(const FetchEmployees()),
                                    systemBloc: context.read<SystemBloc>(),
                                    adminId: loginEmployee?.adminModal?.id,
                                  );
                                },
                              ),
                          ],
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

  void showRequestDialog(
    BuildContext context,
    List<SystemModal> systemState,
    SystemBloc systemBloc,
    EmployeeModal? employee,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Pending Requests (${systemState.length})'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child:
                systemState.isEmpty
                    ? const Center(child: Text('No pending requests'))
                    : ListView.builder(
                      itemCount: systemState.length,
                      itemBuilder: (context, index) {
                        final request = systemState[index];
                        return Card(
                          child: ListTile(
                            title: Text(request.systemName),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Requested by: ${request.requestedByName ?? 'Unknown'}',
                                ),
                                if (request.requestedAt != null)
                                  Text('Date: ${request.requestedAt!}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.check,
                                    color: Colors.green,
                                  ),
                                  onPressed: () {
                                    // Fixed: Use the request's data for approval
                                    systemBloc.add(
                                      ApproveRequest(
                                        system: SystemModal(
                                          id: request.id,
                                          systemName: request.systemName,
                                          version: request.version,
                                          status: "assigned",
                                          employeeName:
                                              request
                                                  .requestedByName, // Use the requester's name
                                          employeeId:
                                              request
                                                  .requestId, // Use the requester's ID
                                          adminId: request.adminId,
                                          isRequested: false,
                                          requestedByName:
                                              request.requestedByName,
                                          requestedAt: request.requestedAt,
                                          requestStatus: 'approved',
                                          operatingSystem:
                                              request.operatingSystem,
                                          requestId:
                                              null, // Clear request ID after approval
                                        ),
                                      ),
                                    );
                                    Navigator.pop(context);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ),

                                  onPressed: () {
                                    systemBloc.add(
                                      RejectRequest(
                                        system: SystemModal(
                                          id: request.id,
                                          systemName: request.systemName,
                                          version: request.version,
                                          status:
                                              "available", // Fixed: Set back to available, not "Unassigned"
                                          employeeName: null,
                                          employeeId: null,
                                          adminId: request.adminId,
                                          isRequested: false,
                                          requestedByName: null,
                                          requestedAt: request.requestedAt,
                                          requestStatus: 'rejected',
                                          operatingSystem:
                                              request.operatingSystem,
                                          requestId: null,
                                        ),
                                      ),
                                    );
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
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
                          }),
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
                            system: SystemModal(
                              id: system.id,
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
