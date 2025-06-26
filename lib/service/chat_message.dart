import 'package:cloud_firestore/cloud_firestore.dart';



enum MessageStatus { sending, sent, delivered, read, failed }

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String content;
  final Timestamp timestamp;
  final bool isRead;

  final MessageStatus status;
  final String? attachmentUrl;
  final Map<String, dynamic>? metadata;
  final String roomId;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    required this.roomId,
    this.isRead = false,
    this.status = MessageStatus.sent,
    this.attachmentUrl,
    this.metadata,
  });

  ChatMessage copyWith({
    String? id,
    String? senderId,

    String? senderName,
    String? receiverId,
    String? content,
    Timestamp? timestamp,
    bool? isRead,
    String? type,
    MessageStatus? status,
    String? attachmentUrl,
    Map<String, dynamic>? metadata,
    String? roomId,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,

      status: status ?? this.status,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      metadata: metadata ?? this.metadata,
      roomId: roomId ?? this.roomId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'content': content,
      'timestamp': timestamp,
      'isRead': isRead,

      'status': status.name,
      'attachmentUrl': attachmentUrl,
      'metadata': metadata,
      'roomId': roomId,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      receiverId: map['receiverId'] ?? '',
      content: map['content'] ?? '',
      timestamp: map['timestamp'],
      isRead: map['isRead'] ?? false,
      status: MessageStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => MessageStatus.sent,
      ),

      attachmentUrl: map['attachmentUrl'],
      metadata:
          map['metadata'] != null
              ? Map<String, dynamic>.from(map['metadata'])
              : null,
      roomId: map['roomId'] ?? '',
    );
  }

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      receiverId: data['receiverId'] ?? '',
      content: data['content'] ?? '',
      timestamp: data['timestamp'],
      isRead: data['isRead'] ?? false,
      status: MessageStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => MessageStatus.sent,
      ),
      attachmentUrl: data['attachmentUrl'],
      metadata:
          data['metadata'] != null
              ? Map<String, dynamic>.from(data['metadata'])
              : null,
      roomId: data['roomId'] ?? '',
    );
  }
}

class UserContact {
  final String id;
  final String name;
  final String? email;
  final String? profileImage;
  final String? phone;
  final bool isOnline;
  final DateTime? lastSeen;
  final String role;

  const UserContact({
    required this.id,
    required this.name,
    this.email,
    this.profileImage,
    this.phone,
    this.isOnline = false,
    this.lastSeen,
    this.role = 'user',
  });

  UserContact copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImage,
    String? phone,
    bool? isOnline,
    DateTime? lastSeen,
    String? role,
  }) {
    return UserContact(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      phone: phone ?? this.phone,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'phone': phone,
      'isOnline': isOnline,
      'lastSeen': lastSeen?.toIso8601String(),
      'role': role,
    };
  }

  factory UserContact.fromMap(Map<String, dynamic> map) {
    return UserContact(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'],
      profileImage: map['profileImage'],
      phone: map['phone'],
      isOnline: map['isOnline'] ?? false,
      lastSeen:
          map['lastSeen'] != null ? DateTime.parse(map['lastSeen']) : null,
      role: map['role'] ?? 'user',
    );
  }

  factory UserContact.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserContact(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'],
      profileImage: data['profileImage'],
      phone: data['phone'],
      isOnline: data['isOnline'] ?? false,
      lastSeen:
          data['lastSeen'] != null
              ? (data['lastSeen'] as Timestamp).toDate()
              : null,
      role: data['role'] ?? 'user',
    );
  }
}
