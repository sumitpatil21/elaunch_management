import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:elaunch_management/Service/system_modal.dart';
import 'package:elaunch_management/System/system_bloc.dart';
import 'package:elaunch_management/System/system_event.dart';
import 'package:elaunch_management/employee/employee_bloc.dart';
import 'package:elaunch_management/service/employee_modal.dart';

import '../ utils/status_color_utils.dart';

class RequestDialog extends StatefulWidget {
  final List<SystemModal> requests;
  final bool isWeb;

  const RequestDialog({super.key, required this.requests, required this.isWeb});

  @override
  State<RequestDialog> createState() => _RequestDialogState();
}

class _RequestDialogState extends State<RequestDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.pending_actions, color: Colors.orange),
          const SizedBox(width: 8),
          Text('Pending Requests (${widget.requests.length})'),
        ],
      ),
      content: SizedBox(
        width: widget.isWeb ? 600 : double.maxFinite,
        height: widget.isWeb ? 500 : 400,
        child:
            widget.requests.isEmpty
                ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No pending requests',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
                : ListView.builder(
                  itemCount: widget.requests.length,
                  itemBuilder: (context, index) {
                    final request = widget.requests[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Icon(
                          Icons.computer,
                          color: StatusColorUtils.getStatusColor('pending'),
                        ),
                        title: Text(
                          request.systemName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Requested by: ${request.requestedByName ?? 'Unknown'}',
                            ),
                            if (request.requestedAt != null)
                              Text(
                                'Date: ${formatDate(request.requestedAt!)}',
                              ),
                            Text('OS: ${request.operatingSystem ?? 'Unknown'}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                              onPressed: () => approveRequest(request),
                              tooltip: 'Approve',
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              onPressed: () => rejectRequest(request),
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
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  void approveRequest(SystemModal request) {
    context.read<SystemBloc>().add(
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
  showSnackBar(
      context,
      'Request approved successfully!',
      Colors.green,
    );
  }

  void rejectRequest(SystemModal request) {
    context.read<SystemBloc>().add(
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
    showSnackBar(context, 'Request rejected', Colors.orange);
  }
}


class SystemFormDialog extends StatefulWidget {
  static const String routeName = '/system-form';
  final SystemModal? system;
  final String? adminId;


  const SystemFormDialog({
    Key? key,
    this.system,
    this.adminId,

  }) : super(key: key);
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

        BlocProvider(create: (context) => EmployeeBloc()..add(const FetchEmployees())),
      ],
      child:  SystemFormDialog(),
    );
  }
  @override
  State<SystemFormDialog> createState() => _SystemFormDialogState();
}

class _SystemFormDialogState extends State<SystemFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _versionController = TextEditingController();

  late EmployeeModal _selectedEmployee;
  late String _selectedStatus;
  late String _selectedOS;
  late EmployeeModal _unassignedEmployee;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    _unassignedEmployee = EmployeeModal(
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

    _selectedEmployee = _unassignedEmployee;
    _selectedStatus = 'available';
    _selectedOS = 'Windows';

    if (widget.system != null) {
      _nameController.text = widget.system!.systemName;
      _versionController.text = widget.system!.version ?? '';
      _selectedStatus = widget.system!.status ?? 'available';
      _selectedOS = widget.system!.operatingSystem ?? 'Windows';

      if (widget.system!.employeeId != null) {
        final employeeBloc = context.read<EmployeeBloc>();
        try {
          _selectedEmployee = employeeBloc.state.employees.firstWhere(
            (emp) => emp.id == widget.system!.employeeId,
            orElse: () => _unassignedEmployee,
          );
        } catch (e) {
          _selectedEmployee = _unassignedEmployee;
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _versionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(widget.system != null ? Icons.edit : Icons.add),
          const SizedBox(width: 8),
          Text(widget.system != null ? 'Edit System' : 'Add System'),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // System Name Field
                TextFormField(
                  controller: _nameController,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Please enter a system name'
                              : null,
                  decoration: const InputDecoration(
                    labelText: "System Name",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.computer),
                  ),
                ),
                const SizedBox(height: 16),

                // Operating System Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedOS,
                  decoration: const InputDecoration(
                    labelText: "Operating System",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.settings),
                  ),
                  items:
                      ['Windows', 'macOS', 'Linux']
                          .map(
                            (os) =>
                                DropdownMenuItem(value: os, child: Text(os)),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedOS = value ?? 'Windows';
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Version Field
                TextFormField(
                  controller: _versionController,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Please enter a version'
                              : null,
                  decoration: const InputDecoration(
                    labelText: "Version",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.info),
                  ),
                ),
                const SizedBox(height: 16),

                // Status Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: "Status",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.circle),
                  ),
                  items:
                      ['available', 'assigned', 'maintenance', 'retired']
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: StatusColorUtils.getStatusColor(
                                        status,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(status.toUpperCase()),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value ?? 'available';
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Employee Assignment Dropdown
                BlocBuilder<EmployeeBloc, dynamic>(
                  builder: (context, employeeState) {
                    return DropdownButtonFormField<EmployeeModal?>(
                      value: _selectedEmployee,
                      decoration: const InputDecoration(
                        labelText: "Assign Employee",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      items: [
                        DropdownMenuItem<EmployeeModal?>(
                          value: _unassignedEmployee,
                          child: const Text("Unassigned"),
                        ),
                        ...employeeState.employees
                            .map<DropdownMenuItem<EmployeeModal?>>((emp) {
                              return DropdownMenuItem<EmployeeModal?>(
                                value: emp,
                                child: Text(emp.name),
                              );
                            }),
                      ],
                      onChanged: (emp) {
                        setState(() {
                          _selectedEmployee = emp ?? _unassignedEmployee;
                        });
                      },
                    );
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
          icon: Icon(widget.system != null ? Icons.update : Icons.add),
          label: Text(widget.system != null ? "Update" : "Add"),
          onPressed: _submitForm,
        ),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final systemBloc = context.read<SystemBloc>();

      if (widget.system != null) {
        systemBloc.add(
          UpdateSystem(
            system: SystemModal(
              id: widget.system!.id,
              systemName: _nameController.text.trim(),
              version: _versionController.text.trim(),
              status: _selectedStatus,
              operatingSystem: _selectedOS,
              employeeName:
                  _selectedEmployee.id == '-1' ? null : _selectedEmployee.name,
              employeeId:
                  _selectedEmployee.id == '-1' ? null : _selectedEmployee.id,
              adminId: widget.adminId,
            ),
          ),
        );
       showSnackBar(
          context,
          'System updated successfully!',
          Colors.blue,
        );
      } else {
        // Add new system
        systemBloc.add(
          AddSystem(
            systemName: _nameController.text.trim(),
            version: _versionController.text.trim(),
            status: _selectedStatus,
            operatingSystem: _selectedOS,
            employeeName:
                _selectedEmployee.id == '-1' ? null : _selectedEmployee.name,
            employeeId:
                _selectedEmployee.id == '-1' ? null : _selectedEmployee.id,
            adminId: widget.adminId,
          ),
        );
        showSnackBar(
          context,
          'System added successfully!',
          Colors.green,
        );
      }
      Navigator.pop(context);
    }
  }
}
 String formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

   void showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
