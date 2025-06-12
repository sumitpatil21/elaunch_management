
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
          create: (context) => EmployeeBloc()..add(LoadEmployees()),
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
    SelectRole? user =
        ModalRoute.of(context)!.settings.arguments as SelectRole?;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple.withOpacity(0.2),
        title: const Text("Device"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.purple.withOpacity(0.2),
        onPressed:
            () => showDeviceDialog(
              context,
              employeeBloc: context.read<EmployeeBloc>()..add(LoadEmployees()),
              deviceBloc: context.read<DeviceBloc>(),
            ),
        label: const Text("Add Device"),
        icon: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Search",
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
          ),
          // Status Filter Chips
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

          Expanded(
            child: BlocBuilder<DeviceBloc, DeviceState>(
              builder: (context, state) {
                final query = searchController.text.toLowerCase();

                final filteredDevices =
                    state.devices.where((device) {
                      final matchesSearch =
                          device.deviceName.toLowerCase().contains(query) ||
                          (device.osVersion?.toLowerCase().contains(query) ??
                              false) ||
                          (device.assignedEmployeeName?.toLowerCase().contains(
                                query,
                              ) ??
                              false) ||
                          (device.operatingSystem?.toLowerCase().contains(
                                query,
                              ) ??
                              false);

                      final matchesStatus =
                          selectedStatusFilter == 'all' ||
                          (device.status ?? 'available') ==
                              selectedStatusFilter;

                      return matchesSearch && matchesStatus;
                    }).toList();

                if (filteredDevices.isEmpty) {
                  return Center(
                    child: Text(
                      searchController.text.isNotEmpty
                          ? 'No results for "${searchController.text}"'
                          : 'No Devices found',
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredDevices.length,
                  itemBuilder: (context, index) {
                    final device = filteredDevices[index];
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
                      confirmDismiss:
                          (_) => showDialog(
                            context: context,
                            builder:
                                (_) => AlertDialog(
                                  title: const Text("Confirm Delete"),
                                  content: Text(
                                    "Are you sure you want to delete ${device.deviceName} device?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, false),
                                      child: const Text("CANCEL"),
                                    ),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      onPressed:
                                          () => Navigator.pop(context, true),
                                      child: const Text("DELETE"),
                                    ),
                                  ],
                                ),
                          ),
                      onDismissed: (_) {
                        context.read<DeviceBloc>().add(
                          DeleteDevice(id: device.id ?? ""),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("${device.deviceName} deleted"),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: getStatusColor(
                              device.status ?? 'available',
                            ),
                            child: const Icon(Icons.phone_android),
                          ),
                          title: Text(
                            device.deviceName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${device.operatingSystem ?? ''} ${device.osVersion ?? ''}",
                              ),
                              Text(
                                "Assigned to: ${device.assignedEmployeeName ?? 'Unassigned'}",
                              ),

                              Row(
                                children: [
                                  const Text("Status:"),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: getStatusColor(
                                        device.status ?? 'available',
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      (device.status ?? 'available')
                                          .toUpperCase(),
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
                                      showDeviceDialog(
                                        context,
                                        device: device,
                                        employeeBloc:
                                            context.read<EmployeeBloc>()
                                              ..add(LoadEmployees()),
                                        deviceBloc: context.read<DeviceBloc>(),
                                      );
                                    },
                                  )
                                  : ElevatedButton(
                                    onPressed: () {},
                                    child: Text(
                                      "Apply",
                                      style: TextStyle(color: Colors.green),
                                    ),
                                  ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
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

  void showDeviceDialog(
    BuildContext context, {
    TestingDeviceModal? device,
    required EmployeeBloc employeeBloc,
    required DeviceBloc deviceBloc,
  }) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final versionController = TextEditingController();
    final unassignedEmployee = EmployeeModal(
      id: "",
      name: "Unassigned",
      email: '',
      password: '',
      address: '',
      role: "",
      departmentId: "1",
      adminId: "1",
    );

    String selectedEmployee = unassignedEmployee.name;
    String selectedStatus = device?.status ?? 'available';
    String selectedOS = device?.status ?? 'Android';

    SelectRole? args =
        ModalRoute.of(context)!.settings.arguments as SelectRole?;

    if (device != null) {
      nameController.text = device.deviceName;
      versionController.text = device.osVersion ?? '';
      selectedStatus = device.status ?? 'available';
      selectedOS = device.operatingSystem ?? 'Android';

      // if (device.assignedToEmployeeId != null) {
      //   selectedEmployee = employeeBloc.state.employees.firstWhere(
      //     (emp) => emp.id == device.assignedToEmployeeId,
      //   ) as String ;
      // }
    }

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(device != null ? 'Edit Device' : 'Add Device'),
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
                                value == null || value.isEmpty
                                    ? 'Please enter a device name'
                                    : null,
                        decoration: const InputDecoration(
                          labelText: "Device Name",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedOS,
                        decoration: const InputDecoration(
                          labelText: "Operating system",
                          border: OutlineInputBorder(),
                        ),
                        items:
                            ['Android', 'iOS']
                                .map(
                                  (os) => DropdownMenuItem(
                                    value: os,
                                    child: Text(os),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedOS = value ?? 'Android';
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: versionController,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Please enter OS version'
                                    : null,
                        decoration: const InputDecoration(
                          labelText: "OS Version",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedStatus,
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
                            selectedStatus = value ?? 'available';
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      const Text("Select employee (Optional)"),
                      const SizedBox(height: 12),
                      // DropdownButtonFormField<String>(
                      //   value: selectedEmployee,
                      //   decoration: const InputDecoration(
                      //     labelText: "employee",
                      //     border: OutlineInputBorder(),
                      //   ),
                      //   // items: [
                      //   //   DropdownMenuItem<String>(
                      //   //     value: unassignedEmployee.name,
                      //   //     child: const Text("Unassigned"),
                      //   //   ),
                      //   //   ...employeeBloc.state.employees.map((emp) {
                      //   //     return DropdownMenuItem<String>(
                      //   //       value: emp['name'],
                      //   //       child: Text(emp.name),
                      //   //     );
                      //   //   }),
                      //   // ],
                      //   onChanged: (emp) {
                      //     setState(() {
                      //       selectedEmployee =emp ?? unassignedEmployee.name;
                      //     });
                      //   },
                      // ),
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
                  child: Text(device != null ? "Update" : "Add"),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final deviceData = TestingDeviceModal(
                        id: device?.id,
                        deviceName: nameController.text,
                        operatingSystem: selectedOS,
                        osVersion: versionController.text,
                        status: selectedStatus,
                        assignedToEmployeeId: selectedEmployee,
                        assignedEmployeeName: selectedEmployee,
                        lastCheckInDate: device?.lastCheckInDate,
                        lastCheckOutDate: device?.lastCheckOutDate,
                        adminId: args?.adminModal?.id,
                      );

                      if (device != null) {
                        deviceBloc.add(UpdateDevice(deviceData));
                      } else {
                        deviceBloc.add(AddDevice(deviceData));
                      }
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
