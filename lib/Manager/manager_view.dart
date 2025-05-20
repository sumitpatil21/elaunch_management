import 'package:elaunch_management/Dashboard/splaceScreen.dart';
import 'package:elaunch_management/Department/department_bloc.dart';
import 'package:elaunch_management/Employee/employee_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../Service/department_modal.dart';
import '../Service/manger_modal.dart';
import 'manager_bloc.dart';

class ManagerScreen extends StatefulWidget {
  static String routeName = "/manager";

  const ManagerScreen({super.key});

  static Widget builder(BuildContext context) {
    final arguments =
        ModalRoute.of(context)?.settings.arguments as ManagerScreenArguments?;

    if (arguments == null) {
      return const Scaffold(body: Center(child: Text('Invalid arguments')));
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) => ManagerBloc(ManagerState())..add(
                FetchManagers(
                  departmentId: arguments.departmentId,
                  adminId: arguments.adminId ?? 1,
                ),
              ),
        ),
        BlocProvider(
          create:
              (context) =>
                  DepartmentBloc(DepartmentState())
                    ..add(FetchDepartments(adminId: arguments.adminId)),
        ),
      ],
      child: const ManagerScreen(),
    );
  }

  @override
  State<ManagerScreen> createState() => _ManagerScreenState();
}

class _ManagerScreenState extends State<ManagerScreen> {
  final TextEditingController _searchController = TextEditingController();

  String get searchText => _searchController.text.trim();
  DepartmentModal? selectedDepartment;

  @override
  Widget build(BuildContext context) {
    final departments = context.watch<DepartmentBloc>().state.departments;
    final arguments =
        ModalRoute.of(context)?.settings.arguments as ManagerScreenArguments?;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.withOpacity(0.2),
        title: Text(
          selectedDepartment != null
              ? "Managers - ${selectedDepartment!.name}"
              : "Managers  ${arguments?.department?.name ?? ""}",
        ),
        actions: [
          PopupMenuButton<int?>(
            icon: const Icon(Icons.filter_list),
            itemBuilder:
                (_) => [
                  const PopupMenuItem<int?>(
                    value: null,
                    child: Text('All Managers'),
                  ),
                  ...departments
                      .map(
                        (dept) => PopupMenuItem<int?>(
                          value: dept.id,
                          child: Text(dept.name),
                        ),
                      )
                      .toList(),
                ],
            onSelected: (departmentId) {
              setState(() {
                selectedDepartment =
                    departmentId != null
                        ? departments.firstWhere((d) => d.id == departmentId)
                        : null;
              });
              context.read<ManagerBloc>().add(
                FetchManagers(
                  departmentId: departmentId,

                  adminId:
                      selectedDepartment?.id_admin ?? arguments?.adminId ?? 1,
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green.withOpacity(0.2),
        onPressed: () => showManagerDialog(context),
        label: Text("Add Manager"),
        icon: Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Search",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search),
                filled: true,

                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.green, width: 1),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                ),
              ),

              onChanged: (query) {
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<ManagerBloc, ManagerState>(
              builder: (context, state) {
                if (state.managers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.supervised_user_circle,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text("No managers found"),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            final arguments =
                                ModalRoute.of(context)?.settings.arguments
                                    as ManagerScreenArguments?;
                            context.read<ManagerBloc>().add(
                              FetchManagers(
                                departmentId: selectedDepartment?.id,
                                adminId:
                                    selectedDepartment?.id_admin ??
                                    arguments?.adminId ??
                                    1,
                              ),
                            );
                          },
                          child: const Text("Refresh"),
                        ),
                      ],
                    ),
                  );
                }

                final filteredManagers =
                    searchText.isEmpty
                        ? state.managers
                        : state.managers
                            .where(
                              (manager) =>
                                  manager.managerName.toLowerCase().contains(
                                    searchText.toLowerCase(),
                                  ) ||
                                  (manager.email.toLowerCase().contains(
                                    searchText.toLowerCase(),
                                  )) ||
                                  (manager.departmentName
                                          ?.toLowerCase()
                                          .contains(searchText.toLowerCase()) ??
                                      false),
                            )
                            .toList();

                if (filteredManagers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text("No results for \"$searchText\""),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          child: const Text("Clear Search"),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredManagers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final manager = filteredManagers[index];
                    return Dismissible(
                      key: Key(manager.id.toString()),
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
                                    "Are you sure you want to delete ${manager.managerName}?",
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
                        context.read<ManagerBloc>().add(
                          DeleteManager(manager.id),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("${manager.managerName} deleted"),
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
                            backgroundColor: Colors.green.withOpacity(0.2),
                            child: Text(manager.managerName[0].toUpperCase()),
                          ),
                          title: Text(
                            manager.managerName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(manager.email),
                              if (manager.departmentName != null)
                                Text(manager.departmentName!),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed:
                                    () => showManagerDialog(
                                      context,
                                      manager: manager,
                                    ),
                              ),
                              IconButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    EmployeeScreen.routeName,
                                    arguments: ManagerScreenArguments(departmentList: departments,manager: manager,adminId: departments.first.id_admin),
                                  );
                                },
                                icon: Icon(Icons.arrow_forward_ios_rounded),
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

  void showManagerDialog(BuildContext context, {MangerModal? manager}) {
    final departmentBloc = context.read<DepartmentBloc>();
    final departments = departmentBloc.state.departments;
    final managerBloc = context.read<ManagerBloc>();
    final arguments =
        ModalRoute.of(context)?.settings.arguments as ManagerScreenArguments?;

    DepartmentModal? selectedDepartment =
        departments.isNotEmpty ? departments.first : null;

    final formKey = GlobalKey<FormState>();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController dobController = TextEditingController();
    final TextEditingController addressController = TextEditingController();

    if (manager != null) {
      nameController.text = manager.managerName;
      emailController.text = manager.email;
      addressController.text = manager.address;
      dobController.text = manager.dob;
      selectedDepartment = departments.firstWhere(
        (dept) => dept.id == manager.departmentId,
        orElse: () => departments.isNotEmpty ? departments.first : null!,
      );
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
              title: Text(manager != null ? 'Edit Manager' : 'Add Manager'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (departments.isNotEmpty)
                        DropdownButtonFormField<DepartmentModal>(
                          value: selectedDepartment,
                          decoration: const InputDecoration(
                            labelText: "Department",
                            border: OutlineInputBorder(),
                          ),
                          items:
                              departments.map((dept) {
                                return DropdownMenuItem<DepartmentModal>(
                                  value: dept,
                                  child: Text(dept.name),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedDepartment = value;
                            });
                          },
                          validator:
                              (value) =>
                                  value == null
                                      ? 'Please select a department'
                                      : null,
                        ),
                      if (departments.isNotEmpty) const SizedBox(height: 12),
                      TextFormField(
                        controller: nameController,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Please enter a manager name'
                                    : null,
                        decoration: const InputDecoration(
                          labelText: "Manager Name",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: emailController,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Please enter a manager email'
                                    : null,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: addressController,
                        decoration: const InputDecoration(
                          labelText: "Address",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: dobController,
                        decoration: const InputDecoration(
                          labelText: "DOB",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                ElevatedButton(
                  child: Text(manager != null ? "Update" : "Add"),
                  onPressed: () {
                    if (formKey.currentState!.validate() &&
                        selectedDepartment != null) {
                      if (manager != null) {
                        managerBloc.add(
                          UpdateManager(
                            id: manager.id,
                            name: nameController.text,
                            email: emailController.text,
                            address: addressController.text,
                            dob: dobController.text,
                            departmentId: selectedDepartment!.id,
                            adminId: selectedDepartment!.id_admin,
                          ),
                        );
                      } else {
                        managerBloc.add(
                          AddManager(
                            name: nameController.text,
                            email: emailController.text,
                            address: addressController.text,
                            dob: dobController.text,
                            departmentId: selectedDepartment!.id,
                            adminId: selectedDepartment!.id_admin,
                            departmentName: selectedDepartment!.name,
                          ),
                        );
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
