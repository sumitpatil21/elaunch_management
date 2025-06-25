import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../Employee/employee_bloc.dart';
import '../Employee/employee_event.dart';
import '../Employee/employee_state.dart';
import '../SuperAdminLogin/admin_event.dart';
import '../service/chat_message.dart';
import '../service/employee_modal.dart';
import '../service/firebase_database.dart';
import 'chat_bloc.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatScreen extends StatefulWidget {
  static const routeName = '/chat';

  const ChatScreen({super.key});

  static Widget builder(BuildContext context) {
    final selectRole = ModalRoute.of(context)!.settings.arguments as SelectRole;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) =>
                  ChatBloc(firebaseDbHelper: FirebaseDbHelper.firebase)
                    ..add(LoadChatRooms(selectRole.employeeModal?.id ?? "")),
        ),
        BlocProvider(
          create: (context) => EmployeeBloc()..add(FetchEmployees()),
        ),
      ],
      child: const ChatScreen(),
    );
  }

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1a2a4d),
      appBar: AppBar(
        backgroundColor: const Color(0xff1a2a4d),
        title: const Text(
          'Message',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF00A884),
          indicatorWeight: 3,
          labelColor: const Color(0xFF00A884),
          unselectedLabelColor: Colors.white70,
          tabs: const [Tab(text: 'CHATS'), Tab(text: 'CONTACTS')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [ChatRoomsList(), ContactsList()],
      ),
    );
  }
}

class ChatRoomsList extends StatelessWidget {
  const ChatRoomsList({super.key});

  @override
  Widget build(BuildContext context) {
    final selectRole = ModalRoute.of(context)!.settings.arguments as SelectRole;

    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state.isLoadingRooms) {
          return const Center(child: CircularProgressIndicator());
        }

        return Container(
          color: const Color(0xFF111B21),
          child: ListView.builder(
            itemCount: state.chatRooms.length,
            itemBuilder: (context, index) {
              final room = state.chatRooms[index];
              final otherUserId = room.participantIds.firstWhere(
                (id) => id != selectRole.employeeModal?.id,
                orElse: () => '',
              );

              return FutureBuilder<EmployeeModal?>(
                future: FirebaseDbHelper.firebase.getEmployeeById(otherUserId),
                builder: (context, snapshot) {
                  final employee = snapshot.data;
                  return ChatRoomListItem(
                    name: employee?.name ?? 'Unknown',
                    lastMessage: room.lastMessage ?? "",
                    time: _formatTime(room.lastMessageTime?.toDate()),
                    unreadCount: 0,
                    isOnline: false,
                    // In ChatRoomsList:
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            // Use the parent context to get the bloc
                            final parentContext = context;
                            return MultiBlocProvider(
                              providers: [
                                BlocProvider(
                                  create:
                                      (context) =>
                                  ChatBloc(firebaseDbHelper: FirebaseDbHelper.firebase)
                                    ..add(LoadChatRooms(selectRole.employeeModal?.id ?? "")),
                                ),
                                BlocProvider(
                                  create: (context) => EmployeeBloc()..add(FetchEmployees()),
                                ),
                              ],
                              child: ChatDetailScreen(
                                name: employee?.name ?? 'Unknown',
                                isOnline: false,
                                roomId: room.id,
                                otherUserId: otherUserId,
                                employeeModal: selectRole.employeeModal,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 7) {
      return '${time.day}/${time.month}/${time.year}';
    } else if (difference.inDays > 0) {
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

class ChatRoomListItem extends StatelessWidget {
  final String name;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isOnline;
  final VoidCallback onTap;

  const ChatRoomListItem({
    super.key,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    required this.isOnline,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFF2A3942), width: 0.5),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFF2A3942),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          color:
                              unreadCount > 0
                                  ? const Color(0xFF00A884)
                                  : Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: const BoxDecoration(
                            color: Color(0xFF00A884),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatDetailScreen extends StatefulWidget {
  final String name;
  final bool isOnline;
  final String roomId;
  final String otherUserId;
  final EmployeeModal? employeeModal;

  const ChatDetailScreen({
    super.key,
    required this.name,
    required this.isOnline,
    required this.roomId,
    required this.otherUserId,
    required this.employeeModal,
  });

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(
      LoadChatMessages(
        roomId: widget.roomId,
        userId: widget.employeeModal?.id ?? "",
        otherUserId: '',
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B141A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF202C33),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.name, style: const TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                final messages = state.getMessagesForRoom(widget.roomId);

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(
                      _scrollController.position.minScrollExtent,
                    );
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return MessageBubble(
                      message: message.content,
                      time: _formatTime(message.timestamp),
                      isMe: message.senderId == widget.employeeModal?.id,
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildMessageInput() {
    return Container(
      color: const Color(0xFF202C33),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Type a message',
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Color(0xFF2A3942),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            mini: true,
            backgroundColor: const Color(0xFF00A884),
            onPressed: () {
              if (_messageController.text.trim().isNotEmpty) {
                final message = ChatMessage(
                  id: '',
                  senderId: widget.employeeModal?.id ?? "",
                  senderName: widget.employeeModal?.name ?? "",
                  receiverId: widget.otherUserId,
                  content: _messageController.text,
                  timestamp: DateTime.now(),
                  roomId: widget.roomId,
                  isRead: false,
                  status: MessageStatus.sent,
                );

                context.read<ChatBloc>().add(SendMessage(message));
                _messageController.clear();
              }
            },
            child: const Icon(Icons.send, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String message;
  final String time;
  final bool isMe;
  final bool isRead;

  const MessageBubble({
    super.key,
    required this.message,
    required this.time,
    required this.isMe,
    this.isRead = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isMe ? 64 : 8,
          right: isMe ? 8 : 64,
          top: 4,
          bottom: 4,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF005C4B) : const Color(0xFF202C33),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    isRead ? Icons.done_all : Icons.done,
                    size: 16,
                    color: isRead ? const Color(0xFF4FC3F7) : Colors.white60,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ContactsList extends StatelessWidget {
  const ContactsList({super.key});

  @override
  Widget build(BuildContext context) {
    final selectRole = ModalRoute.of(context)!.settings.arguments as SelectRole;

    return BlocBuilder<EmployeeBloc, EmployeeState>(
      builder: (context, state) {
        return Container(
          color: const Color(0xFF111B21),
          child: ListView.builder(
            itemCount: state.employees.length,
            itemBuilder: (context, index) {
              final employee = state.employees[index];
              if (employee.id == selectRole.employeeModal?.id) {
                return const SizedBox(); // Skip current user
              }

              return ListTile(
                leading: CircleAvatar(child: Text(employee.name[0])),
                title: Text(
                  employee.name,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  employee.departmentName ?? '',
                  style: const TextStyle(color: Colors.white70),
                ),
                onTap: () {
                  context.read<ChatBloc>().add(
                    CreateChatRoom(
                      currentUserId: selectRole.employeeModal?.id ?? "",
                      otherUserId: employee.id,
                    ),
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ChatDetailScreen(
                            name: employee.name,
                            isOnline: false,
                            roomId: _generateRoomId(
                              selectRole.employeeModal?.id ?? "",
                              employee.id,
                            ),
                            otherUserId: employee.id,
                            employeeModal: selectRole.employeeModal,
                          ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  String _generateRoomId(String id1, String id2) {
    final ids = [id1, id2]..sort();
    return '${ids[0]}_${ids[1]}';
  }
}
