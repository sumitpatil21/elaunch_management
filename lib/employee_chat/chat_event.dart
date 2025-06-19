
import 'package:equatable/equatable.dart';

import '../Service/chart_room.dart';
import '../Service/chat_message.dart';




abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadChatRooms extends ChatEvent {
  final String userId;

  const LoadChatRooms(this.userId);

  @override
  List<Object?> get props => [userId];
}

class ChatRoomsUpdated extends ChatEvent {
  final List<ChatRoom> chatRooms;

  const ChatRoomsUpdated(this.chatRooms);

  @override
  List<Object?> get props => [chatRooms];
}

class LoadChatMessages extends ChatEvent {
  final String userId;
  final String otherUserId;

  const LoadChatMessages(this.userId, this.otherUserId);

  @override
  List<Object?> get props => [userId, otherUserId];
}

class ChatMessagesUpdated extends ChatEvent {
  final List<ChatMessage> messages;

  const ChatMessagesUpdated(this.messages);

  @override
  List<Object?> get props => [messages];
}

class SendMessage extends ChatEvent {
  final ChatMessage message;

  const SendMessage(this.message);

  @override
  List<Object?> get props => [message];
}

class MarkMessagesAsRead extends ChatEvent {
  final String roomId;
  final String userId;

  const MarkMessagesAsRead(this.roomId, this.userId);

  @override
  List<Object?> get props => [roomId, userId];
}

class MessageSent extends ChatEvent {
  const MessageSent();
}

class MessageSendFailed extends ChatEvent {
  final String error;

  const MessageSendFailed(this.error);

  @override
  List<Object?> get props => [error];
}
