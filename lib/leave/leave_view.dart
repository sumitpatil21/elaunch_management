

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../ utils/status_color_utils.dart';
import '../Employee/employee_bloc.dart';
import '../Employee/employee_event.dart';
import '../Leave/leave_bloc.dart';
import '../Leave/leave_event.dart';
import '../Leave/leave_state.dart';
import '../Service/leave_modal.dart';
import '../SuperAdminLogin/admin_event.dart';
import 'leave_dialog.dart';

class LeaveView extends StatelessWidget {
  static String routeName = "/leave";

  const LeaveView({super.key});

  static Widget builder(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LeaveBloc()..add(FetchLeaves())),
        BlocProvider(
          create: (context) => EmployeeBloc()..add(FetchEmployees()),
        ),
      ],
      child: const LeaveView(),
    );
  }

  @override
  Widget build(BuildContext context) {
    SelectRole user = ModalRoute.of(context)?.settings.arguments as SelectRole;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.withOpacity(0.2),
        title: const Text('Leave Management'),
        elevation: 0,
      ),
      // Only show FAB for employees, not admins
      floatingActionButton:
          (user.employeeModal != null && user.selectedRole != 'Admin')
              ? FloatingActionButton(
                backgroundColor: Colors.green.withOpacity(0.2),
                child: const Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  final employeeBloc = context.read<EmployeeBloc>();
                  final leaveBloc = context.read<LeaveBloc>();
                  showDialog(
                    context: context,
                    builder:
                        (context) => MultiBlocProvider(
                          providers: [
                            BlocProvider.value(value: leaveBloc),
                            BlocProvider.value(value: employeeBloc),
                            BlocProvider(create: (context) => LeaveBloc()),
                          ],
                          child: LeaveDialogs(employee: user.employeeModal),
                        ),
                  );
                },
              )
              : null,
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
    final statusColor = StatusColorUtils.getStatusColor(leave.status);

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
                    '${formatDate(leave.startDate)} - ${formatDate(leave.endDate)}',
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
            // Only show approve/reject buttons if user is admin and leave is pending
            if (leave.status == 'pending' &&
                user?.adminModal != null &&
                user?.selectedRole == 'Admin')
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
          'Leave ${status == 'approved' ? 'approved' : 'rejected'} successfully',
        ),
        backgroundColor: status == 'approved' ? Colors.green : Colors.red,
      ),
    );
  }
}

String formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}


