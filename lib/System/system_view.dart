import 'package:elaunch_management/Service/system_modal.dart';
import 'package:elaunch_management/System/system_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SystemView extends StatefulWidget {
  static String routeName = "/system";
  const SystemView({super.key});
  static Widget builder(BuildContext context) {
    return MultiBlocProvider(
      providers: [

       BlocProvider(create: (context) => SystemBloc(SystemState()),)
      ],
      child: const SystemView(),
    );
  }
  @override
  State<SystemView> createState() => _SystemViewState();
}

class _SystemViewState extends State<SystemView> {
  @override
  Widget build(BuildContext context) {
TextEditingController searchController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.withOpacity(0.2),
        title: Text(
         "System"
        ),
        // actions: [
        //   PopupMenuButton<int?>(
        //     icon: const Icon(Icons.filter_list),
        //     itemBuilder:
        //         (_) => [
        //       const PopupMenuItem<int?>(
        //         value: null,
        //         child: Text('All Managers'),
        //       ),
        //       ...departments
        //           .map(
        //             (dept) => PopupMenuItem<int?>(
        //           value: dept.id,
        //           child: Text(dept.name),
        //         ),
        //       )
        //           .toList(),
        //     ],
        //     onSelected: (departmentId) {
        //       setState(() {
        //         selectedDepartment =
        //         departmentId != null
        //             ? departments.firstWhere((d) => d.id == departmentId)
        //             : null;
        //       });
        //       context.read<ManagerBloc>().add(
        //         FetchManagers(
        //           departmentId: departmentId,
        //
        //           adminId:
        //           selectedDepartment?.id_admin ?? arguments?.adminId ?? 1,
        //         ),
        //       );
        //     },
        //   ),
        // ],
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
              controller: searchController,
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
                    searchController.clear();
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
            child: BlocBuilder<SystemBloc, SystemState>(
              builder: (context, state) {
                if (state.systems.isEmpty) {
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

                      ],
                    ),
                  );
                }
                //
                // final filteredManagers =
                // searchController.isEmpty
                //     ? state.
                //     : state.managers
                //     .where(
                //       (manager) =>
                //   manager.managerName.toLowerCase().contains(
                //     searchText.toLowerCase(),
                //   ) ||
                //       (manager.email.toLowerCase().contains(
                //         searchText.toLowerCase(),
                //       )) ||
                //       (manager.departmentName
                //           ?.toLowerCase()
                //           .contains(searchText.toLowerCase()) ??
                //           false),
                // )
                //     .toList();
                //
                // if (filteredManagers.isEmpty) {
                //   return Center(
                //     child: Column(
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       children: [
                //         const Icon(
                //           Icons.search_off,
                //           size: 64,
                //           color: Colors.grey,
                //         ),
                //         const SizedBox(height: 16),
                //         Text("No results for \"$searchText\""),
                //         const SizedBox(height: 16),
                //         ElevatedButton(
                //           onPressed: () {
                //             searchController.clear();
                //             setState(() {});
                //           },
                //           child: const Text("Clear Search"),
                //         ),
                //       ],
                //     ),
                //   );
                // }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.systems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final system = state.systems[index];
                    return Dismissible(
                      key: Key(system.id.toString()),
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
                            "Are you sure you want to delete ${system.systemName}?",
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
                        context.read<SystemBloc>().add(
                          DeleteSystem(id: system.id??1),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("${system.systemName} deleted"),
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
                            backgroundColor: Colors.yellow.withOpacity(0.2),
                            child: Icon(Icons.computer_outlined),
                          ),
                          title: Text(
                            system.systemName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(system.version??""),
                              Text(system.systemName),
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
                                  system: system,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  // Navigator.pushNamed(
                                  //   context,
                                  //   EmployeeScreen.routeName,
                                  //   arguments: ManagerScreenArguments(departmentList: departments,manager: system,adminId: departments.first.id_admin),
                                  // );
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

  void showManagerDialog(BuildContext context, {SystemModal? system}) {

    // final departments = departmentBloc.state.departments;
    // final managerBloc = context.read<ManagerBloc>();
    // final arguments =
    // ModalRoute.of(context)?.settings.arguments as ManagerScreenArguments?;

   // DepartmentModal? selectedDepartment =
   //  departments.isNotEmpty ? departments.first :  null;

    final formKey = GlobalKey<FormState>();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController versionController = TextEditingController();
    // final TextEditingController dobController = TextEditingController();
    // final TextEditingController addressController = TextEditingController();

    if (system != null) {
      nameController.text = system.systemName;
      versionController.text = system.version??"";

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
              title: Text(system != null ? 'Edit Manager' : 'Add Manager'),
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
                            ? 'Please enter a manager name'
                            : null,
                        decoration: const InputDecoration(
                          labelText: "Manager Name",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: versionController,
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
                      // TextFormField(
                      //   controller: addressController,
                      //   decoration: const InputDecoration(
                      //     labelText: "Address",
                      //     border: OutlineInputBorder(),
                      //   ),
                      // ),
                      // const SizedBox(height: 12),
                      // TextFormField(
                      //   controller: dobController,
                      //   decoration: const InputDecoration(
                      //     labelText: "DOB",
                      //     border: OutlineInputBorder(),
                      //   ),
                      // ),
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
                  child: Text(system != null ? "Update" : "Add"),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      if (system != null) {
                        context.read<SystemBloc>().add(
                          UpdateSystem(
                            id: system.id!,
                            systemName: nameController.text,
                            version: versionController.text,
                          ),
                        );
                      } else {
                        context.read<SystemBloc>().add(
                          AddSystem(
                            systemName: nameController.text,
                            version: versionController.text,
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


