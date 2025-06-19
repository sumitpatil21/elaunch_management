import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Employee/employee_bloc.dart';
import '../Employee/employee_state.dart';
import '../Leave/leave_bloc.dart';
import '../Leave/leave_event.dart';
import '../Leave/leave_state.dart';
import '../Leave/leave_view.dart';

import '../Service/leave_modal.dart';
import '../service/employee_modal.dart';

class LeaveDialogs extends StatelessWidget {
  final EmployeeModal? employee;

  const LeaveDialogs({super.key, this.employee});

  @override
  Widget build(BuildContext context) {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return BlocBuilder<LeaveBloc, LeaveState>(
      builder: (context, dialogState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Apply for Leave',
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
                          'Employee: ${employee?.name ?? 'Current User'}',
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
                    value: dialogState.selectedLeaveType,
                    decoration: InputDecoration(
                      labelText: 'Leave Type',
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
                      if (value != null) {
                        context.read<LeaveBloc>().add(SelectLeaveType(value));
                        ;
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  // Date Selection Row
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => selectStartDate(context),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
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
                                  dialogState.startDate != null
                                      ? formatDate(dialogState.startDate!)
                                      : 'Select Date',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color:
                                    dialogState.startDate != null
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
                          onTap: () => selectEndDate(context),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
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
                                  dialogState.endDate != null
                                      ? formatDate(dialogState.endDate!)
                                      : 'Select Date',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color:
                                    dialogState.endDate != null
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

                  if (dialogState.duration != null) ...[
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
                            'Duration: ${dialogState.duration} '
                                '${dialogState.duration == 1 ? 'day' : 'days'}',
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

                  // Employee Selection
                  InkWell(
                    onTap: () => showEmployeeSelector(context),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.person_search, color: Colors.grey[600]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Notify Employee',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dialogState.selectedNotifyEmployee ??
                                      'Select employee',
                                  style: TextStyle(
                                    fontSize: 16,

                                    fontWeight: FontWeight.w500,
                                    color:
                                    dialogState.selectedNotifyEmployee !=
                                        null
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Reason Text Field
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
                    onChanged: (value) {
                      context.read<LeaveBloc>().add(UpdateReason(value));
                      ;
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
              onPressed:
                  () => submitLeaveApplication(
                context,
                formKey,
                reasonController.text,
                dialogState,
              ),
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

  Future<void> selectStartDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      context.read<LeaveBloc>().add(SelectStartDate(date));
    }
  }

  Future<void> selectEndDate(BuildContext context) async {
    final dialogState = context.read<LeaveBloc>().state;
    final date = await showDatePicker(
      context: context,
      initialDate: dialogState.startDate ?? DateTime.now(),
      firstDate: dialogState.startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      context.read<LeaveBloc>().add(SelectEndDate(date));
    }
  }

  void showEmployeeSelector(BuildContext context) async {
    final employeeBloc = context.read<EmployeeBloc>();

    final selectedEmployee = await showDialog<String>(
      context: context,
      builder:
          (context) => BlocProvider.value(
        value: employeeBloc,
        child: const SelectEmployee(),
      ),
    );

    if (selectedEmployee != null) {
      context.read<LeaveBloc>().add(SelectNotifyEmployee(selectedEmployee));
    }
  }

  void submitLeaveApplication(
      BuildContext context,
      GlobalKey<FormState> formKey,
      String reason,
      LeaveState dialogState,
      ) {
    if (formKey.currentState!.validate() &&
        dialogState.startDate != null &&
        dialogState.endDate != null) {
      final newLeave = LeaveModal(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        employeeName: employee?.name ?? 'Current User',
        leaveType: dialogState.selectedLeaveType,
        startDate: dialogState.startDate!,
        endDate: dialogState.endDate!,
        reason: reason,
        status: "pending",
        duration: dialogState.duration,
        approverName: 'Manager',
        employeeId: employee?.id ?? '',
        notify: dialogState.selectedNotifyEmployee ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      context.read<LeaveBloc>().add(AddLeave(newLeave));
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Leave application submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (dialogState.startDate == null || dialogState.endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select start and end dates'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class SelectEmployee extends StatelessWidget {
  const SelectEmployee({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Select Employee to Notify',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: BlocBuilder<EmployeeBloc, EmployeeState>(
          builder: (context, state) {
            return Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search employee...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child:
                  state.employees.isEmpty
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
                    itemCount: state.employees.length,
                    itemBuilder: (context, index) {
                      final emp = state.employees[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
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
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}