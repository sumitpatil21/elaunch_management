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
        BlocProvider(create: (context) => SystemBloc(SystemState())),
      ],
      child: const SystemView(),
    );
  }

  @override
  State<SystemView> createState() => _SystemViewState();
}

class _SystemViewState extends State<SystemView> {
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize by fetching systems
    context.read<SystemBloc>().add(FetchSystem(adminId: 1)); // Replace with actual adminId
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.withOpacity(0.2),
        title: Text("System"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green.withOpacity(0.2),
        onPressed: () => showSystemDialog(context), // Fixed method name
        label: Text("Add System"), // Fixed text
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
                          Icons.computer_outlined, // Fixed icon
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text("No systems found"), // Fixed text
                        const SizedBox(height: 16),
                      ],
                    ),
                  );
                }

                // Filter systems based on search
                final filteredSystems = searchController.text.isEmpty
                    ? state.systems
                    : state.systems.where((system) =>
                system.systemName.toLowerCase().contains(
                  searchController.text.toLowerCase(),
                ) ||
                    (system.version?.toLowerCase().contains(
                      searchController.text.toLowerCase(),
                    ) ?? false)).toList();

                if (filteredSystems.isEmpty) {
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
                        Text("No results for \"${searchController.text}\""),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            searchController.clear();
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
                  itemCount: filteredSystems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final system = filteredSystems[index];
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
                      confirmDismiss: (_) => showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Confirm Delete"),
                          content: Text(
                            "Are you sure you want to delete ${system.systemName}?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("CANCEL"),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("DELETE"),
                            ),
                          ],
                        ),
                      ),
                      onDismissed: (_) {
                        context.read<SystemBloc>().add(
                          DeleteSystem(
                            id: system.id ?? 1,
                            adminId: 1, // Replace with actual adminId
                          ),
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
                            backgroundColor: Colors.blue.withOpacity(0.2), // Changed color
                            child: Icon(Icons.computer_outlined),
                          ),
                          title: Text(
                            system.systemName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Version: ${system.version ?? 'N/A'}"), // Fixed display
                              if (system.employeeName != null) // Added null check
                                Text("Assigned to: ${system.employeeName}"),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => showSystemDialog( // Fixed method name
                                  context,
                                  system: system,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  // Add navigation logic here if needed
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

  void showSystemDialog(BuildContext context, {SystemModal? system}) { // Fixed method name
    final formKey = GlobalKey<FormState>();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController versionController = TextEditingController();

    if (system != null) {
      nameController.text = system.systemName;
      versionController.text = system.version ?? "";
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
              title: Text(system != null ? 'Edit System' : 'Add System'), // Fixed title
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        validator: (value) =>
                        value == null || value.isEmpty
                            ? 'Please enter a system name' // Fixed validation message
                            : null,
                        decoration: const InputDecoration(
                          labelText: "System Name", // Fixed label
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: versionController,
                        validator: (value) =>
                        value == null || value.isEmpty
                            ? 'Please enter a version' // Fixed validation message
                            : null,
                        decoration: const InputDecoration(
                          labelText: "Version", // Fixed label
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
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
                            adminId: 1, // Replace with actual adminId
                          ),
                        );
                      } else {
                        context.read<SystemBloc>().add(
                          AddSystem(
                            systemName: nameController.text,
                            version: versionController.text,
                            adminId: 1, // Replace with actual adminId
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