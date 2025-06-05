import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Service/employee_modal.dart';
import '../Service/leave_modal.dart';
import '../SuperAdminLogin/admin_bloc.dart';
import 'leave_bloc.dart';
import 'leave_event.dart';
import 'leave_state.dart';

class LeaveView extends StatelessWidget {
  static String routeName = "/leave";

  const LeaveView({super.key});

  static Widget builder(BuildContext context) {
    return BlocProvider(
      create: (context) => LeaveBloc()..add(FetchLeaves()),
      child: const LeaveView(),
    );
  }

  @override
  Widget build(BuildContext context) {
    SelectRole? user = ModalRoute.of(context)?.settings.arguments as SelectRole;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Leave Management'),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showEmployeeSearch(context),
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => _showNotifications(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[700],
        child: const Icon(Icons.add, color: Colors.white),
        onPressed:
            () => _showAddLeaveDialog(
              context,
              user.employeeModal,
              context.read<LeaveBloc>(),
            ),
      ),
      body: Column(
        children: [
          _buildStatsCard(context),
          Expanded(
            child: BlocBuilder<LeaveBloc, LeaveState>(
              builder: (context, state) {
                if (state.leaves.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  );
                }

                if (state.leaves.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No leave requests found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<LeaveBloc>().add(FetchLeaves());
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: state.leaves.length,
                    itemBuilder:
                        (context, index) =>
                            _buildLeaveCard(context, state.leaves[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      color: Colors.green[50],
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Annual', '22', Colors.green),
            _buildStatItem('Sick', '18', Colors.orange),
            _buildStatItem('Emergency', '6', Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, Color color) {
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

  Widget _buildLeaveCard(BuildContext context, LeaveModal leave) {
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
                Chip(
                  backgroundColor: statusColor.withOpacity(0.2),
                  label: Text(
                    leave.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],

                borderRadius: BorderRadius.circular(8),
              ),
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
            if (leave.notify!.isNotEmpty) ...[
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
            if (leave.status == 'pending')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        foregroundColor: Colors.red,
                      ),
                      onPressed:
                          () => _updateLeaveStatus(context, leave, 'rejected'),
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
                          () => _updateLeaveStatus(context, leave, 'approved'),
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
                    onPressed: () => _showDeleteConfirmation(context, leave),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _updateLeaveStatus(
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
    );

    context.read<LeaveBloc>().add(UpdateLeaveStatus(updatedLeave));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Leave ${status == 'approved' ? 'approved' : 'rejected'} successfully',
        ),
        backgroundColor: status == 'approved' ? Colors.green : Colors.red,
      ),
    );
  }

  void _showEmployeeSearch(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Search Employee',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Search Employee',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: 5, // Replace with actual employee list
                      itemBuilder:
                          (context, index) => Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green[100],
                                child: Text('E${index + 1}'),
                              ),
                              title: Text('Employee ${index + 1}'),
                              subtitle: Text('ID: EMP00${index + 1}'),
                              onTap: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                    margin: const EdgeInsets.only(left: 150),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Notifications',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: 3, // Replace with actual notifications
                      itemBuilder:
                          (context, index) => Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.orange[100],
                                child: const Icon(
                                  Icons.notifications,
                                  color: Colors.orange,
                                ),
                              ),
                              title: Text('Notification ${index + 1}'),
                              subtitle: const Text(
                                'Details about the notification',
                              ),
                              trailing: const Text('2h ago'),
                            ),
                          ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, LeaveModal leave) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Delete Leave Request',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete ${leave.employeeName}\'s leave request?',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<LeaveBloc>().add(DeleteLeave(leave.id));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Leave request deleted successfully'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showAddLeaveDialog(
    BuildContext context,
    EmployeeModal? employee,
    LeaveBloc leaveBloc,
  ) {
    final formKey = GlobalKey<FormState>();
    final reasonController = TextEditingController();
    String selectedLeaveType = 'Annual Leave';
    DateTime? startDate;
    DateTime? endDate;
    String? selectedNotifyEmployee;
    List<EmployeeModal> availableEmployees =
        []; // This should come from your employee service

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                      DropdownButtonFormField<String>(
                        value: selectedLeaveType,
                        decoration: InputDecoration(
                          labelText: 'Leave Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Annual Leave',
                            child: Text('Annual Leave'),
                          ),
                          DropdownMenuItem(
                            value: 'Sick Leave',
                            child: Text('Sick Leave'),
                          ),
                          DropdownMenuItem(
                            value: 'Excuse Leave',
                            child: Text('Excuse Leave'),
                          ),
                          DropdownMenuItem(
                            value: 'Emergency Leave',
                            child: Text('Emergency Leave'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedLeaveType = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
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
                                  setState(() {
                                    startDate = date;
                                    if (endDate != null &&
                                        endDate!.isBefore(date)) {
                                      endDate = null;
                                    }
                                  });
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
                                  setState(() {
                                    endDate = date;
                                  });
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
                      // Notify Employee Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedNotifyEmployee,
                        decoration: InputDecoration(
                          labelText: 'Notify Employee (Optional)',
                          hintText: 'Select employee to notify',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('None'),
                          ),
                          ...availableEmployees.map((employee) {
                            return DropdownMenuItem<String>(
                              value: employee.name,
                              child: Text(employee.name),
                            );
                          }),
                          // Sample employees for demonstration
                          const DropdownMenuItem<String>(
                            value: 'John Doe',
                            child: Text('John Doe'),
                          ),

                          const DropdownMenuItem<String>(
                            value: 'Jane Smith',
                            child: Text('Jane Smith'),
                          ),
                          const DropdownMenuItem<String>(
                            value: 'Mike Johnson',
                            child: Text('Mike Johnson'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedNotifyEmployee = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
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
                      );

                      leaveBloc.add(AddLeave(newLeave));
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Leave application submitted successfully!',
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
      },
    );
  }
}

// Helper functions
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

String _getStatusText(String status) {
  switch (status.toLowerCase()) {
    case 'approved':
      return 'Approved';
    case 'rejected':
      return 'Rejected';
    case 'pending':
      return 'Pending';
    default:
      return 'Unknown';
  }
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}
