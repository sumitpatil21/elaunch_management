import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Device_Testing/device_bloc.dart';
import '../Device_Testing/device_event.dart';
import '../Employee/employee_bloc.dart';
import '../Employee/employee_state.dart';
import '../Service/device_modal.dart';

import '../SuperAdminLogin/admin_event.dart';
import '../service/employee_modal.dart';


class DeviceDialog extends StatefulWidget {
  final TestingDeviceModal? device;
  final Map<String, dynamic> dialogData;

  const DeviceDialog({super.key, this.device, required this.dialogData});

  @override
  State<DeviceDialog> createState() => _DeviceDialogState();
}

class _DeviceDialogState extends State<DeviceDialog> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController versionController;
  late Map<String, dynamic> dialogData;

  @override
  void initState() {
    super.initState();
    dialogData = {...widget.dialogData};
    nameController = TextEditingController(
      text: widget.device?.deviceName ?? widget.dialogData['deviceName'] ?? '',
    );
    versionController = TextEditingController(
      text: widget.device?.osVersion ?? widget.dialogData['osVersion'] ?? '',
    );

    if (widget.device != null) {
      dialogData = {
        'deviceName': widget.device?.deviceName ?? '',
        'osVersion': widget.device?.osVersion ?? '',
        'operatingSystem': widget.device?.operatingSystem ?? 'Android',
        'status': widget.device?.status ?? 'available',
        'assignedToEmployeeId': widget.device?.assignedToEmployeeId,
        'assignedEmployeeName': widget.device?.assignedEmployeeName,
      };
    }
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
        if (dialogData['assignedToEmployeeId'] != null &&
            dialogData['assignedToEmployeeId'] != '-1') {
          try {
            selectedEmployee = employeeState.employees.firstWhere(
              (emp) => emp.id == dialogData['assignedToEmployeeId'],
            );
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
                      setState(() {
                        dialogData['deviceName'] = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: dialogData['operatingSystem'] ?? 'Android',
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
                      setState(() {
                        dialogData['operatingSystem'] = value;
                      });
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
                      setState(() {
                        dialogData['osVersion'] = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: dialogData['status'] ?? 'available',
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
                        dialogData['status'] = value;
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
                      ...employeeState.employees.map((emp) {
                        return DropdownMenuItem<EmployeeModal>(
                          value: emp,
                          child: Text(emp.name),
                        );
                      }),
                    ],
                    onChanged: (emp) {
                      setState(() {
                        dialogData['assignedToEmployeeId'] = emp?.id;
                        dialogData['assignedEmployeeName'] = emp?.name;
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
              child: Text(widget.device != null ? "Update" : "Add"),
              onPressed: () => _handleDeviceAction(context),
            ),
          ],
        );
      },
    );
  }

  void _handleDeviceAction(BuildContext context) {
    if (formKey.currentState!.validate()) {
      final deviceBloc = context.read<DeviceBloc>();
      final args = ModalRoute.of(context)!.settings.arguments as SelectRole?;

      final deviceData = TestingDeviceModal(
        id: widget.device?.id,
        deviceName: dialogData['deviceName'],
        operatingSystem: dialogData['operatingSystem'] ?? 'Android',
        osVersion: dialogData['osVersion'],
        status: dialogData['status'] ?? 'available',
        assignedToEmployeeId: dialogData['assignedToEmployeeId'],
        assignedEmployeeName: dialogData['assignedEmployeeName'],
        lastCheckInDate: widget.device?.lastCheckInDate,
        lastCheckOutDate: widget.device?.lastCheckOutDate,
        adminId: args?.adminModal?.id,
      );

      if (widget.device != null) {
        deviceBloc.add(UpdateDevice(deviceData));
      } else {
        deviceBloc.add(AddDevice(deviceData));
      }

      Navigator.pop(context);
    }
  }
}
