

import 'dart:async';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import '../Service/firebase_database.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final FirebaseDbHelper _firebaseDbHelper;
  StreamSubscription? _messagesSubscription;
  StreamSubscription? _roomsSubscription;

  ChatBloc(this._firebaseDbHelper) : super(const ChatState()) {
    on<LoadChatRooms>(_onLoadChatRooms);
    on<ChatRoomsUpdated>(_onChatRoomsUpdated);
    on<LoadChatMessages>(_onLoadChatMessages);
    on<ChatMessagesUpdated>(_onChatMessagesUpdated);
    on<SendMessage>(_onSendMessage);
    on<MessageSent>(_onMessageSent);
    on<MessageSendFailed>(_onMessageSendFailed);
    on<MarkMessagesAsRead>(_onMarkMessagesAsRead);
  }

  Future<void> _onLoadChatRooms(
      LoadChatRooms event,
      Emitter<ChatState> emit,
      ) async {
    try {


      await _roomsSubscription?.cancel();
      _roomsSubscription = _firebaseDbHelper
        .getChatRooms(event.userId)
        .listen(
    (chatRooms) => add(ChatRoomsUpdated(chatRooms)),
    onError: (error) {
    log('Error loading chat rooms: $error');
    emit(state.copyWith(

    errorMessage: 'Failed to load chat rooms: $error',
    ));
    },
    );
    } catch (e) {
    log('Error in _onLoadChatRooms: $e');
    emit(state.copyWith(

    errorMessage: 'Failed to load chat rooms: $e',
    ));
    }
  }

  void _onChatRoomsUpdated(
      ChatRoomsUpdated event,
      Emitter<ChatState> emit,
      ) {
    emit(state.copyWith(

      chatRooms: event.chatRooms,
    ));
  }

  Future<void> _onLoadChatMessages(
      LoadChatMessages event,
      Emitter<ChatState> emit,
      ) async {



      await _messagesSubscription?.cancel();
      _messagesSubscription = _firebaseDbHelper
          .getChatMessages(event.userId, event.otherUserId)
          .listen(
            (messages) => add(ChatMessagesUpdated(messages)),
        onError: (error) {
          log('Error loading chat messages: $error');
          emit(state.copyWith(

            errorMessage: 'Failed to load messages: $error',
          ));
        },
      );

  }

  void _onChatMessagesUpdated(
      ChatMessagesUpdated event,
      Emitter<ChatState> emit,
      ) {
    emit(state.copyWith(

      messages: event.messages,
    ));
  }

  Future<void> _onSendMessage(
      SendMessage event,
      Emitter<ChatState> emit,
      ) async {
    try {
      emit(state.copyWith(isSendingMessage: true));

      await _firebaseDbHelper.sendMessage(event.message);
      add(const MessageSent());
    } catch (e) {
      log('Error sending message: $e');
      add(MessageSendFailed('Failed to send message: $e'));
    }
  }

  void _onMessageSent(
      MessageSent event,
      Emitter<ChatState> emit,
      ) {
    emit(state.copyWith(isSendingMessage: false));
  }

  void _onMessageSendFailed(
      MessageSendFailed event,
      Emitter<ChatState> emit,
      ) {
    emit(state.copyWith(
      isSendingMessage: false,
      errorMessage: event.error,
    ));
  }

  Future<void> _onMarkMessagesAsRead(
      MarkMessagesAsRead event,
      Emitter<ChatState> emit,
      ) async {
    try {
      await _firebaseDbHelper.markMessagesAsRead(event.roomId, event.userId);
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