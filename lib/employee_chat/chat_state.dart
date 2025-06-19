import 'package:equatable/equatable.dart';

import '../Service/chart_room.dart';
import '../Service/chat_message.dart';

class ChatState extends Equatable {

  final List<ChatRoom> chatRooms;
  final List<ChatMessage> messages;
  final String? errorMessage;
  final bool isSendingMessage;

  const ChatState({

    this.chatRooms = const [],
    this.messages = const [],
    this.errorMessage,
    this.isSendingMessage = false,
  });

  ChatState copyWith({

    List<ChatRoom>? chatRooms,
    List<ChatMessage>? messages,
    String? errorMessage,
    bool? isSendingMessage,
  }) {
    return ChatState(

      chatRooms: chatRooms ?? this.chatRooms,
      messages: messages ?? this.messages,
      errorMessage: errorMessage,
      isSendingMessage: isSendingMessage ?? this.isSendingMessage,
    );
  }

  @override
  List<Object?> get props => [

    chatRooms,
    messages,
    errorMessage,
    isSendingMessage,
  ];
}