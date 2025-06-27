

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../ utils/status_color_utils.dart';
import '../Employee/employee_bloc.dart';
import '../Employee/employee_event.dart';
import '../Employee/employee_state.dart';

import '../SuperAdminLogin/admin_event.dart';
import '../service/chart_room.dart';
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
          create: (context) => ChatBloc()
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

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    _buildTabBar(),
                    Expanded(
                      child: TabBarView(
                        controller: tabController,
                        children: const [
                          ChatRoomsList(),
                          ContactsList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text(
            'Messages',
            style: TextStyle(
              color: textColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: TabBar(
        controller: tabController,
        indicatorColor: secondaryColor,
        indicatorWeight: 3,
        labelColor: secondaryColor,
        unselectedLabelColor: unselectedTextColor,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs: const [
          Tab(text: 'CHATS'),
          Tab(text: 'CONTACTS'),
        ],
      ),
    );
  }
}

class ChatRoomsList extends StatefulWidget {
  const ChatRoomsList({super.key});

  @override
  State<ChatRoomsList> createState() => _ChatRoomsListState();
}

class _ChatRoomsListState extends State<ChatRoomsList> {
  @override
  Widget build(BuildContext context) {
    final selectRole = ModalRoute.of(context)!.settings.arguments as SelectRole;

    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state.isLoadingRooms) {
          return Center(
            child: CircularProgressIndicator(color: primaryColor),
          );
        }

        if (state.chatRooms.isEmpty) {
          return const Center(
            child: Text(
              'No chats available',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return BlocBuilder<EmployeeBloc, EmployeeState>(
          builder: (context, employeeState) {
            return ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: state.chatRooms.length,
              itemBuilder: (context, index) {
                final room = state.chatRooms[index];
                final otherUserId = room.participantIds.firstWhere(
                      (id) => id != selectRole.employeeModal?.id,
                );


               final employee = employeeState.employees
                    .where((emp) => emp.id == otherUserId).toList();

                if (employee != null) {

                  return ChatRoomListItem(
                    name: employee[index].name,
                    lastMessage: room.lastMessage ?? "",
                    time: formatTime(room.lastMessageTime?.toDate()),
                    unreadCount: 0,
                    isOnline: false,
                    onTap: () {
                      navigateToChatDetail(
                        context,
                        employee: employee[index],
                        room: room,
                        otherUserId: otherUserId,
                        selectRole: selectRole,
                      );
                    },
                  );
                } else {
                  return FutureBuilder<EmployeeModal?>(
                    future: FirebaseDbHelper.firebase.getEmployeeById(otherUserId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ChatRoomListItem(
                          name: 'Loading...',
                          lastMessage: room.lastMessage ?? "",
                          time: formatTime(room.lastMessageTime?.toDate()),
                          unreadCount: 0,
                          isOnline: false,
                          onTap: () {},
                        );
                      }

                      final fetchedEmployee = snapshot.data;
                      return ChatRoomListItem(
                        name: fetchedEmployee?.name ?? 'Unknown User',
                        lastMessage: room.lastMessage ?? "",
                        time: formatTime(room.lastMessageTime?.toDate()),
                        unreadCount: 0,
                        isOnline: false,
                        onTap: () {
                          navigateToChatDetail(
                            context,
                            employee: fetchedEmployee,
                            room: room,
                            otherUserId: otherUserId,
                            selectRole: selectRole,
                          );
                        },
                      );
                    },
                  );
                }
              },
            );
          },
        );
      },
    );
  }


  void navigateToChatDetail(
      BuildContext context, {
        required EmployeeModal? employee,
        required ChatRoom room,
        required String otherUserId,
        required SelectRole selectRole,
      }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => ChatBloc()
                  ..add(LoadChatRooms(selectRole.employeeModal?.id ?? "")),
              ),
              BlocProvider(
                create: (context) => EmployeeBloc()..add(FetchEmployees()),
              ),
            ],
            child: ChatDetailScreen(
              name: employee?.name ?? 'Unknown User',
              isOnline: false,
              roomId: room.id,
              otherUserId: otherUserId,
              currentUserId: selectRole.employeeModal?.id ?? "",
              selectRole: selectRole,
            ),
          );
        },
      ),
    );
  }

  String formatTime(DateTime? time) {
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
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFF2A3942),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: secondaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: primaryColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
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
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          color: unreadCount > 0 ? secondaryColor : Colors.white54,
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
                          maxLines: 1,
                        ),
                      ),
                      if (unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: secondaryColor,
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
  final String currentUserId;
  final SelectRole selectRole;

  const ChatDetailScreen({
    super.key,
    required this.name,
    required this.isOnline,
    required this.roomId,
    required this.otherUserId,
    required this.currentUserId,
    required this.selectRole,
  });

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(
      LoadChatMessages(
        roomId: widget.roomId,
        userId: widget.currentUserId,
        otherUserId: widget.otherUserId,
      ),
    );

    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF2A3942),
              child: Text(
                widget.name.isNotEmpty ? widget.name[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                Text(
                  widget.isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: widget.isOnline ? secondaryColor : Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  final messages = state.getMessagesForRoom(widget.roomId);

                    if (_scrollController.hasClients && messages.isNotEmpty) {
                      _scrollController.animateTo(
                        _scrollController.position.minScrollExtent,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }


                  if (messages.isEmpty) {
                    return const Center(
                      child: Text(
                        'No messages yet',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.all(8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return MessageBubble(
                        message: message.content,
                        time: formatTime(message.timestamp.toDate()),
                        isMe: message.senderId == widget.currentUserId,
                        isRead: message.isRead,
                      );
                    },
                  );
                },
              ),
            ),
            buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget buildMessageInput() {
    return Container(
      color: messageInputColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.white70),
            onPressed: () {},
          ),
          Expanded(
            child: TextField(

              controller: _messageController,
              focusNode: _focusNode,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Type a message',
                hintStyle: const TextStyle(color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFF2A3942),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (text) => sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.attach_file, color: Colors.white70),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
          FloatingActionButton(
            mini: true,
            backgroundColor: secondaryColor,
            onPressed: sendMessage,
            child: const Icon(Icons.send, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  void sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      final message = ChatMessage(
        id: '',
        senderId: widget.currentUserId,
        senderName: widget.selectRole.employeeModal?.name ?? "",
        receiverId: widget.otherUserId,
        content: _messageController.text,
        timestamp: Timestamp.fromDate(DateTime.now()),
        roomId: widget.roomId,
        isRead: false,
        status: MessageStatus.sent,
      );

      context.read<ChatBloc>().add(SendMessage(message));
      _messageController.clear();
    }
  }

  String formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isMe ? messageBubbleColorMe : messageBubbleColorOther,
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
                        color: isRead ?secondaryColor : Colors.white60,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
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
    final _primaryColor = const Color(0xff1a2a4d);
    final _textColor = Colors.white;

    return BlocBuilder<EmployeeBloc, EmployeeState>(
      builder: (context, state) {
        if (state.isLoading) {
          return Center(
            child: CircularProgressIndicator(color: _primaryColor),
          );
        }

        if (state.employees.isEmpty) {
          return const Center(
            child: Text(
              'No contacts available',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8),
          itemCount: state.employees.length,
          itemBuilder: (context, index) {
            final employee = state.employees[index];
            if (employee.id == selectRole.employeeModal?.id) {
              return const SizedBox(); // Skip current user
            }

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF2A3942),
                child: Text(
                  employee.name.isNotEmpty
                      ? employee.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                employee.name,
                style: TextStyle(color: _textColor),
              ),
              subtitle: Text(
                employee.departmentName ?? '',
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
              onTap: () async {
                // Generate or get existing room ID
                final roomId = _generateRoomId(
                  selectRole.employeeModal?.id ?? "",
                  employee.id,
                );

                // Create chat room if it doesn't exist
                context.read<ChatBloc>().add(
                  CreateChatRoom(
                    currentUserId: selectRole.employeeModal?.id ?? "",
                    otherUserId: employee.id,
                  ),
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return MultiBlocProvider(
                        providers: [
                          BlocProvider(
                            create:
                                (context) =>
                                    ChatBloc()..add(
                                      LoadChatRooms(
                                        selectRole.employeeModal?.id ?? "",
                                      ),
                                    ),
                          ),
                          BlocProvider(
                            create:
                                (context) =>
                                    EmployeeBloc()..add(FetchEmployees()),
                          ),
                        ],
                        child: ChatDetailScreen(
                          name: employee.name,
                          isOnline: false,
                          roomId: roomId,
                          otherUserId: employee.id,
                          currentUserId: selectRole.employeeModal?.id ?? "",
                          selectRole: selectRole,
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
    );
  }

  String _generateRoomId(String id1, String id2) {
    final ids = [id1, id2]..sort();
    return '${ids[0]}_${ids[1]}';
  }
}
