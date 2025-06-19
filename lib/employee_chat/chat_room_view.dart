

import 'package:elaunch_management/Service/employee_modal.dart';
import 'package:elaunch_management/SuperAdminLogin/admin_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../Service/firebase_database.dart';
import 'chat_bloc.dart';
import 'chat_event.dart';
import 'chat_state.dart';

import 'chat_view.dart';

class ChatListScreen extends StatelessWidget {
  static String routeName = '/chat-list';


  const ChatListScreen({ super.key});

  static Widget builder(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBloc(FirebaseDbHelper.firebase)
        ..add(LoadChatRooms("")),
      child: ChatListScreen( ),
    );

  }
  @override
  Widget build(BuildContext context) {
    SelectRole user = ModalRoute.of(context)!.settings.arguments as SelectRole;
    return BlocProvider(
      create: (context) => ChatBloc(FirebaseDbHelper.firebase)
        ..add(LoadChatRooms(user.employeeModal!.id)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chats'),
          actions: [
            // IconButton(
            //   icon: const Icon(Icons.add),
            //   onPressed: () => _showNewChatDialog(context),
            // ),
          ],
        ),
        body: BlocConsumer<ChatBloc, ChatState>(
          listener: (context, state) {

          },
          builder: (context, state) {

            if (state.chatRooms.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No chats available',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap the + button to start a new chat',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }
            return Center();
            // return ListView.builder(
            //   itemCount: state.chatRooms.length,
            //   itemBuilder: (context, index) {
            //     final room = state.chatRooms[index];
            //     final otherUserId = room.participantIds.firstWhere(
            //           (id) => id != user.employeeModal!.id,
            //       orElse: () => '',
            //     );
            //
            //     return FutureBuilder<EmployeeModal?>(
            //       future: FirebaseDbHelper.firebase.getEmployeeById(otherUserId).then((value) =>
            //       ),
            //       builder: (context, snapshot) {
            //         if (snapshot.connectionState == ConnectionState.waiting) {
            //           return const ListTile(
            //             leading: CircleAvatar(child: CircularProgressIndicator()),
            //             title: Text('Loading...'),
            //           );
            //         }
            //
            //         final employee = snapshot.data;
            //         if (employee == null) {
            //           return const SizedBox.shrink();
            //         }
            //
            //         // final unreadCount = room.unreadCounts[.id] ?? 0;
            //         final isUnread =true;
            //
            //         return Card(
            //           margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            //           child: ListTile(
            //             leading: CircleAvatar(
            //               backgroundColor: Colors.blue,
            //
            //             ),
            //             title: Text(
            //               employee.name,
            //               style: TextStyle(
            //                 fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
            //               ),
            //             ),
            //             subtitle: Text(
            //               room.lastMessage,
            //               maxLines: 1,
            //               overflow: TextOverflow.ellipsis,
            //               style: TextStyle(
            //                 fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
            //                 color: isUnread ? Colors.black87 : Colors.grey[600],
            //               ),
            //             ),
            //             trailing: Column(
            //               mainAxisAlignment: MainAxisAlignment.center,
            //               crossAxisAlignment: CrossAxisAlignment.end,
            //               children: [
            //                 Text(
            //                   _formatTime(room.lastMessageTime),
            //                   style: TextStyle(
            //                     fontSize: 12,
            //                     color: isUnread ? Colors.blue : Colors.grey,
            //                     fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
            //                   ),
            //                 ),
            //                 if (isUnread) ...[
            //                   const SizedBox(height: 4),
            //                   Container(
            //                     padding: const EdgeInsets.all(6),
            //                     decoration: const BoxDecoration(
            //                       color: Colors.blue,
            //                       shape: BoxShape.circle,
            //                     ),
            //                     child: Text(
            //                       // unreadCount > 99 ? '99+' : unreadCount.toString(),
            //                       "99",
            //                       style: const TextStyle(
            //                         color: Colors.white,
            //                         fontSize: 10,
            //                         fontWeight: FontWeight.bold,
            //                       ),
            //                     ),
            //                   ),
            //                 ],
            //               ],
            //             ),
            //             onTap: () {
            //               // Mark messages as read when opening chat
            //               context.read<ChatBloc>().add(
            //                 MarkMessagesAsRead(room.id, .id),
            //               );
            //
            //               Navigator.push(
            //                 context,
            //                 MaterialPageRoute(
            //                   builder: (context) => ChatScreen(
            //                     currentUser: user.employeeModal,
            //                     otherUser: employee,
            //                   ),
            //                 ),
            //               );
            //             },
            //           ),
            //         );
            //       },
            //     );
            //   },
            // );
          },
        ),
      ),
    );
  }

  // void _showNewChatDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (dialogContext) => NewChatDialog(currentUser: currentUser),
  //   );
  // }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);


    if (difference.inDays > 0) {
    return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
    return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes}m ago';
    } else {
    return 'Just now';
    }
  }
}

// New Chat Dialog
class NewChatDialog extends StatefulWidget {
  final EmployeeModal currentUser;

  const NewChatDialog({required this.currentUser, super.key});

  @override
  State<NewChatDialog> createState() => _NewChatDialogState();
}

class _NewChatDialogState extends State<NewChatDialog> {
  List<EmployeeModal> employees = [];
  List<EmployeeModal> filteredEmployees = [];
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
    _searchController.addListener(_filterEmployees);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    try {
      final allEmployees = await FirebaseDbHelper.firebase.getEmployees();
      setState(() {
        employees = allEmployees.where((emp) => emp.id != widget.currentUser.id).cast<EmployeeModal>().toList();
        filteredEmployees = employees;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading employees: $e')),
        );
      }
    }
  }

  void _filterEmployees() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredEmployees = employees.where((emp) =>
      emp.name.toLowerCase().contains(query) ||
          emp.email.toLowerCase().contains(query)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Start New Chat'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search employees...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredEmployees.isEmpty
                  ? const Center(child: Text('No employees found'))
                  : ListView.builder(
                itemCount: filteredEmployees.length,
                itemBuilder: (context, index) {
                  final employee = filteredEmployees[index];
                  return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue,

                      ),
                      title: Text(employee.name),


                      subtitle: Text(employee.email),
                  onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                  builder: (context) => ChatScreen(
                  currentUser: widget.currentUser,
                  otherUser: employee,
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
