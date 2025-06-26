

import 'package:equatable/equatable.dart';


import '../service/chart_room.dart';
import '../service/chat_message.dart';

class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

// Chat Rooms
class LoadChatRooms extends ChatEvent {
  final String userId;

  const LoadChatRooms(this.userId);

  @override
  List<Object> get props => [userId];
}

class ChatRoomsUpdated extends ChatEvent {
  final List<ChatRoom> chatRooms;

  const ChatRoomsUpdated(this.chatRooms);

  @override
  List<Object> get props => [chatRooms];
}

class CreateChatRoom extends ChatEvent {
  final String currentUserId;
  final String otherUserId;

  const CreateChatRoom({required this.currentUserId, required this.otherUserId});

  @override
  List<Object> get props => [currentUserId, otherUserId];
}

// Messages
class LoadChatMessages extends ChatEvent {
  final String userId;
  final String otherUserId;
  final String roomId;

  const LoadChatMessages({
    required this.userId,
    required this.otherUserId,
    required this.roomId,
  });

  @override
  List<Object> get props => [userId, otherUserId, roomId];
}

class ChatMessagesUpdated extends ChatEvent {
  final List<ChatMessage> messages;

  const ChatMessagesUpdated(this.messages);

  @override
  List<Object> get props => [messages];
}

class SendMessage extends ChatEvent {
  final ChatMessage message;

  const SendMessage(this.message);

  @override
  List<Object> get props => [message];
}

class UpdateMessageStatus extends ChatEvent {
  final String messageId;
  final MessageStatus status;

  const UpdateMessageStatus(this.messageId, this.status);

  @override
  List<Object> get props => [messageId, status];
}

class DeleteMessage extends ChatEvent {
  final String messageId;
  final String roomId;

  const DeleteMessage(this.messageId, this.roomId);

  @override
  List<Object> get props => [messageId, roomId];
}

// Read Status
class MarkMessagesAsRead extends ChatEvent {
  final String roomId;
  final String userId;

  const MarkMessagesAsRead({required this.roomId, required this.userId});

  @override
  List<Object> get props => [roomId, userId];
}

// Contacts
class LoadUserContacts extends ChatEvent {
  final String userId;

  const LoadUserContacts(this.userId);

  @override
  List<Object> get props => [userId];
}

class UserContactsLoaded extends ChatEvent {
  final List<UserContact> contacts;

  const UserContactsLoaded(this.contacts);

  @override
  List<Object> get props => [contacts];
}

class SearchContacts extends ChatEvent {
  final String query;

  const SearchContacts(this.query);

  @override
  List<Object> get props => [query];
}

// Typing Indicators
class StartTyping extends ChatEvent {
  final String roomId;
  final String userId;

  const StartTyping(this.roomId, this.userId);

  @override
  List<Object> get props => [roomId, userId];
}

class StopTyping extends ChatEvent {
  final String roomId;
  final String userId;

  const StopTyping(this.roomId, this.userId);

  @override
  List<Object> get props => [roomId, userId];
}

// Online Status
class UpdateOnlineStatus extends ChatEvent {
  final String userId;
  final bool isOnline;

  const UpdateOnlineStatus(this.userId, this.isOnline);

  @override
  List<Object> get props => [userId, isOnline];
}

// Error Handling
class ClearError extends ChatEvent {
  const ClearError();
}