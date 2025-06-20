import 'package:elaunch_management/service/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Service/chart_room.dart';
import '../SuperAdminLogin/admin_event.dart';
import '../service/chat_message.dart';
import 'chat_bloc.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatScreen extends StatefulWidget {
  static const routeName = '/chat';


  const ChatScreen({super.key});

  static Widget builder(BuildContext context) {
    SelectRole user = ModalRoute.of(context)!.settings.arguments as SelectRole;
    return BlocProvider(
      create:
          (context) => ChatBloc(firebaseDbHelper: FirebaseDbHelper.firebase),
      child: ChatScreen(),
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
      appBar: AppBar(
        title: const Text('Chats'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.chat), text: 'Messages'),
            Tab(icon: Icon(Icons.contacts), text: 'Contacts'),
          ],
        ),
      ),
      body: Center(),
    );
  }
}

class ChatRoomsList extends StatelessWidget {
  final String userId;

  const ChatRoomsList({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state.isLoadingRooms) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.chatRooms.isEmpty) {
          return const Center(child: Text('No chats yet'));
        }

        return ListView.builder(
          itemCount: state.chatRooms.length,
          itemBuilder: (context, index) {
            final room = state.chatRooms[index];
            final otherUserId = room.participantIds.firstWhere(
              (id) => id != userId,
              orElse: () => '',
            );
            final contact = state.getRoomById(otherUserId);
            return null;

            // return ChatRoomListItem(
            //   /*room: room.id,
            //   contact: contact,
            //   currentUserId: userId,
            //   unreadCount: room.unreadCount,*/
            // );
          },
        );
      },
    );
  }
}

class ChatRoomListItem extends StatelessWidget {
  final ChatRoom room;
  final UserContact? contact;
  final String currentUserId;
  final int unreadCount;

  const ChatRoomListItem({
    Key? key,
    required this.room,
    required this.contact,
    required this.currentUserId,
    required this.unreadCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage:
            contact?.profileImage != null
                ? NetworkImage(contact!.profileImage!)
                : null,
        child:
            contact?.profileImage == null
                ? Text(
                  contact?.name.isNotEmpty == true ? contact!.name[0] : '?',
                )
                : null,
      ),
      title: Text(contact?.name ?? 'Unknown'),
      subtitle: Row(
        children: [
          if (room.lastMessageSenderId == currentUserId)
            const Text('You: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              room.lastMessage as String,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            room.lastMessageTime != null
                ? _formatTime(room.lastMessageTime!)
                : '',
            style: const TextStyle(fontSize: 12),
          ),
          if (unreadCount > 0)
            CircleAvatar(
              radius: 10,
              backgroundColor: Colors.blue,
              child: Text(
                '$unreadCount',
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
            ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ChatDetailScreen(
                  roomId: room.id,
                  currentUserId: currentUserId,
                  otherUser: contact,
                ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (now.difference(time).inDays < 1) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.month}/${time.day}';
    }
  }
}

class ChatDetailScreen extends StatefulWidget {
  final String roomId;
  final String currentUserId;
  final UserContact? otherUser;

  const ChatDetailScreen({
    Key? key,
    required this.roomId,
    required this.currentUserId,
    required this.otherUser,
  }) : super(key: key);

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
      LoadChatMessages(userId: '', otherUserId: '', roomId: ''),
    );
    context.read<ChatBloc>().add(
      MarkMessagesAsRead(widget.roomId, widget.currentUserId),
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
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage:
                  widget.otherUser?.profileImage != null
                      ? NetworkImage(widget.otherUser!.profileImage!)
                      : null,
              child:
                  widget.otherUser?.profileImage == null
                      ? Text(
                        widget.otherUser?.name.isNotEmpty == true
                            ? widget.otherUser!.name[0]
                            : '?',
                      )
                      : null,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.otherUser?.name ?? 'Unknown'),
                BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    final isTyping = state.isUserTyping(
                      widget.roomId,
                      widget.otherUser?.id ?? '',
                    );
                    final isOnline = state.isUserOnline(
                      widget.otherUser?.id ?? '',
                    );

                    return Text(
                      isTyping
                          ? 'typing...'
                          : isOnline
                          ? 'online'
                          : 'last seen ${_formatLastSeen(state.onlineUsers.toString() as DateTime?)}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Expanded(
          //   child: BlocBuilder<ChatBloc, ChatState>(
          //     // builder: (context, state) {
          //     //   if (state.isLoadingMessages) {
          //     //     return const Center(child: CircularProgressIndicator());
          //     //   }
          //     //
          //     //   final messages = state.chatRooms;
          //     //
          //     //   WidgetsBinding.instance.addPostFrameCallback((_) {
          //     //     if (_scrollController.hasClients) {
          //     //       _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          //     //     }
          //     //   });
          //     //
          //     //   // return ListView.builder(
          //     //   //   controller: _scrollController,
          //     //   //   itemCount: messages.length,
          //     //   //   itemBuilder: (context, index) {
          //     //   //     return MessageBubble(
          //     //   //       message: messages[index],
          //     //   //       isMe: messages[index].senderId == widget.currentUserId,
          //     //   //     );
          //     //   //   },
          //     //   // );
          //     // },
          //   ),
          // ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),

      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.attach_file), onPressed: () => ()),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(),
              ),
              onChanged: (text) {
                if (text.isNotEmpty) {
                  context.read<ChatBloc>().add(
                    StartTyping(widget.roomId, widget.currentUserId),
                  );
                } else {
                  context.read<ChatBloc>().add(
                    StopTyping(widget.roomId, widget.currentUserId),
                  );
                }
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              if (_messageController.text.trim().isNotEmpty) {
                final message = ChatMessage(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  senderId: widget.currentUserId,
                  senderName:
                      'You', // This should be replaced with actual user name
                  receiverId: widget.otherUser?.id ?? '',
                  content: _messageController.text,
                  timestamp: DateTime.now(),
                  roomId: widget.roomId,
                );

                context.read<ChatBloc>().add(SendMessage(message));
                _messageController.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  // void _showAttachmentOptions() {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (context) {
  //       return SafeArea(
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             ListTile(
  //               leading: const Icon(Icons.image),
  //               title: const Text('Image'),
  //               onTap: () {
  //                 Navigator.pop(context);
  //                 _pickAndSendMedia(MessageType.image);
  //               },
  //             ),
  //             ListTile(
  //               leading: const Icon(Icons.videocam),
  //               title: const Text('Video'),
  //               onTap: () {
  //                 Navigator.pop(context);
  //                 _pickAndSendMedia(MessageType.video);
  //               },
  //             ),
  //             ListTile(
  //               leading: const Icon(Icons.insert_drive_file),
  //               title: const Text('Document'),
  //               onTap: () {
  //                 Navigator.pop(context);
  //                 _pickAndSendMedia(MessageType.document);
  //               },
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
  //
  // void _pickAndSendMedia(MessageType type) async {
  //   // Implement file picking logic
  //   // For example using image_picker or file_picker packages
  //   // Then send the file using SendMediaMessage event
  // }

  String _formatLastSeen(DateTime? lastSeen) {
    if (lastSeen == null) return 'unknown';

    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inSeconds < 60) return 'just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) return '${difference.inHours} hours ago';
    return '${difference.inDays} days ago';
  }
}

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const MessageBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,

      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isMe ? Theme.of(context).primaryColor : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // if (!isMe)
            //   Text(
            //     message.senderName,
            //     style: TextStyle(
            //       fontWeight: FontWeight.bold,
            //       color: isMe ? Colors.white : Colors.black,
            //     ),
            //   ),
            // if (message.type == MessageType.text)
            //   Text(
            //     message.content,
            //     style: TextStyle(color: isMe ? Colors.white : Colors.black),
            //   ),
            // if (message.type == MessageType.image)
            //   GestureDetector(
            //     onTap: () {
            //       // Show image in full screen
            //     },
            //     child: ClipRRect(
            //       borderRadius: BorderRadius.circular(8),
            //       child: Image.network(
            //         message.attachmentUrl!,
            //         width: double.infinity,
            //         height: 200,
            //         fit: BoxFit.cover,
            //       ),
            //     ),
            //   ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(width: 4),
                if (isMe)
                  Icon(
                    _getStatusIcon(message.status),
                    size: 12,
                    color: isMe ? Colors.white70 : Colors.black54,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return Icons.access_time;
      case MessageStatus.sent:
        return Icons.check;
      case MessageStatus.delivered:
        return Icons.done_all;
      case MessageStatus.read:
        return Icons.done_all;
      case MessageStatus.failed:
        return Icons.error_outline;
      }
  }
}

class ContactsList extends StatelessWidget {
  final String userId;

  const ContactsList({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search contacts...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (query) {
              context.read<ChatBloc>().add(SearchContacts(query));
            },
          ),
        ),
        Expanded(
          child: BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              if (state.isLoadingContacts) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.filteredContacts.isEmpty) {
                return const Center(child: Text('No contacts found'));
              }

              return ListView.builder(
                itemCount: state.filteredContacts.length,
                itemBuilder: (context, index) {
                  final contact = state.filteredContacts[index];
                  return ContactListItem(
                    contact: contact,
                    currentUserId: userId,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class ContactListItem extends StatelessWidget {
  final UserContact contact;
  final String currentUserId;

  const ContactListItem({
    Key? key,
    required this.contact,
    required this.currentUserId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage:
            contact.profileImage != null
                ? NetworkImage(contact.profileImage!)
                : null,
        child:
            contact.profileImage == null
                ? Text(contact.name.isNotEmpty ? contact.name[0] : '?')
                : null,
      ),
      title: Text(contact.name),
      subtitle: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          return Text(state.isUserOnline(contact.id) ? 'online' : 'last seen');
        },
      ),
      trailing: IconButton(
        icon: const Icon(Icons.chat),
        onPressed: () {
          context.read<ChatBloc>().add(
            CreateChatRoom(currentUserId, contact.id),
          );
          // Navigate to chat detail screen after room is created
          // This should be handled with a listener in the BLoC
        },
      ),
    );
  }

  String _formatLastSeen(DateTime? lastSeen) {
    if (lastSeen == null) return 'unknown';

    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inSeconds < 60) return 'just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) return '${difference.inHours} hours ago';
    return '${difference.inDays} days ago';
  }
}
