import 'dart:async';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:elaunch_management/service/chat_message.dart';
import 'package:elaunch_management/service/firebase_database.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final FirebaseDbHelper _firebaseDbHelper;
  StreamSubscription? _messagesSubscription;
  StreamSubscription? _roomsSubscription;

  ChatBloc({required FirebaseDbHelper firebaseDbHelper})
    : _firebaseDbHelper = firebaseDbHelper,
      super(const ChatState()) {
    on<LoadChatRooms>(_onLoadChatRooms);
    on<ChatRoomsUpdated>(_onChatRoomsUpdated);
    on<CreateChatRoom>(_onCreateChatRoom);
    on<LoadChatMessages>(_onLoadChatMessages);
    on<ChatMessagesUpdated>(_onChatMessagesUpdated);
    on<SendMessage>(_onSendMessage);
    on<MarkMessagesAsRead>(_onMarkMessagesAsRead);
  }

  Future<void> _onLoadChatRooms(
    LoadChatRooms event,
    Emitter<ChatState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoadingRooms: true));

      await _roomsSubscription?.cancel();
      _roomsSubscription = _firebaseDbHelper
          .getChatRooms(event.userId)
          .listen((rooms) => add(ChatRoomsUpdated(rooms)));
    } catch (e) {
      log('Error loading chat rooms: $e');
      emit(
        state.copyWith(
          status: ChatStatus.failure,
          errorMessage: 'Failed to load chat rooms',
        ),
      );
    }
  }

  void _onChatRoomsUpdated(ChatRoomsUpdated event, Emitter<ChatState> emit) {
    emit(
      state.copyWith(
        chatRooms: event.chatRooms,
        isLoadingRooms: false,
        status: ChatStatus.success,
      ),
    );
  }

  Future<void> _onCreateChatRoom(
    CreateChatRoom event,
    Emitter<ChatState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoadingRooms: true));

      final roomId = await _firebaseDbHelper.createChatRoom(
        event.currentUserId,
        event.otherUserId,
      );

      emit(state.copyWith(isLoadingRooms: false, currentRoomId: roomId));
    } catch (e) {
      log('Error creating chat room: $e');
      emit(
        state.copyWith(
          isLoadingRooms: false,
          status: ChatStatus.failure,
          errorMessage: 'Failed to create chat room',
        ),
      );
    }
  }

  Future<void> _onLoadChatMessages(
    LoadChatMessages event,
    Emitter<ChatState> emit,
  ) async {
    try {
      emit(
        state.copyWith(isLoadingMessages: true, currentRoomId: event.roomId),
      );

      await _messagesSubscription?.cancel();
      _messagesSubscription = _firebaseDbHelper
          .getChatMessages(event.roomId)
          .listen((messages) => add(ChatMessagesUpdated(messages)));
    } catch (e) {
      log('Error loading messages: $e');
      emit(
        state.copyWith(
          isLoadingMessages: false,
          status: ChatStatus.failure,
          errorMessage: 'Failed to load messages',
        ),
      );
    }
  }

  void _onChatMessagesUpdated(
    ChatMessagesUpdated event,
    Emitter<ChatState> emit,
  ) {
    emit(
      state.copyWith(
        messages: event.messages,
        isLoadingMessages: false,
        status: ChatStatus.success,
      ),
    );
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    try {
      emit(state.copyWith(isSendingMessage: true));

      // Optimistically add message to state
      final tempMessage = event.message.copyWith(
        status: MessageStatus.sending,
        timestamp: DateTime.now(),
      );
      emit(state.copyWith(messages: [...state.messages, tempMessage]));

      // Send to Firebase
      await _firebaseDbHelper.sendMessage(event.message);

      emit(state.copyWith(isSendingMessage: false));
    } catch (e) {
      log('Error sending message: $e');
      emit(
        state.copyWith(
          isSendingMessage: false,
          status: ChatStatus.failure,
          errorMessage: 'Failed to send message',
        ),
      );
    }
  }

  Future<void> _onMarkMessagesAsRead(
    MarkMessagesAsRead event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _firebaseDbHelper.markMessagesAsRead(event.roomId, event.userId);

      final updatedMessages =
          state.messages.map((msg) {
            if (msg.roomId == event.roomId && msg.receiverId == event.userId) {
              return msg.copyWith(isRead: true);
            }
            return msg;
          }).toList();

      emit(state.copyWith(messages: updatedMessages));
    } catch (e) {
      log('Error marking messages as read: $e');
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    _roomsSubscription?.cancel();
    return super.close();
  }
}
