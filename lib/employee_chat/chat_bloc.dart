import 'dart:async';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elaunch_management/service/chat_message.dart';
import 'package:elaunch_management/service/firebase_database.dart';
import '../Employee/employee_event.dart';
import '../Employee/employee_state.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  StreamSubscription? _messagesSubscription;
  StreamSubscription? _roomsSubscription;

  ChatBloc() : super(const ChatState()) {
    on<LoadChatRooms>(loadChatRooms);
    on<ChatRoomsUpdated>(chatRoomsUpdated);
    on<CreateChatRoom>(createChatRoom);
    on<LoadChatMessages>(loadChatMessages);
    on<ChatMessagesUpdated>(chatMessagesUpdated);
    on<SendMessage>(sendMessage);
    on<MarkMessagesAsRead>(markMessagesAsRead);
  }

  Future<void> loadChatRooms(
    LoadChatRooms event,
    Emitter<ChatState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoadingRooms: true,
        status: ChatStatus.loading,
        errorMessage: null,
      ),
    );

    await _roomsSubscription?.cancel();

    _roomsSubscription = FirebaseDbHelper.firebase
        .getChatRooms(event.userId)
        .listen(
          (rooms) => add(ChatRoomsUpdated(rooms)),
          onError: (error) {
            log('Error in chat rooms stream: $error');
            add(ChatRoomsUpdated([]));
            emit(
              state.copyWith(
                status: ChatStatus.failure,
                errorMessage: 'Failed to load chat rooms',
                isLoadingRooms: false,
              ),
            );
          },
        );
  }

  void chatRoomsUpdated(ChatRoomsUpdated event, Emitter<ChatState> emit) {
    emit(
      state.copyWith(
        chatRooms: event.chatRooms,
        isLoadingRooms: false,
        status: ChatStatus.success,
      ),
    );
  }

  Future<void> createChatRoom(
    CreateChatRoom event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(isLoadingRooms: true, status: ChatStatus.loading));

    final roomId = await FirebaseDbHelper.firebase.createChatRoom(
      event.currentUserId,
      event.otherUserId,
    );

    emit(
      state.copyWith(
        isLoadingRooms: false,
        currentRoomId: roomId,
        status: ChatStatus.success,
      ),
    );
  }

  Future<void> loadChatMessages(
    LoadChatMessages event,
    Emitter<ChatState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoadingMessages: true,
        currentRoomId: event.roomId,
        status: ChatStatus.loading,
        errorMessage: null,
      ),
    );

    await _messagesSubscription?.cancel();

    _messagesSubscription = FirebaseDbHelper.firebase
        .getChatMessages(event.roomId)
        .listen(
          (messages) {
            final roomMessages =
                messages.where((msg) => msg.roomId == event.roomId).toList();
            add(ChatMessagesUpdated(roomMessages));
          },
          onError: (error) {
            log('Error in chat messages stream: $error');
            emit(
              state.copyWith(
                isLoadingMessages: false,

                status: ChatStatus.failure,
                errorMessage: 'Failed to load messages',
              ),
            );
          },
        );
  }

  void chatMessagesUpdated(ChatMessagesUpdated event, Emitter<ChatState> emit) {
    final Map<String, List<ChatMessage>> messagesByRoom = {};

    for (final message in event.messages) {
      if (!messagesByRoom.containsKey(message.roomId)) {
        messagesByRoom[message.roomId] = [];
      }
      messagesByRoom[message.roomId]!.add(message);
    }

    messagesByRoom.forEach((roomId, messages) {
      messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    });

    emit(
      state.copyWith(
        messagesByRoom: messagesByRoom,
        messages: event.messages,
        isLoadingMessages: false,
        status: ChatStatus.success,
      ),
    );
  }

  // In your ChatBloc
  Future<void> sendMessage(SendMessage event, Emitter<ChatState> emit) async {
    emit(state.copyWith(isSendingMessage: true));

    final messageToSend = event.message.copyWith(
      timestamp: Timestamp.fromDate(DateTime.now()),
      status: MessageStatus.sending,
    );

    // Update UI immediately
    final currentMessages = List<ChatMessage>.from(state.messages);
    currentMessages.insert(0, messageToSend);

    final updatedMessagesByRoom = Map<String, List<ChatMessage>>.from(
      state.messagesByRoom,
    );
    if (!updatedMessagesByRoom.containsKey(messageToSend.roomId)) {
      updatedMessagesByRoom[messageToSend.roomId] = [];
    }
    updatedMessagesByRoom[messageToSend.roomId]!.insert(0, messageToSend);

    emit(
      state.copyWith(
        messages: currentMessages,
        messagesByRoom: updatedMessagesByRoom,
        isSendingMessage: true,
      ),
    );

    try {
      // Send message to Firebase
      await FirebaseDbHelper.firebase.sendMessage(messageToSend);

      // Send push notification
      await FirebaseDbHelper.firebase.sendPushNotification(messageToSend);

      emit(state.copyWith(isSendingMessage: false));
    } catch (e) {
      emit(
        state.copyWith(
          isSendingMessage: false,
          status: ChatStatus.failure,
          errorMessage: 'Failed to send message',
        ),
      );
    }
  }

  Future<void> markMessagesAsRead(
    MarkMessagesAsRead event,
    Emitter<ChatState> emit,
  ) async {
    await FirebaseDbHelper.firebase.markMessagesAsRead(
      event.roomId,
      event.userId,
    );
    final updatedMessages =
        state.messages.map((msg) {
          if (msg.roomId == event.roomId && msg.receiverId == event.userId) {
            return msg.copyWith(isRead: true);
          }
          return msg;
        }).toList();

    final updatedMessagesByRoom = Map<String, List<ChatMessage>>.from(
      state.messagesByRoom,
    );
    if (updatedMessagesByRoom.containsKey(event.roomId)) {
      updatedMessagesByRoom[event.roomId] =
          updatedMessagesByRoom[event.roomId]!.map((msg) {
            if (msg.receiverId == event.userId) {
              return msg.copyWith(isRead: true);
            }
            return msg;
          }).toList();
    }

    emit(
      state.copyWith(
        messages: updatedMessages,
        messagesByRoom: updatedMessagesByRoom,
      ),
    );
  }


}
