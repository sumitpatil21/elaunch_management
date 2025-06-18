import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../ utils/status_color_utils.dart';
import '../Device_Testing/device_bloc.dart';
import '../Device_Testing/device_dialog.dart';
import '../Device_Testing/device_event.dart';
import '../Employee/employee_bloc.dart';
import '../Employee/employee_event.dart';
import '../Service/device_modal.dart';
import '../SuperAdminLogin/admin_bloc.dart';
import '../SuperAdminLogin/admin_event.dart';

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
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SelectRole user = ModalRoute.of(context)!.settings.arguments as SelectRole;

    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 800;
    final isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple.withOpacity(0.2),
        title: Text(
          "Device Management",
          style: TextStyle(
            fontSize: isWeb ? 24 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton:
          user.adminModal != null
              ? FloatingActionButton.extended(
                backgroundColor: Colors.purple.withOpacity(0.8),
                onPressed: () {
                  final deviceBloc = context.read<DeviceBloc>();
                  final employeeBloc = context.read<EmployeeBloc>();

                  showDialog(
                    context: context,
                    builder:
                        (context) => MultiBlocProvider(
                          providers: [
                            BlocProvider.value(value: deviceBloc),
                            BlocProvider.value(value: employeeBloc),
                          ],
                          child: DeviceDialog(device: null, dialogData: {}),
                        ),
                  );
                },
                label: Text(isMobile ? "" : "Add Device"),
                icon: const Icon(Icons.add),
              )
              : null,
      body: Column(
        children: [
          buildSearchAndFilters(isWeb, isMobile),
          buildDeviceList(user, isWeb, screenWidth),
        ],
      ),
    );
  }

  Widget buildSearchAndFilters(bool isWeb, bool isMobile) {
    return BlocBuilder<DeviceBloc, DeviceState>(
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.all(isWeb ? 24.0 : 16.0),
          child: Column(
            children: [
              // Search Bar - Responsive
              Row(
                children: [
                  Expanded(
                    flex: isWeb ? 3 : 1,
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        context.read<DeviceBloc>().add(
                          SearchSystems(searchQuery: value),
                        );
                      },
                      decoration: InputDecoration(
                        labelText: "Search Devices",

                        hintText: "Enter device name...",
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
                                    context.read<DeviceBloc>().add(
                                      const SearchSystems(searchQuery: ''),
                                    );
                                  },
                                )
                                : null,
                      ),
                    ),
                  ),
                  if (isWeb) ...[
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 200,
                      child: DropdownButtonFormField<String>(
                        value: state.statusFilter,
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
                          context.read<DeviceBloc>().add(
                            FilterSystems(statusFilter: value ?? 'all'),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),

              // Status Filter Chips - Mobile Only
              if (!isWeb) ...[
                const SizedBox(height: 16),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: statusFilters.length,
                    itemBuilder: (context, index) {
                      final status = statusFilters[index];
                      final isSelected = state.statusFilter == status;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(
                            status == 'all' ? 'All' : status.toUpperCase(),
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            context.read<DeviceBloc>().add(
                              FilterSystems(statusFilter: status),
                            );
                          },
                          backgroundColor: StatusColorUtils.getStatusColor(
                            status,
                          ),
                          selectedColor: StatusColorUtils.getStatusColor(
                            status,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget buildDeviceList(SelectRole? user, bool isWeb, double screenWidth) {
    return Expanded(
      child: BlocBuilder<DeviceBloc, DeviceState>(
        builder: (context, state) {
          if (state.filteredDevices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.phone_android_outlined,
                    size: isWeb ? 80 : 60,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No devices found',
                    style: TextStyle(
                      fontSize: isWeb ? 20 : 16,
                      color: Colors.grey,
                    ),
                  ),
                  if (state.searchQuery.isNotEmpty ||
                      state.statusFilter != 'all') ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        searchController.clear();
                        // context.read<DeviceBloc>().add( ClearSearch());
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
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: state.filteredDevices.length,
              itemBuilder: (context, index) {
                final device = state.filteredDevices[index];
                return buildDeviceCard(context, device, user, isWeb);
              },
            ),
          );
        },
      ),
    );
  }

  Widget buildDeviceCard(
    BuildContext context,
    TestingDeviceModal device,
    SelectRole? user,
    bool isWebLayout,
  ) {
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
                    device.deviceName,
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
                    color: StatusColorUtils.getStatusColor(
                      device.status,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    (device.status ).toUpperCase(),
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

            detailRow(
              Icons.smartphone,
              "OS",
              "${device.operatingSystem ?? 'Unknown'} ${device.osVersion ?? ''}",
            ),
            detailRow(
              Icons.person,
              "Assigned to",
              device.assignedEmployeeName ?? 'Unassigned',
            ),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (user?.employeeModal != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Device request submitted!'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.withOpacity(0.1),
                        foregroundColor: Colors.green,
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.send, size: 16),
                      label: const Text(
                        "Request Device",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  )
                else if (user?.adminModal != null) ...[
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      final deviceBloc = context.read<DeviceBloc>();
                      final employeeBloc = context.read<EmployeeBloc>();
                      final adminBloc = context.read<AdminBloc>();

                      showDialog(
                        context: context,
                        builder:
                            (context) => MultiBlocProvider(
                              providers: [
                                BlocProvider.value(value: deviceBloc),
                                BlocProvider.value(value: employeeBloc),
                                BlocProvider.value(value: adminBloc),
                              ],
                              child: DeviceDialog(
                                device: device,
                                dialogData: {
                                  'deviceName': device.deviceName,
                                  'osVersion': device.osVersion,
                                  'operatingSystem': device.operatingSystem,
                                  'status': device.status,
                                  'assignedToEmployeeId':
                                      device.assignedToEmployeeId,
                                  'assignedEmployeeName':
                                      device.assignedEmployeeName,
                                },
                              ),
                            ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => confirmDelete(context, device),
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

  void confirmDelete(BuildContext context, TestingDeviceModal device) {
    showDialog(
      context: context,

      builder:
          (context) => AlertDialog(
            title: const Text('Delete Device'),
            content: Text(
              'Are you sure you want to delete "${device.deviceName}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<DeviceBloc>().add(DeleteDevice(device.id ?? ""));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Device deleted successfully!'),
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
