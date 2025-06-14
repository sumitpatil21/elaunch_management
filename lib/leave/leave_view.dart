import 'package:elaunch_management/Employee/employee_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../Leave/leave_event.dart';
import '../Leave/leave_state.dart';
import '../Service/leave_modal.dart';
import '../SuperAdminLogin/admin_event.dart';
import '../service/employee_modal.dart';
import 'leave_bloc.dart';


class LeaveView extends StatelessWidget {
  static String routeName = "/leave";

  const LeaveView({super.key});

  static Widget builder(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LeaveBloc()..add(FetchLeaves())),
        BlocProvider(
          create: (context) => EmployeeBloc()..add(LoadEmployees()),
        ),
      ],
      child: const LeaveView(),
    );
  }

  @override
  Widget build(BuildContext context) {
    SelectRole user =
        ModalRoute.of(context)?.settings.arguments as SelectRole;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.withOpacity(0.2),
        title: const Text('leave Management'),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green.withOpacity(0.2),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed:
            () => showAddLeaveDialog(
              context,
              user.employeeModal,
              context.read<LeaveBloc>(),
              context.read<EmployeeBloc>(),
            ),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            color: Colors.green.withOpacity(0.2),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  staticItem('Annual', '22', Colors.green),
                  staticItem('Sick', '18', Colors.orange),
                  staticItem('Emergency', '6', Colors.red),
                ],
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<LeaveBloc, LeaveState>(
              builder: (context, state) {
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<LeaveBloc>().add(FetchLeaves());
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: state.leaves.length,
                    itemBuilder:
                        (context, index) =>
                            buildLeaveCard(context, state.leaves[index], user),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget staticItem(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget buildLeaveCard(
    BuildContext context,
    LeaveModal leave,
    SelectRole? user,
  ) {
    final statusColor = _getStatusColor(leave.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        leave.employeeName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        leave.reason,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                FilterChip(
                  backgroundColor: statusColor.withOpacity(0.2),
                  label: Text(
                    leave.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onSelected: (bool value) {},
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${_formatDate(leave.startDate)} - ${_formatDate(leave.endDate)}',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${leave.duration} ${leave.duration == 1 ? 'day' : 'days'}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            if (leave.reason.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Reason:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                leave.reason,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
            if (leave.notify != null && leave.notify!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Notify: ${leave.notify}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            if (leave.status == 'pending' && user?.adminModal != null)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        foregroundColor: Colors.red,
                      ),
                      onPressed:
                          () => updateLeaveStatus(context, leave, 'rejected'),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed:
                          () => updateLeaveStatus(context, leave, 'approved'),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Approve'),
                    ),
                  ),
                ],
              ),
            if (leave.status != 'pending')
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      context.read<LeaveBloc>().add(DeleteLeave(leave.id));
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void updateLeaveStatus(
    BuildContext context,
    LeaveModal leave,
    String status,
  ) {
    final updatedLeave = LeaveModal(
      id: leave.id,
      employeeName: leave.employeeName,
      leaveType: leave.leaveType,
      startDate: leave.startDate,
      endDate: leave.endDate,
      reason: leave.reason,
      status: status,
      duration: leave.duration,
      approverName: leave.approverName,
      employeeId: leave.employeeId,
      notify: leave.notify,
      createdAt: leave.createdAt,
      updatedAt: DateTime.now(),
    );

    context.read<LeaveBloc>().add(UpdateLeaveStatus(updatedLeave));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'leave ${status == 'approved' ? 'approved' : 'rejected'} successfully',
        ),
        backgroundColor: status == 'approved' ? Colors.green : Colors.red,
      ),
    );
  }

  void showAddLeaveDialog(
    BuildContext context,
    EmployeeModal? employee,
    LeaveBloc leaveBloc,
    EmployeeBloc employeeBloc,
  ) {
    final formKey = GlobalKey<FormState>();
    final reasonController = TextEditingController();
    String selectedLeaveType = 'Annual leave';
    DateTime? startDate;
    DateTime? endDate;
    String? selectedNotifyEmployee;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Apply for leave',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Employee Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'employee: ${employee?.name ?? 'Current User'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${employee?.id ?? 'N/A'}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Leave Type Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedLeaveType,
                    decoration: InputDecoration(
                      labelText: 'leave Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Annual leave',
                        child: Text('Annual leave'),
                      ),
                      DropdownMenuItem(
                        value: 'Sick leave',
                        child: Text('Sick leave'),
                      ),
                      DropdownMenuItem(
                        value: 'Excuse leave',
                        child: Text('Excuse leave'),
                      ),
                      DropdownMenuItem(
                        value: 'Emergency leave',
                        child: Text('Emergency leave'),
                      ),
                    ],
                    onChanged: (value) {

                        selectedLeaveType = value!;

                    },
                  ),
                  const SizedBox(height: 20),

                  // Date Selection
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                            );

                            if (date != null) {

                                startDate = date;
                                if (endDate != null &&
                                    endDate!.isBefore(date)) {
                                  endDate = null;
                                }

                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.shade300,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Start Date',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  startDate != null
                                      ? _formatDate(startDate!)
                                      : 'Select Date',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color:
                                    startDate != null
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: startDate ?? DateTime.now(),
                              firstDate: startDate ?? DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                            );
                            if (date != null) {

                                endDate = date;

                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.shade300,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'End Date',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  endDate != null
                                      ? _formatDate(endDate!)
                                      : 'Select Date',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color:
                                    endDate != null
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (startDate != null && endDate != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue[600],
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Duration: ${endDate!.difference(startDate!).inDays + 1} ${endDate!.difference(startDate!).inDays + 1 == 1 ? 'day' : 'days'}',
                            style: TextStyle(
                              color: Colors.blue[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Employee Notification Selection
                  InkWell(
                    onTap: () async {
                      final result = await showEmployeeSelectionDialog(
                        context,
                        employeeBloc.state.employees.cast<EmployeeModal>(),
                      );
                      if (result != null) {

                          selectedNotifyEmployee = result;

                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_search,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Notify employee',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  selectedNotifyEmployee ??
                                      'Select employee',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color:
                                    selectedNotifyEmployee != null
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Reason Field
                  TextFormField(
                    controller: reasonController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Reason for leave',
                      hintText: 'Enter your reason here...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter reason for leave';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(fontSize: 16)),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate() &&
                    startDate != null &&
                    endDate != null) {
                  final duration =
                      endDate!.difference(startDate!).inDays + 1;
                  final newLeave = LeaveModal(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    employeeName: employee?.name ?? 'Current User',
                    leaveType: selectedLeaveType,
                    startDate: startDate!,
                    endDate: endDate!,
                    reason: reasonController.text,
                    status: "pending",

                    duration: duration,
                    approverName: 'Manager',
                    employeeId: employee?.id ?? '',
                    notify: selectedNotifyEmployee ?? '',
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );

                  leaveBloc.add(AddLeave(newLeave));
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'leave application submitted successfully!',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (startDate == null || endDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select start and end dates'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Submit Application',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<String?> showEmployeeSelectionDialog(
    BuildContext context,
    List<EmployeeModal> employees,
  ) async {
    String searchQuery = '';

    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
           final filteredEmployees =
        employees
            .where(
              (emp) => emp.name.toLowerCase().contains(
            searchQuery.toLowerCase(),
          ),
        )
            .toList();

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Select employee to Notify',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Column(
              children: [
                // Search Field
                TextField(
                  onChanged: (value) {

                      searchQuery = value;

                  },
                  decoration: InputDecoration(
                    hintText: 'Search employee...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),

                  ),
                ),
                const SizedBox(height: 16),

                // Employee List
                Expanded(
                  child:
                  filteredEmployees.isEmpty
                      ? const Center(
                    child: Text(
                      'No employees found',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  )
                      : ListView.builder(
                    itemCount: filteredEmployees.length,
                    itemBuilder: (context, index) {
                      final emp = filteredEmployees[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(
                          vertical: 4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green[100],
                            child: Text(
                              emp.name.isNotEmpty
                                  ? emp.name[0].toUpperCase()
                                  : 'E',
                              style: TextStyle(
                                color: Colors.green[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            emp.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            emp.email,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey[400],
                          ),
                          onTap: () {
                            Navigator.pop(context, emp.name);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}


Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'approved':
      return Colors.green;
    case 'rejected':
      return Colors.red;
    case 'pending':
      return Colors.orange;
    default:
      return Colors.grey;
  }
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}
