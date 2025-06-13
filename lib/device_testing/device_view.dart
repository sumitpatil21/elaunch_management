import 'dart:developer';

import 'package:elaunch_management/Service/admin_modal.dart';
import 'package:elaunch_management/Service/device_modal.dart';

import 'package:elaunch_management/SuperAdminLogin/admin_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Employee/employee_bloc.dart';
import '../SuperAdminLogin/admin_event.dart';
import '../service/employee_modal.dart';
import 'device_bloc.dart';
import 'device_event.dart';

class DeviceView extends StatefulWidget {
  static String routeName = "/device";

  const DeviceView({super.key});

  static Widget builder(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => DeviceBloc()..add(FetchDevice())),
        BlocProvider(
          create: (context) => EmployeeBloc()..add(FetchEmployees()),
        ),
        BlocProvider(create: (context) => AdminBloc()..add(AdminFetch())),
      ],
      child: const DeviceView(),
    );
  }

  @override
  State<DeviceView> createState() => _DeviceViewState();
}

class _DeviceViewState extends State<DeviceView> {
  final List<String> statusFilters = [
    'all',
    'available',
    'assigned',
    'maintenance',
    'retired',
  ];

  @override
  Widget build(BuildContext context) {
    SelectRole user =
        ModalRoute.of(context)!.settings.arguments as SelectRole;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple.withOpacity(0.2),
        title: const Text("Device"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.purple.withOpacity(0.2),
        onPressed: () => context.read<DeviceBloc>().add(ShowDeviceDialog()),
        label: const Text("Add Device"),
        icon: const Icon(Icons.add),
      ),
      body: BlocListener<DeviceBloc, DeviceState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }

          if (state.isDialogVisible) {
            _showDeviceDialog(context, state);
          }
        },
        child: Column(
          children: [_buildSearchAndFilters(), _buildDeviceList(user)],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return BlocBuilder<DeviceBloc, DeviceState>(
      builder: (context, state) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Search",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      context.read<DeviceBloc>().add(ClearSearch());
                    },
                  ),
                ),
                onChanged: (query) {
                  context.read<DeviceBloc>().add(UpdateSearchQuery(query));
                },
                controller: TextEditingController()..text = state.searchQuery,
              ),
            ),
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: statusFilters.length,
                itemBuilder: (context, index) {
                  final status = statusFilters[index];
                  final isSelected = state.selectedStatusFilter == status;

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
                        context.read<DeviceBloc>().add(
                          UpdateStatusFilter(status),
                        );
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
          ],
        );
      },
    );
  }

  Widget _buildDeviceList(SelectRole? user) {
    return Expanded(
      child: BlocBuilder<DeviceBloc, DeviceState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredDevices = state.filteredDevices;

          if (filteredDevices.isEmpty) {
            return Center(
              child: Text(
                state.searchQuery.isNotEmpty
                    ? 'No results for "${state.searchQuery}"'
                    : 'No Devices found',
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredDevices.length,
            itemBuilder: (context, index) {
              final device = filteredDevices[index];
              return _buildDeviceCard(context, device, user);
            },
          );
        },
      ),
    );
  }

  Widget _buildDeviceCard(
    BuildContext context,
    TestingDeviceModal device,
    SelectRole? user,
  ) {
    return Dismissible(
      key: Key(device.id.toString()),
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
      confirmDismiss: (_) => _showDeleteConfirmation(context, device),
      onDismissed: (_) {
        context.read<DeviceBloc>().add(DeleteDevice(device.id ?? ""));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("${device.deviceName} deleted")));
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: getStatusColor(device.status ?? 'available'),
            child: const Icon(Icons.phone_android),
          ),
          title: Text(
            device.deviceName,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${device.operatingSystem ?? ''} ${device.osVersion ?? ''}"),
              Text(
                "Assigned to: ${device.assignedEmployeeName ?? 'Unassigned'}",
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
                      color: getStatusColor(device.status ?? 'available'),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      (device.status ?? 'available').toUpperCase(),
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
              (user?.employeeModal == null)
                  ? IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      context.read<DeviceBloc>().add(
                        ShowDeviceDialog(device: device),
                      );
                    },
                  )
                  : ElevatedButton(
                    onPressed: () {},
                    child: const Text(
                      "Apply",
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(
    BuildContext context,
    TestingDeviceModal device,
  ) {
    return showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Confirm Delete"),
            content: Text(
              "Are you sure you want to delete ${device.deviceName} device?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("CANCEL"),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text("DELETE"),
              ),
            ],
          ),
    );
  }

  void _showDeviceDialog(BuildContext context, DeviceState state) {
    if (!state.isDialogVisible) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (_) => _DeviceDialog(
              device: state.dialogDevice,
              dialogData: state.dialogData,
            ),
      ).then((_) {
        context.read<DeviceBloc>().add(HideDeviceDialog());
      });
    });
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
        return Colors.purple.withOpacity(0.2);
    }
  }
}

class _DeviceDialog extends StatefulWidget {
  final TestingDeviceModal? device;
  final Map<String, dynamic> dialogData;

  const _DeviceDialog({required this.device, required this.dialogData});

  @override
  State<_DeviceDialog> createState() => _DeviceDialogState();
}

class _DeviceDialogState extends State<_DeviceDialog> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController versionController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
      text: widget.dialogData['deviceName'] ?? '',
    );
    versionController = TextEditingController(
      text: widget.dialogData['osVersion'] ?? '',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    versionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmployeeBloc, EmployeeState>(
      builder: (context, employeeState) {
        final unassignedEmployee = EmployeeModal(
          id: '-1',
          name: "Unassigned",
          email: '',
          password: '',
          address: '',
          departmentName: "",
          managerName: "",
          role: "",
          departmentId: "1",
          adminId: "1",
          managerId: "1",
        );

        EmployeeModal? selectedEmployee = unassignedEmployee;
        if (widget.dialogData['assignedToEmployeeId'] != null) {
          try {
            selectedEmployee =
                employeeState.employees.firstWhere(
                      (emp) =>
                          emp.id == widget.dialogData['assignedToEmployeeId'],
                    )
                    as EmployeeModal?;
          } catch (e) {
            selectedEmployee = unassignedEmployee;
          }
        }

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(widget.device != null ? 'Edit Device' : 'Add Device'),
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
                            value?.isEmpty == true
                                ? 'Please enter a device name'
                                : null,
                    decoration: const InputDecoration(
                      labelText: "Device Name",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      context.read<DeviceBloc>().add(
                        UpdateDialogField('deviceName', value),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: widget.dialogData['operatingSystem'] ?? 'Android',
                    decoration: const InputDecoration(
                      labelText: "Operating System",
                      border: OutlineInputBorder(),
                    ),
                    items:
                        ['Android', 'iOS']
                            .map(
                              (os) =>
                                  DropdownMenuItem(value: os, child: Text(os)),
                            )
                            .toList(),
                    onChanged: (value) {
                      context.read<DeviceBloc>().add(
                        UpdateDialogField('operatingSystem', value),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: versionController,
                    validator:
                        (value) =>
                            value?.isEmpty == true
                                ? 'Please enter OS version'
                                : null,
                    decoration: const InputDecoration(
                      labelText: "OS Version",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      context.read<DeviceBloc>().add(
                        UpdateDialogField('osVersion', value),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: widget.dialogData['status'] ?? 'available',
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
                      context.read<DeviceBloc>().add(
                        UpdateDialogField('status', value),
                      );
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
                      ...employeeState.employees.map((emp) {
                        return DropdownMenuItem<EmployeeModal>(
                          value: emp,
                          child: Text(emp.name),
                        );
                      }),
                    ],
                    onChanged: (emp) {
                      context.read<DeviceBloc>().add(
                        UpdateDialogField('assignedToEmployeeId', emp?.id),
                      );
                      context.read<DeviceBloc>().add(
                        UpdateDialogField('assignedEmployeeName', emp?.name),
                      );
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
              child: Text(widget.device != null ? "Update" : "Add"),
              onPressed: () => _saveDevice(context),
            ),
          ],
        );
      },
    );
  }

  void _saveDevice(BuildContext context) {
    if (formKey.currentState!.validate()) {
      final args = ModalRoute.of(context)!.settings.arguments as AdminModal?;

      final deviceData = TestingDeviceModal(
        id: widget.device?.id,
        deviceName: nameController.text,
        operatingSystem: widget.dialogData['operatingSystem'] ?? 'Android',
        osVersion: versionController.text,
        status: widget.dialogData['status'] ?? 'available',
        assignedToEmployeeId: widget.dialogData['assignedToEmployeeId'],
        assignedEmployeeName: widget.dialogData['assignedEmployeeName'],
        lastCheckInDate: widget.device?.lastCheckInDate,
        lastCheckOutDate: widget.device?.lastCheckOutDate,
        adminId: args?.id,
      );

      if (widget.device != null) {
        context.read<DeviceBloc>().add(UpdateDevice(deviceData));
      } else {
        context.read<DeviceBloc>().add(AddDevice(deviceData));
      }

      Navigator.pop(context);
    }
  }
}
