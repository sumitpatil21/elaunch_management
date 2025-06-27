import 'package:equatable/equatable.dart';

import '../service/chart_room.dart';
import '../service/chat_message.dart';

enum ChatStatus { initial, loading, success, failure }

class ChatState extends Equatable {
  final ChatStatus status;

  final Map<String, List<ChatMessage>> messagesByRoom;

  final List<ChatRoom> chatRooms;
  final bool isLoadingRooms;
  final List<ChatMessage> messages;
  final bool isLoadingMessages;
  final bool isSendingMessage;
  final String? currentRoomId;
  final List<UserContact> contacts;
  final List<UserContact> filteredContacts;
  final bool isLoadingContacts;
  final String? searchQuery;

  const ChatState({
    this.status = ChatStatus.initial,

    this.messagesByRoom = const {},
    this.chatRooms = const [],
    this.isLoadingRooms = false,
    this.messages = const [],
    this.isLoadingMessages = false,
    this.isSendingMessage = false,
    this.currentRoomId,
    this.contacts = const [],
    this.filteredContacts = const [],
    this.isLoadingContacts = false,
    this.searchQuery,
  });

  ChatState copyWith({
    ChatStatus? status,
    String? errorMessage,
    Map<String, List<ChatMessage>>? messagesByRoom,
    List<ChatRoom>? chatRooms,
    bool? isLoadingRooms,
    List<ChatMessage>? messages,
    bool? isLoadingMessages,
    bool? isSendingMessage,
    String? currentRoomId,
    List<UserContact>? contacts,
    List<UserContact>? filteredContacts,
    bool? isLoadingContacts,
    String? searchQuery,
    Map<String, bool>? typingUsers,
    Map<String, bool>? onlineUsers,
  }) {
    return ChatState(
      status: status ?? this.status,
      messagesByRoom: messagesByRoom ?? this.messagesByRoom,
      chatRooms: chatRooms ?? this.chatRooms,
      isLoadingRooms: isLoadingRooms ?? this.isLoadingRooms,
      messages: messages ?? this.messages,
      isLoadingMessages: isLoadingMessages ?? this.isLoadingMessages,
      isSendingMessage: isSendingMessage ?? this.isSendingMessage,
      currentRoomId: currentRoomId ?? this.currentRoomId,
      contacts: contacts ?? this.contacts,
      filteredContacts: filteredContacts ?? this.filteredContacts,
      isLoadingContacts: isLoadingContacts ?? this.isLoadingContacts,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<ChatMessage> getMessagesForRoom(String roomId) {
    return messages.where((msg) => msg.roomId == roomId).toList();
  }

  @override
  List<Object?> get props => [
    status,

    messagesByRoom,
    chatRooms,
    isLoadingRooms,
    messages,
    isLoadingMessages,
    isSendingMessage,
    currentRoomId,
    contacts,
    filteredContacts,
    isLoadingContacts,
    searchQuery,
  ];
}
