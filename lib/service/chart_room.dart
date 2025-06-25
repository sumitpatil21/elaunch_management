import 'package:cloud_firestore/cloud_firestore.dart';

import '../Service/chat_message.dart';

class ChatRoom {
  final String id;
  final List<String> participantIds;
  final String? lastMessage;
  final Timestamp? lastMessageTime;
  final String? lastMessageSenderId;

  // final String unreadCount;
  final Map<String, dynamic> participantDetails;

  const ChatRoom({
    required this.id,
    required this.participantIds,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageSenderId,
    // this.unreadCount = "0",
    this.participantDetails = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participantIds': participantIds,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'lastMessageSenderId': lastMessageSenderId,
      // 'unreadCount': unreadCount,
      'participantDetails': participantDetails,
    };
  }

  factory ChatRoom.fromMap(Map map) {
    return ChatRoom(
      id: map['id'] ?? '',
      participantIds: List<String>.from(map['participantIds'] ?? []),
      lastMessage: map['lastMessage']??"",
      lastMessageTime: map['lastMessageTime'],
      lastMessageSenderId: map['lastMessageSenderId'],
      // unreadCount: map['unreadCount'],
      participantDetails: Map<String, dynamic>.from(map['participantDetails'] ?? {}),
    );
  }
}