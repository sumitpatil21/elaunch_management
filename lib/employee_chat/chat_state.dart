
import 'package:equatable/equatable.dart';


import '../service/chart_room.dart';
import '../service/chat_message.dart';


enum ChatStatus { initial, loading, success, failure }

class ChatState extends Equatable {
  final ChatStatus status;
  final String? errorMessage;

  // Chat Rooms
  final List<ChatRoom> chatRooms;
  final bool isLoadingRooms;

  // Messages
  final List<ChatMessage> messages;
  final bool isLoadingMessages;
  final bool isSendingMessage;
  final String? currentRoomId;

  // Contacts
  final List<UserContact> contacts;
  final List<UserContact> filteredContacts;
  final bool isLoadingContacts;
  final String? searchQuery;

  // Status Indicators
  final Map<String, bool> typingUsers;
  final Map<String, bool> onlineUsers;

  const ChatState({
    this.status = ChatStatus.initial,
    this.errorMessage,
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
    this.typingUsers = const {},
    this.onlineUsers = const {},
  });

  @override
  List<Object?> get props => [
    status,
    errorMessage,
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
    typingUsers,
    onlineUsers,
  ];

  ChatState copyWith({
    ChatStatus? status,
    String? errorMessage,
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
      errorMessage: errorMessage ?? this.errorMessage,
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
      typingUsers: typingUsers ?? this.typingUsers,
      onlineUsers: onlineUsers ?? this.onlineUsers,
    );
  }

  // Helper methods
  bool isUserTyping(String roomId, String userId) {
    return typingUsers['${roomId}_$userId'] ?? false;
  }

  bool isUserOnline(String userId) {
    return onlineUsers[userId] ?? false;
  }

  List<ChatMessage> getMessagesForRoom(String roomId) {
    return messages.where((msg) => msg.roomId == roomId).toList();
  }

  ChatRoom? getRoomById(String roomId) {
    try {
      return chatRooms.firstWhere((room) => room.id == roomId);
    } catch (_) {
      return null;
    }
  }
}