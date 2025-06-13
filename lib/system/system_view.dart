


import 'package:elaunch_management/System/system_event.dart';
import 'package:elaunch_management/System/system_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import 'package:elaunch_management/Service/system_modal.dart';
import 'package:elaunch_management/SuperAdminLogin/admin_bloc.dart';
import 'package:elaunch_management/System/system_bloc.dart';

import '../SuperAdminLogin/admin_event.dart';
import '../employee/employee_bloc.dart';
import '../service/employee_modal.dart';

class SystemView extends StatefulWidget {
  static String routeName = "/system";

  const SystemView({super.key});

  static Widget builder(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SystemBloc()
            ..add(const FetchSystem())
            ..add(const FetchRequests()),
        ),
        BlocProvider(
          create: (context) => EmployeeBloc()..add(const FetchEmployees()),
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

    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 800;
    final isMobile = screenWidth < 600;

    return Scaffold(
      appBar: _buildAppBar(context, loginEmployee, isWeb),
      floatingActionButton: _buildFloatingActionButton(context, loginEmployee),
      body: _buildBody(context, loginEmployee, isWeb, isMobile),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, SelectRole? loginEmployee, bool isWeb) {
    return AppBar(
      backgroundColor: Colors.yellow.withOpacity(0.2),
      title: Text(
        "System Management",
        style: TextStyle(fontSize: isWeb ? 24 : 20),
      ),
      actions: [
        if (loginEmployee?.adminModal != null)
          BlocBuilder<SystemBloc, SystemState>(
            builder: (context, state) {
              final requestCount = state.requests.length;
              return Stack(
                children: [
                  TextButton.icon(
                    onPressed: () => _showRequestDialog(
                      context,
                      state.requests,
                      context.read<SystemBloc>(),
                      loginEmployee?.employeeModal,
                    ),
                    icon: const Icon(Icons.notifications, color: Colors.yellow),
                    label: Text(
                      isWeb ? "Requests" : "",
                      style: const TextStyle(color: Colors.yellow),
                    ),
                  ),
                  if (requestCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                        ),
                        child: Text(
                          '$requestCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
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
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context, SelectRole? loginEmployee) {
    if (loginEmployee?.adminModal == null) return null;

    return FloatingActionButton.extended(
      backgroundColor: Colors.yellow.withOpacity(0.2),
      onPressed: () => _showSystemDialog(
        context,
        employeeBloc: context.read<EmployeeBloc>()..add(const FetchEmployees()),
        systemBloc: context.read<SystemBloc>(),
        adminId: loginEmployee?.adminModal?.id,
      ),
      label: const Text("Add System"),
      icon: const Icon(Icons.add),
    );
  }

  Widget _buildBody(BuildContext context, SelectRole? loginEmployee, bool isWeb, bool isMobile) {
    return Column(
      children: [
        _buildSearchAndFilters(isWeb, isMobile),
        _buildSystemsList(context, loginEmployee, isWeb, isMobile),
      ],
    );
  }

  Widget _buildSearchAndFilters(bool isWeb, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isWeb ? 24.0 : 16.0),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: "Search Systems",
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
          const SizedBox(height: 16),

          // Status Filter Chips
          SizedBox(
            height: 50,
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
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedStatusFilter = status;
                      });
                    },
                    backgroundColor: _getStatusColor(status),
                    selectedColor: _getStatusColor(status),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemsList(BuildContext context, SelectRole? loginEmployee, bool isWeb, bool isMobile) {
    return Expanded(
      child: BlocBuilder<SystemBloc, SystemState>(
        builder: (context, state) {


          List<SystemModal> filteredSystems = state.systems.where((system) {
          final matchesSearch = system.systemName
              .toLowerCase()
              .contains(searchController.text.toLowerCase());
          final matchesStatus = selectedStatusFilter == 'all' ||
          system.status == selectedStatusFilter;
          return matchesSearch && matchesStatus;
          }).toList();

          if (filteredSystems.isEmpty) {
          return const Center(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Icon(Icons.computer_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No systems found', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
          ),
          );
          }

          return isWeb
          ? _buildWebGridView(filteredSystems, loginEmployee, context)
              : _buildMobileListView(filteredSystems, loginEmployee, context);
        },
      ),
    );
  }

  Widget _buildWebGridView(List<SystemModal> systems, SelectRole? loginEmployee, BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: systems.length,
      itemBuilder: (context, index) {
        final system = systems[index];
        return _buildSystemCard(system, loginEmployee, context, isWeb: true);
      },
    );
  }

  Widget _buildMobileListView(List<SystemModal> systems, SelectRole? loginEmployee, BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: systems.length,
      itemBuilder: (context, index) {
        final system = systems[index];
        return _buildSystemCard(system, loginEmployee, context, isWeb: false);
      },
    );
  }

  Widget _buildSystemCard(SystemModal system, SelectRole? loginEmployee, BuildContext context, {required bool isWeb}) {
    // final isAlreadyRequested = system.isRequested == true &&
    //     system.requestId == loginEmployee?.employeeModal?.id;

    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: isWeb ? 0 : 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
        // Header
        Row(
        children: [
        Icon(Icons.computer, color: _getStatusColor(system.status ?? 'available')),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            system.systemName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isWeb ? 18 : 16,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ],
      ),
      const SizedBox(height: 12),

      // System Details
      _buildDetailRow("OS", system.operatingSystem ?? 'Unknown'),
      _buildDetailRow("Version", system.version ?? 'Unknown'),
      _buildDetailRow("Employee", system.employeeName ?? 'Unassigned'),

      const SizedBox(height: 8),

      // Status Badge
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
            color: _getStatusColor(system.status ?? 'available'),


            borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        (system.status ?? 'available').toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    const Spacer(),

    // Actions
    _buildActionButtons(system, loginEmployee, context),
    ],
    ),
    ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(SystemModal system, SelectRole? loginEmployee, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Employee Actions
        if (loginEmployee?.employeeModal != null &&
            (system.status == 'available' ||
                (system.isRequested == true && system.requestId == loginEmployee?.employeeModal?.id)))
          _buildEmployeeActionButton(system, loginEmployee!, context),

        // Admin Actions
        if (loginEmployee?.adminModal != null) ...[
          const SizedBox(width: 8),
          _buildAdminActionButton(system, loginEmployee!, context),
        ],
      ],
    );
  }

  Widget _buildEmployeeActionButton(SystemModal system, SelectRole loginEmployee, BuildContext context) {
    final isAlreadyRequested = system.isRequested == true &&
        system.requestId == loginEmployee.employeeModal?.id;

    return ElevatedButton.icon(
      onPressed: () => _handleEmployeeAction(system, loginEmployee, context, isAlreadyRequested),
      icon: Icon(
        isAlreadyRequested ? Icons.cancel : Icons.send,
        size: 16,
      ),
      label: Text(
        isAlreadyRequested ? "Cancel" : "Request",
        style: const TextStyle(fontSize: 12),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isAlreadyRequested ? Colors.red[100] : Colors.green[100],
        foregroundColor: isAlreadyRequested ? Colors.red : Colors.green,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildAdminActionButton(SystemModal system, SelectRole loginEmployee, BuildContext context) {
    return IconButton(
      onPressed: () => _showSystemDialog(
        context,
        system: system,
        employeeBloc: context.read<EmployeeBloc>()..add(const FetchEmployees()),
        systemBloc: context.read<SystemBloc>(),
        adminId: loginEmployee.adminModal?.id,
      ),
      icon: const Icon(Icons.edit),
      style: IconButton.styleFrom(
        backgroundColor: Colors.blue[100],
        foregroundColor: Colors.blue,
      ),
    );
  }

  void _handleEmployeeAction(SystemModal system, SelectRole loginEmployee, BuildContext context, bool isCancel) {
    if (isCancel) {
      context.read<SystemBloc>().add(
        CancelRequest(
          requestId: loginEmployee.employeeModal!.id ?? "",
          systemId: system.id!,
        ),
      );
      _showSnackBar(context, 'Request cancelled successfully!', Colors.orange);
    } else {
      context.read<SystemBloc>().add(
        RequestSystem(
          system: SystemModal(
            id: system.id,
            systemName: system.systemName,
            version: system.version,


            status: system.status,
            employeeName: system.employeeName,
            employeeId: system.employeeId,
            adminId: system.adminId,
            isRequested: true,
            requestId: loginEmployee.employeeModal?.id,
            requestedByName: loginEmployee.employeeModal?.name,
            requestedAt: DateTime.now(),
            requestStatus: 'pending',
            operatingSystem: system.operatingSystem,
          ),
        ),
      );
      _showSnackBar(context, 'Request submitted successfully!', Colors.green);
    }
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _getStatusColor(String status) {
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
        return Colors.grey;
    }
  }

  void _showRequestDialog(BuildContext context, List<SystemModal> requests, SystemBloc systemBloc, EmployeeModal? employee,) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 800;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.pending_actions, color: Colors.orange),
              const SizedBox(width: 8),
              Text('Pending Requests (${requests.length})'),
            ],
          ),
          content: SizedBox(
            width: isWeb ? 600 : double.maxFinite,
            height: isWeb ? 500 : 400,
            child: requests.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No pending requests', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
                : ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Icon(
                      Icons.computer,
                      color: _getStatusColor('pending'),
                    ),
                    title: Text(
                      request.systemName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Requested by: ${request.requestedByName ?? 'Unknown'}'),
                        if (request.requestedAt != null)
                          Text('Date: ${_formatDate(request.requestedAt!)}'),
                        Text('OS: ${request.operatingSystem ?? 'Unknown'}'),
                      ],
                    ),
                    trailing: Row(
                        mainAxisSize: MainAxisSize.min,


                        children: [
                    IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    onPressed: () => _approveRequest(systemBloc, request, context),
                    tooltip: 'Approve',
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () => _rejectRequest(systemBloc, request, context),
                    tooltip: 'Reject',
                  ),
                  ],
                ),
                ),
                );
              },
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _approveRequest(SystemBloc systemBloc, SystemModal request, BuildContext context) {
    systemBloc.add(
      ApproveRequest(
        system: SystemModal(
          id: request.id,
          systemName: request.systemName,
          version: request.version,
          status: "assigned",
          employeeName: request.requestedByName,
          employeeId: request.requestId,
          adminId: request.adminId,
          isRequested: false,
          requestedByName: request.requestedByName,
          requestedAt: request.requestedAt,
          requestStatus: 'approved',
          operatingSystem: request.operatingSystem,
          requestId: null,
        ),
      ),
    );
    Navigator.pop(context);
    _showSnackBar(context, 'Request approved successfully!', Colors.green);
  }

  void _rejectRequest(SystemBloc systemBloc, SystemModal request, BuildContext context) {
    systemBloc.add(
      RejectRequest(
        system: SystemModal(
          id: request.id,
          systemName: request.systemName,
          version: request.version,
          status: "available",
          employeeName: null,
          employeeId: null,
          adminId: request.adminId,
          isRequested: false,
          requestedByName: null,
          requestedAt: request.requestedAt,
          requestStatus: 'rejected',
          operatingSystem: request.operatingSystem,
          requestId: null,
        ),
      ),
    );
    Navigator.pop(context);
    _showSnackBar(context, 'Request rejected', Colors.orange);
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  void _showSystemDialog(BuildContext context, {SystemModal? system, required EmployeeBloc employeeBloc, required SystemBloc systemBloc, String? adminId,}) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final versionController = TextEditingController();
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 800;

    final unassignedEmployee = EmployeeModal(
      id: '-1',
      name: "Unassigned",
      email: '',
      password: '',
      address: '',
      role: "",
      departmentId: "1",
      adminId: "",
      departmentName: "",
      managerName: "",
      managerId: "",
    );

    EmployeeModal selectedEmployee = unassignedEmployee;
    String selectedStatus = 'available';
    String selectedOS = 'Windows';

    if (system != null) {
      nameController.text = system.systemName;
      versionController.text = system.version ?? '';
      selectedStatus = system.status ?? 'available';
      selectedOS = system.operatingSystem ?? 'Windows';

      if (system.employeeId != null) {

    try {
    selectedEmployee = employeeBloc.state.employees.firstWhere(
    (emp) => emp.id == system.employeeId,
    orElse: () => unassignedEmployee,
    );
    } catch (e) {
    selectedEmployee = unassignedEmployee;
    }
    }
    }

    showDialog(
    context: context,
    builder: (_) {
    return StatefulBuilder(
    builder: (context, setState) {
    return AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    title: Row(
    children: [
    Icon(system != null ? Icons.edit : Icons.add),
    const SizedBox(width: 8),
    Text(system != null ? 'Edit System' : 'Add System'),
    ],
    ),
    content: SizedBox(
    width: isWeb ? 500 : double.maxFinite,
    child: SingleChildScrollView(
    child: Form(
    key: formKey,
    child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
    TextFormField(
    controller: nameController,
    validator: (value) => value == null || value.isEmpty
    ? 'Please enter a system name'
        : null,
    decoration: const InputDecoration(
    labelText: "System Name",
    border: OutlineInputBorder(),
    prefixIcon: Icon(Icons.computer),
    ),
    ),
    const SizedBox(height: 16),

    DropdownButtonFormField<String>(
    value: selectedOS,
    decoration: const InputDecoration(
    labelText: "Operating System",
    border: OutlineInputBorder(),
    prefixIcon: Icon(Icons.settings),
    ),
    items: ['Windows', 'macOS', 'Linux']
        .map((os) => DropdownMenuItem(
    value: os,
    child: Text(os),
    ))
        .toList(),
    onChanged: (value) {
    setState(() {
    selectedOS = value ?? 'Windows';
    });
    },
    ),
    const SizedBox(height: 16),

    TextFormField(
    controller: versionController,
    validator: (value) => value == null || value.isEmpty
    ? 'Please enter a version'
        : null,
    decoration: const InputDecoration(
    labelText: "Version",
    border: OutlineInputBorder(),
    prefixIcon: Icon(Icons.info),
    ),
    ),
    const SizedBox(height: 16),

    DropdownButtonFormField<String>(
    value: selectedStatus,
    decoration: const InputDecoration(
    labelText: "Status",
    border: OutlineInputBorder(),
    prefixIcon: Icon(Icons.circle),
    ),
    items: ['available', 'assigned', 'maintenance', 'retired']


        .map((status) => DropdownMenuItem(
    value: status,
    child: Row(
    children: [
    Container(
    width: 12,
    height: 12,
    decoration: BoxDecoration(
    color: _getStatusColor(status),
    shape: BoxShape.circle,
    ),
    ),
    const SizedBox(width: 8),
    Text(status.toUpperCase()),
    ],
    ),
    ))
        .toList(),
    onChanged: (value) {
    setState(() {
    selectedStatus = value ?? 'available';
    });
    },
    ),
    const SizedBox(height: 16),

    DropdownButtonFormField<EmployeeModal?>(
    value: selectedEmployee,
    decoration: const InputDecoration(
    labelText: "Assign Employee",
    border: OutlineInputBorder(),
    prefixIcon: Icon(Icons.person),
    ),
    items: [
    DropdownMenuItem<EmployeeModal?>(
    value: unassignedEmployee,
    child: const Text("Unassigned"),
    ),
    ...employeeBloc.state.employees.map((emp) {
    return DropdownMenuItem<EmployeeModal?>(
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
    ),
    actions: [
    TextButton(
    child: const Text("Cancel"),
    onPressed: () => Navigator.pop(context),
    ),
    ElevatedButton.icon(
    icon: Icon(system != null ? Icons.update : Icons.add),
    label: Text(system != null ? "Update" : "Add"),
    onPressed: () => _submitSystemForm(
    formKey,
    system,
    systemBloc,
    nameController,
    versionController,
    selectedStatus,
    selectedOS,
    selectedEmployee,
    unassignedEmployee,
    adminId,
    context,
    ),
    ),
    ],
    );
    },
    );
    },
    );
  }

  void _submitSystemForm(GlobalKey<FormState> formKey, SystemModal? system, SystemBloc systemBloc, TextEditingController nameController, TextEditingController versionController, String selectedStatus, String selectedOS, EmployeeModal selectedEmployee, EmployeeModal unassignedEmployee,


  String? adminId,
  BuildContext context,
  ) {
  if (formKey.currentState!.validate()) {
  if (system != null) {
  systemBloc.add(
  UpdateSystem(
  system: SystemModal(
  id: system.id,
  systemName: nameController.text.trim(),
  version: versionController.text.trim(),
  status: selectedStatus,
  operatingSystem: selectedOS,
  employeeName: selectedEmployee.id == '-1' ? null : selectedEmployee.name,
  employeeId: selectedEmployee.id == '-1' ? null : selectedEmployee.id,
  adminId: adminId,
  ),
  ),
  );
  _showSnackBar(context, 'System updated successfully!', Colors.blue);
  } else {
  systemBloc.add(
  AddSystem(
  systemName: nameController.text.trim(),
  version: versionController.text.trim(),
  status: selectedStatus,
  operatingSystem: selectedOS,
  employeeName: selectedEmployee.id == '-1' ? null : selectedEmployee.name,
  employeeId: selectedEmployee.id == '-1' ? null : selectedEmployee.id,
  adminId: adminId,
  ),
  );
  _showSnackBar(context, 'System added successfully!', Colors.green);
  }
  Navigator.pop(context);
  }
  }
}