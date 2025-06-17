import 'dart:developer';

import 'package:elaunch_management/System/system_event.dart';
import 'package:elaunch_management/System/system_state.dart';
import 'package:elaunch_management/system/system_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:elaunch_management/Service/system_modal.dart';
import 'package:elaunch_management/SuperAdminLogin/admin_bloc.dart';
import 'package:elaunch_management/System/system_bloc.dart';

import '../ utils/status_color_utils.dart';
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
          create:
              (context) =>
                  SystemBloc()
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


  @override
  Widget build(BuildContext context) {
    SelectRole? loginEmployee =
        ModalRoute.of(context)!.settings.arguments as SelectRole?;

    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 800;
    final isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow.withOpacity(0.2),
        title: Text(
          "System Management",
          style: TextStyle(
            fontSize: isWeb ? 24 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (loginEmployee?.adminModal != null)
            BlocBuilder<SystemBloc, SystemState>(
              builder: (context, state) {
                final requestCount = state.requests.length;
                return Stack(
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        final employeeBloc = context.read<EmployeeBloc>();
                        final systemBloc = context.read<SystemBloc>();

                        showDialog(
                          context: context,
                          builder:
                              (context) => MultiBlocProvider(
                            providers: [
                              BlocProvider.value(value: systemBloc),
                              BlocProvider.value(value: employeeBloc),
                            ],
                            child: RequestDialog(
                              isWeb: isWeb,
                              requests: state.requests,

                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.inbox, color: Colors.yellow),
                      label: Text(
                        isMobile ? "" : "Requests",
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
      ),
      floatingActionButton:
          loginEmployee?.adminModal != null
              ? FloatingActionButton.extended(
                backgroundColor: Colors.yellow.withOpacity(0.8),
            onPressed: () {
              final employeeBloc = context.read<EmployeeBloc>();
              final systemBloc = context.read<SystemBloc>();

              showDialog(
                context: context,
                builder:
                    (context) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: systemBloc),
                    BlocProvider.value(value: employeeBloc),
                  ],
                  child: SystemFormDialog(
                    adminId: loginEmployee?.adminModal?.id,
                  ),
                ),
              );
            },
                label: Text(isMobile ? "" : "Add System"),
                icon: const Icon(Icons.add),
              )
              : null,
      body: Column(
        children: [
          // Search Bar - Responsive
          Container(
            padding: EdgeInsets.all(isWeb ? 24.0 : 16.0),
            child: Row(
              children: [
                Expanded(
                  flex: isWeb ? 3 : 1,
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: "Search Systems",
                      hintText: "Enter system name...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon:
                          searchController.text.isNotEmpty
                              ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  searchController.clear();
                                  setState(() {});
                                },
                              )
                              : null,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                if (isWeb) ...[
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 200,
                    child: DropdownButtonFormField<String>(
                      value: selectedStatusFilter,
                      decoration: InputDecoration(
                        labelText: "Filter by Status",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items:
                          statusFilters.map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(
                                status == 'all'
                                    ? 'All Status'
                                    : status.toUpperCase(),
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedStatusFilter = value ?? 'all';
                        });
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Status Filter Chips - Mobile Only
          if (!isWeb)
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
                      backgroundColor: StatusColorUtils.getStatusColor(status),
                      selectedColor: StatusColorUtils.getStatusColor(status),
                    ),
                  );
                },
              ),
            ),

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
                  return Center(
                    child: Column(

                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.computer_outlined,
                          size: isWeb ? 80 : 60,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No systems found',
                          style: TextStyle(
                            fontSize: isWeb ? 20 : 16,
                            color: Colors.grey,
                          ),
                        ),
                        if (searchController.text.isNotEmpty ||
                            selectedStatusFilter != 'all') ...[
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              searchController.clear();
                              setState(() {
                                selectedStatusFilter = 'all';
                              });
                            },
                            child: const Text('Clear Filters'),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: GridView.builder(

                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(

                        crossAxisCount: screenWidth > 1200 ? 3 : 1,
                        childAspectRatio: 1.5,
                        crossAxisSpacing: 1,
                        mainAxisSpacing: 1,
                      ),
                      itemCount: filteredSystems.length,
                      itemBuilder: (context, index) {
                        final system = filteredSystems[index];
                        return systemCard(
                          context,
                          system,
                          loginEmployee,
                          true,
                        );
                      },
                    ),
                  );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget systemCard(
    BuildContext context,
    SystemModal system,
    SelectRole? loginEmployee,
    bool isWebLayout,
  ) {
    final isAlreadyRequested =
        system.isRequested == true &&
        system.requestId == loginEmployee?.employeeModal?.id;

    return Card(
      elevation: isWebLayout ? 4 : 2,
      margin: EdgeInsets.only(bottom: isWebLayout ? 12 : 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    system.systemName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isWebLayout ? 18 : 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: StatusColorUtils.getStatusColor(system.status ?? 'available'),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    (system.status ?? 'available').toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // System Details
            detailRow(
              Icons.memory,
              "OS",
              system.operatingSystem ?? 'Unknown',
            ),
            detailRow(
              Icons.info_outline,
              "Version",
              system.version ?? 'Unknown',
            ),
            detailRow(
              Icons.person,
              "Assigned to",
              system.employeeName ?? 'Unassigned',
            ),

            if (system.isRequested == true &&
                system.requestedByName != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.pending_actions,
                      size: 16,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Requested by: ${system.requestedByName}",
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const Spacer(),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (loginEmployee?.employeeModal != null &&
                    (system.status == 'available' || isAlreadyRequested))
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          isAlreadyRequested
                              ? () => cancelRequest(
                                context,
                                system,
                                loginEmployee!,
                              )
                              : () => submitRequest(
                                context,
                                system,
                                loginEmployee!,
                              ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isAlreadyRequested
                                ? Colors.red.withOpacity(0.1)
                                : Colors.green.withOpacity(0.1),
                        foregroundColor:
                            isAlreadyRequested ? Colors.red : Colors.green,
                        elevation: 0,
                      ),
                      icon: Icon(
                        isAlreadyRequested ? Icons.cancel : Icons.send,
                        size: 16,
                      ),
                      label: Text(
                        isAlreadyRequested
                            ? "Cancel Request"
                            : "Request System",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  )
                else if (loginEmployee?.adminModal != null) ...[
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      final employeeBloc = context.read<EmployeeBloc>();
                      final systemBloc = context.read<SystemBloc>();

                      showDialog(
                        context: context,
                        builder:
                            (context) => MultiBlocProvider(
                          providers: [
                            BlocProvider.value(value: systemBloc),
                            BlocProvider.value(value: employeeBloc),
                          ],
                          child: SystemFormDialog(
                            system: system,
                            adminId: loginEmployee?.adminModal?.id,
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => confirmDelete(context, system),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
              fontSize: 12,
            ),
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

  void submitRequest(BuildContext context, SystemModal system, SelectRole loginEmployee,) {
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Request submitted successfully!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void cancelRequest(BuildContext context, SystemModal system, SelectRole loginEmployee,) {
    context.read<SystemBloc>().add(
      CancelRequest(
        requestId: loginEmployee.employeeModal!.id ?? "",
        systemId: system.id!,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Request cancelled successfully!'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void confirmDelete(BuildContext context, SystemModal system) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete System'),
            content: Text(
              'Are you sure you want to delete "${system.systemName}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<SystemBloc>().add(DeleteSystem(id: system.id!));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('System deleted successfully!'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

}
