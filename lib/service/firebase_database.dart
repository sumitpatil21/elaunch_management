
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elaunch_management/Service/device_modal.dart';
import 'package:elaunch_management/Service/system_modal.dart';

import '../service/employee_modal.dart';
import 'admin_modal.dart';
import 'chart_room.dart';
import 'chat_message.dart';
import 'department_modal.dart';
import 'leave_modal.dart';

class FirebaseDbHelper {
  FirebaseDbHelper._();
  static final firebase = FirebaseDbHelper._();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  CollectionReference get admins => firestore.collection('admins');
  CollectionReference get departments => firestore.collection('departments');
  CollectionReference get employees => firestore.collection('employees');
  CollectionReference get systems => firestore.collection('systems');
  CollectionReference get devices => firestore.collection('devices');
  CollectionReference get leaves => firestore.collection('leaves');
  CollectionReference get chatMessages => firestore.collection('chat_messages');
  CollectionReference get chatRooms => firestore.collection('chat_rooms');
  CollectionReference get users => firestore.collection('users');

  Future<void> createAdmin(AdminModal admin) async {
    final doc = await admins.add(admin.toMap());
    log("Admin created with ID: ${doc.id}");
  }

  Future<void> updateAdminStatus(String email, String status) async {
    final query = await admins.where('email', isEqualTo: email).get();
    for (final doc in query.docs) {
      await doc.reference.update({'status': status});
    }
  }

  Future<List<AdminModal>> getAdminByEmail(String email) async {
    final query = await admins.where('email', isEqualTo: email).get();
    return query.docs
        .map(
          (doc) => AdminModal.fromJson({
        ...doc.data() as Map<String, dynamic>,
        'id': doc.id,
      }),
    )
        .toList();
  }

  Future<List<AdminModal>> getAllAdmins() async {
    final snapshot = await admins.get();
    return snapshot.docs
        .map(
          (doc) => AdminModal.fromJson({
        ...doc.data() as Map<String, dynamic>,
        'id': doc.id,
      }),
    )
        .toList();
  }

  // Department methods...
  Future<void> createDepartment(DepartmentModal department) async {
    final docRef = departments.doc();
    await docRef.set({
      ...department.toJson(),
      'id': docRef.id,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<DepartmentModal>> getDepartments([String? adminId]) async {
    Query query = departments;

    if (adminId != null) {
      query = query.where('adminRef', isEqualTo: admins.doc(adminId));
    }

    final snapshot = await query.get();

    return snapshot.docs.map((doc) {
      final data = doc.data()! as Map<String, dynamic>;
      return DepartmentModal.fromJson({
        ...data,
        'id': doc.id,
      });
    }).toList();
  }

  Future<void> updateDepartment(DepartmentModal department) async {
    await departments.doc(department.id).update({
      ...department.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteDepartment(String id) async {
    final hasEmployees =
        (await employees
            .where('departmentRef', isEqualTo: departments.doc(id))
            .get())
            .docs
            .isNotEmpty;

    if (hasEmployees) {
      throw Exception('department has employees and cannot be deleted');
    }
    await departments.doc(id).delete();
  }

  // Employee methods...
  Future<void> createEmployee(EmployeeModal employee) async {
    if (!(await departments.doc(employee.departmentId).get()).exists) {
      throw Exception('department does not exist');
    }

    final docRef = employees.doc();
    await docRef.set({
      ...employee.toJson(),
      'id': docRef.id,
      'departmentRef': departments.doc(employee.departmentId),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<EmployeeModal>> getEmployees({
    String? role,
    String? departmentId,
    String? adminId,
  }) async {
    Query query = employees;

    if (role != null) query = query.where('role', isEqualTo: role);
    if (departmentId != null) {
      query = query.where(
        'departmentRef',
        isEqualTo: departments.doc(departmentId),
      );
    }
    if (adminId != null) {
      query = query.where('adminRef', isEqualTo: admins.doc(adminId));
    }

    final snapshot = await query.get();
    log("employee docs count: ${snapshot.docs.length}");

    return snapshot.docs.map((doc) {
      final data = doc.data()! as Map<String, dynamic>;
      log("employee data: $data");
      return EmployeeModal.fromJson(data);
    }).toList();
  }

  Future<List<EmployeeModal>> getEmployeeByEmail(String email) async {
    final query = await employees.where('email', isEqualTo: email).get();
    return query.docs
        .map(
          (doc) => EmployeeModal.fromJson({
        ...doc.data() as Map<String, dynamic>,
        'id': doc.id,
      }),
    )
        .toList();
  }

  Future<void> updateEmployee(EmployeeModal employee) async {
    if (employee.id == null) return;
    await employees.doc(employee.id).update({
      ...employee.toJson(),
      'departmentRef': departments.doc(employee.departmentId.toString()),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteEmployee(String id) async {
    await employees.doc(id).delete();
  }

  Future<EmployeeModal?> getEmployeeById(String id) async {
    final doc = await employees.doc(id).get();
    if (doc.exists) {
      return EmployeeModal.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // FIXED CHAT METHODS
  Future<String> createChatRoom(
      String currentUserId,
      String otherUserId,
      ) async {
    final roomId = _generateRoomId(currentUserId, otherUserId);
    final participants = [currentUserId, otherUserId]..sort();

    // Check if room already exists
    final existingRoom = await chatRooms.doc(roomId).get();

    if (!existingRoom.exists) {
      await chatRooms.doc(roomId).set({
        'id': roomId,
        'participants': participants,
        'participantIds': participants, // Add this for easier querying
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSenderId': '',
        'unreadCount': {
          currentUserId: 0,
          otherUserId: 0
        },
      });
    }

    return roomId;
  }

  String _generateRoomId(String id1, String id2) {
    final ids = [id1, id2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  Future<void> sendMessage(ChatMessage message) async {
    try {
      // Generate unique message ID
      final messageRef = chatMessages.doc();
      final messageId = messageRef.id;

      // Create the message document
      final messageData = {
        'id': messageId,
        'roomId': message.roomId,
        'senderId': message.senderId,
        'senderName': message.senderName,
        'receiverId': message.receiverId,
        'content': message.content,
        'timestamp': FieldValue.serverTimestamp(),
        'status': MessageStatus.sent.toString().split('.').last,
        'isRead': false,
      };

      // Use batch write for consistency
      final batch = firestore.batch();

      // Add message
      batch.set(messageRef, messageData);

      // Update chat room
      batch.update(chatRooms.doc(message.roomId), {
        'lastMessage': message.content,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSenderId': message.senderId,
        'unreadCount.${message.receiverId}': FieldValue.increment(1),
      });


    await batch.commit();

    log('Message sent successfully: $messageId');

    // Send push notification to receiver
    await _sendPushNotification(message);

    } catch (e) {
    log('Error sending message: $e');
    throw Exception('Failed to send message: $e');
    }
  }

  Future<void> _sendPushNotification(ChatMessage message) async {
    try {
      // Get receiver's FCM token
      final receiverDoc = await employees.doc(message.receiverId).get();

      if (receiverDoc.exists) {
        final receiverData = receiverDoc.data() as Map<String, dynamic>;
        final fcmToken = receiverData['fcmToken'] as String?;

        if (fcmToken != null && fcmToken.isNotEmpty) {
          // Here you would call your cloud function or use Firebase Admin SDK
          // For now, we'll just log it
          log('Should send notification to token: $fcmToken');
          log('Message: ${message.content}');
          log('From: ${message.senderName}');

          // You can implement this by calling a cloud function:
          /*
          await FirebaseFunctions.instance
              .httpsCallable('sendChatNotification')
              .call({
            'token': fcmToken,
            'title': 'New message from ${message.senderName}',
            'body': message.content,
            'data': {
              'type': 'chat',
              'roomId': message.roomId,
              'senderId': message.senderId,
              'senderName': message.senderName,
            }
          });
          */
        }
      }
    } catch (e) {
      log('Error sending push notification: $e');
      // Don't throw here as message was already sent successfully
    }
  }

  Stream<List<ChatRoom>> getChatRooms(String userId) {
    return chatRooms
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ChatRoom.fromMap({
          ...data,
          'id': doc.id,
        });
      })
          .toList(),
    );
  }

  Stream<List<ChatMessage>> getChatMessages(String roomId) {
    return chatMessages
        .where('roomId', isEqualTo: roomId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ChatMessage.fromMap({
          ...data,
          'id': doc.id,
        });
      })
          .toList(),
    );
  }

  Future<void> markMessagesAsRead(String roomId, String userId) async {
    try {
      final unreadMessages = await chatMessages
          .where('roomId', isEqualTo: roomId)
          .where('receiverId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      if (unreadMessages.docs.isNotEmpty) {
        final batch = firestore.batch();

        for (final doc in unreadMessages.docs) {
          batch.update(doc.reference, {'isRead': true});
        }

        batch.update(chatRooms.doc(roomId), {
          'unreadCount.$userId': 0
        });

        await batch.commit();
        log('Marked ${unreadMessages.docs.length} messages as read');
      }
    } catch (e) {
      log('Error marking messages as read: $e');
    }
  }

  Future<void> updateMessageStatus(
      String messageId,
      MessageStatus status,
      ) async {
    try {
      await chatMessages.doc(messageId).update({
        'status': status.toString().split('.').last,
      });
    } catch (e) {
      log('Error updating message status: $e');
    }
  }

  Future<void> deleteMessage(String messageId, String roomId) async {
    try {
      await chatMessages.doc(messageId).delete();
    } catch (e) {
      log('Error deleting message: $e');
    }
  }


  Future<void> updateFCMToken(String userId, String token) async {
    try {
      await employees.doc(userId).update({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });
      log('FCM token updated for user: $userId');
    } catch (e) {
      log('Error updating FCM token: $e');
    }
  }

  Future<String?> getFCMToken(String userId) async {
    try {
      final doc = await employees.doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['fcmToken'] as String?;
      }
    } catch (e) {
      log('Error getting FCM token: $e');
    }
    return null;
  }

  // Online status management
  Future<void> updateOnlineStatus(String userId, bool isOnline) async {
    try {
      await employees.doc(userId).update({
        'isOnline': isOnline,
        'lastSeen': isOnline ? null : FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log('Error updating online status: $e');
    }
  }

  // Typing indicators
  Future<void> startTyping(String roomId, String userId) async {
    try {
      await chatRooms.doc(roomId).update({
        'typing.$userId': true,
        'typingLastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log('Error starting typing: $e');
    }
  }
// In FirebaseDbHelper class


  Future<void> stopTyping(String roomId, String userId) async {
    try {
      await chatRooms.doc(roomId).update({
        'typing.$userId': false,
        'typingLastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log('Error stopping typing: $e');
    }
  }
  Future<void> sendPushNotification(ChatMessage message) async {
    try {
      // Get receiver's FCM token
      final receiverDoc = await employees.doc(message.receiverId).get();

      if (receiverDoc.exists) {
        final receiverData = receiverDoc.data() as Map<String, dynamic>;
        final fcmToken = receiverData['fcmToken'] as String?;

        if (fcmToken != null && fcmToken.isNotEmpty) {
          // Call your cloud function to send the notification
          await firestore.collection('notifications').add({
            'to': fcmToken,
            'notification': {
              'title': 'New message from ${message.senderName}',
              'body': message.content,
              'sound': 'default',
            },
            'data': {
              'type': 'chat',
              'roomId': message.roomId,
              'senderId': message.senderId,
              'senderName': message.senderName,
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            },
            'priority': 'high',
          });
        }
      }
    } catch (e) {
      log('Error sending push notification: $e');
    }
  }



  Future<void> createSystem(SystemModal system) async {
    final docRef = systems.doc();

    await docRef.set({
      ...system.toJson(),
      'id': docRef.id,
      'adminRef': admins.doc(system.adminId.toString()),
      if (system.employeeId != null)
        'employeeRef': employees.doc(system.employeeId.toString()),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<SystemModal>> getSystems([String? adminId]) async {
    Query query = systems;

    if (adminId != null) {
      query = query.where('adminRef', isEqualTo: admins.doc(adminId));
    }

    final snapshot = await query.get();
    log("system docs count: ${snapshot.docs.length}");

    return snapshot.docs.map((doc) {
      final data = doc.data()! as Map<String, dynamic>;
      log("system data: $data");
      return SystemModal.fromJson({
        ...data,
        'id': doc.id,
        'adminId': (data['adminRef'] as DocumentReference).id,
        if (data['employeeRef'] != null)
          'employeeId': (data['employeeRef'] as DocumentReference).id,
      });
    }).toList();
  }

  Future<List<SystemModal>> getAllSystems() async {
    return getSystems();
  }

  Future<void> updateSystem(SystemModal system) async {
    if (system.id == null) return;
    await systems.doc(system.id).update({
      ...system.toJson(),
      'adminRef': admins.doc(system.adminId.toString()),
      if (system.employeeId != null)
        'employeeRef': employees.doc(system.employeeId.toString()),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteSystem(String id) async {
    await systems.doc(id).delete();
  }

  Future<void> createSystemRequests(SystemModal system) async {
    await systems.doc(system.id).update({
      'isRequested': system.isRequested ?? true,
      'requestId': system.requestId,
      'requestedByName': system.requestedByName,
      'requestedAt':
          system.requestedAt != null ? FieldValue.serverTimestamp() : null,
      'requestStatus': system.requestStatus ?? 'pending',
    });
  }

  Future<List<SystemModal>> fetchRequests() async {
    final snapshot =
        await systems
            .where('isRequested', isEqualTo: true)
            .where('requestStatus', isEqualTo: 'pending')
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return SystemModal.fromJson({...data, 'id': doc.id});
    }).toList();
  }

  Future<void> approveSystemRequest(SystemModal system) async {
    await systems.doc(system.id).update({
      'systemName': system.systemName,
      'version': system.version,
      'operatingSystem': system.operatingSystem,
      'status': system.status,
      'employee_name': system.employeeName,
      'id_employee': system.employeeId,
      'id_admin': system.adminId,
      'isRequested': false,
      'requested_by_name': null,
      'requestId': null,
      'request_status': 'approved',
      'approvedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> rejectSystemRequest(SystemModal system) async {
    await systems.doc(system.id).update({
      'systemName': system.systemName,
      'version': system.version,
      'operatingSystem': system.operatingSystem,
      'status': 'available',
      'employee_name': null,
      'id_employee': null,
      'id_admin': system.adminId,
      'isRequested': false,
      'requested_by_name': null,
      'requestId': null,
      'request_status': 'rejected',
      'rejectedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> cancelSystemRequest(String systemId, String requestId) async {
    await systems.doc(systemId).update({
      'isRequested': false,
      'request_status': 'cancelled',
      'requestId': null,
      'requested_by_name': null,
      'requestedAt': null,
      'cancelledAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> createDevice(TestingDeviceModal device) async {
    final docRef = devices.doc();
    await docRef.set({
      ...device.toJson(),
      'id': docRef.id,
      'adminRef': admins.doc(device.adminId.toString()),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<TestingDeviceModal>> getDevices([String? adminId]) async {
    Query query = devices;

    if (adminId != null) {
      query = query.where('adminRef', isEqualTo: admins.doc(adminId));
    }

    final snapshot = await query.get();
    log("Device docs count: ${snapshot.docs.length}");

    return snapshot.docs.map((doc) {
      final data = doc.data()! as Map<String, dynamic>;
      log("Device data: $data");
      return TestingDeviceModal.fromJson({
        ...data,
        'id': doc.id,
        'adminId': (data['adminRef'] as DocumentReference).id,
      });
    }).toList();
  }

  Future<List<TestingDeviceModal>> getAllDevices() async {
    return getDevices();
  }

  Future<void> updateDevice(TestingDeviceModal device) async {
    if (device.id == null) return;
    await devices.doc(device.id).update({
      ...device.toJson(),
      'adminRef': admins.doc(device.adminId.toString()),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteDevice(String id) async {
    await devices.doc(id).delete();
  }

  Future<void> approveDeviceRequest(TestingDeviceModal system) async {
    await devices.doc(system.id).update(system.toJson());
  }

  Future<void> rejectDeviceRequest(TestingDeviceModal system) async {
    await devices.doc(system.id).update(system.toJson());
  }

  Future<void> cancelDeviceRequest(String systemId, String requestId) async {
    await devices.doc(systemId).update({
      'isRequested': false,
      'request_status': 'cancelled',
      'requestId': null,
      'requested_by_name': null,
      'requestedAt': null,
      'cancelledAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> createLeaves(LeaveModal leave) async {
    final docRef = leaves.doc();
    final leaveData = {
      ...leave.toMap(),
      'id': docRef.id,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await docRef.set(leaveData);
    print('leave created successfully with ID: ${docRef.id}');
    return docRef.id;
  }

  Future<List<LeaveModal>> getLeaves({
    String? employeeId,
    String? status,
  }) async {
    Query query = leaves.orderBy('createdAt', descending: true);

    if (employeeId != null && employeeId.isNotEmpty) {
      query = query.where('employeeId', isEqualTo: employeeId);
    }

    if (status != null && status.isNotEmpty && status != 'all') {
      query = query.where('status', isEqualTo: status);
    }

    final snapshot = await query.get();
    print('Retrieved ${snapshot.docs.length} leaves from Firestore');

    return snapshot.docs.map((doc) {
      final data = doc.data()! as Map<String, dynamic>;
      return LeaveModal.fromMap({...data, 'id': doc.id});
    }).toList();
  }

  Future<void> updateLeaves(LeaveModal leave) async {
    if (leave.id.isEmpty) {
      throw Exception('leave ID is required for update');
    }

    final updateData = {
      ...leave.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await leaves.doc(leave.id).update(updateData);
    print('leave updated successfully: ${leave.id}');
  }

  Future<void> deleteLeave(String id) async {
    await leaves.doc(id).delete();
    print('leave deleted successfully: $id');
  }

  Future<LeaveModal?> getLeaveById(String id) async {
    if (id.isEmpty) {
      throw Exception('leave ID is required');
    }

    final doc = await leaves.doc(id).get();
    if (doc.exists) {
      final data = doc.data()! as Map<String, dynamic>;
      return LeaveModal.fromMap({...data, 'id': doc.id});
    }
    return null;
  }

}
