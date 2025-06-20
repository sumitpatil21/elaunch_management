
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
  StreamSubscription? _contactsSubscription;
  Timer? _typingTimer;

  ChatBloc({required FirebaseDbHelper firebaseDbHelper})
      : _firebaseDbHelper = firebaseDbHelper,
        super(const ChatState()) {
    // Event handlers
    _registerEventHandlers();
  }

  void _registerEventHandlers() {
    // Chat Rooms
    on<LoadChatRooms>(_onLoadChatRooms);
    on<ChatRoomsUpdated>(_onChatRoomsUpdated);
    on<CreateChatRoom>(_onCreateChatRoom);

    // Messages
    on<LoadChatMessages>(_onLoadChatMessages);
    on<ChatMessagesUpdated>(_onChatMessagesUpdated);
    on<SendMessage>(_onSendMessage);
    on<UpdateMessageStatus>(_onUpdateMessageStatus);
    on<DeleteMessage>(_onDeleteMessage);

    // Read Status
    on<MarkMessagesAsRead>(_onMarkMessagesAsRead);

    // Contacts
    on<LoadUserContacts>(_onLoadUserContacts);
    on<UserContactsLoaded>(_onUserContactsLoaded);
    on<SearchContacts>(_onSearchContacts);

    // Typing Indicators
    on<StartTyping>(_onStartTyping);
    on<StopTyping>(_onStopTyping);

    // Status
    on<UpdateOnlineStatus>(_onUpdateOnlineStatus);

    // Error Handling
    on<ClearError>(_onClearError);
  }

  // Chat Rooms
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
      emit(state.copyWith(
        status: ChatStatus.failure,
        errorMessage: 'Failed to load chat rooms',
      ));
    }
  }

  void _onChatRoomsUpdated(
      ChatRoomsUpdated event,
      Emitter<ChatState> emit,
      ) {
    emit(state.copyWith(
      chatRooms: event.chatRooms,
      isLoadingRooms: false,
      status: ChatStatus.success,
    ));
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

      emit(state.copyWith(
        isLoadingRooms: false,
        currentRoomId: roomId,
      ));
    } catch (e) {
      log('Error creating chat room: $e');
      emit(state.copyWith(
        isLoadingRooms: false,
        status: ChatStatus.failure,
        errorMessage: 'Failed to create chat room',
      ));
    }
  }

  // Messages
  Future<void> _onLoadChatMessages(
      LoadChatMessages event,
      Emitter<ChatState> emit,
      ) async {
    try {
      emit(state.copyWith(
        isLoadingMessages: true,
        currentRoomId: event.roomId,
      ));

      await _messagesSubscription?.cancel();
      _messagesSubscription = _firebaseDbHelper
          .getChatMessages(event.roomId)
          .listen((messages) => add(ChatMessagesUpdated(messages)));
    } catch (e) {
      log('Error loading messages: $e');
      emit(state.copyWith(
        isLoadingMessages: false,
        status: ChatStatus.failure,
        errorMessage: 'Failed to load messages',
      ));
    }
  }

  void _onChatMessagesUpdated(
      ChatMessagesUpdated event,
      Emitter<ChatState> emit,
      ) {
    emit(state.copyWith(
      messages: event.messages,
      isLoadingMessages: false,
      status: ChatStatus.success,
    ));
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
      emit(state.copyWith(
        messages: [...state.messages, tempMessage],
      ));

      // Send to Firebase
      await _firebaseDbHelper.sendMessage(event.message);

      emit(state.copyWith(isSendingMessage: false));
    } catch (e) {
      log('Error sending message: $e');
      emit(state.copyWith(
        isSendingMessage: false,
        status: ChatStatus.failure,
        errorMessage: 'Failed to send message',
      ));
    }
  }

  Future<void> _onUpdateMessageStatus(
      UpdateMessageStatus event,
      Emitter<ChatState> emit,
      ) async {
    try {
      await _firebaseDbHelper.updateMessageStatus(
        event.messageId,
        event.status,
      );

      final updatedMessages = state.messages.map((msg) {
        if (msg.id == event.messageId) {
          return msg.copyWith(status: event.status);
        }
        return msg;
      }).toList();

      emit(state.copyWith(messages: updatedMessages));
    } catch (e) {
      log('Error updating message status: $e');
    }
  }

  Future<void> _onDeleteMessage(
      DeleteMessage event,
      Emitter<ChatState> emit,
      ) async {
    try {
      await _firebaseDbHelper.deleteMessage(event.messageId, event.roomId);

      final updatedMessages = state.messages
          .where((msg) => msg.id != event.messageId)
          .toList();

      emit(state.copyWith(messages: updatedMessages));
    } catch (e) {
      log('Error deleting message: $e');
      emit(state.copyWith(
        status: ChatStatus.failure,
        errorMessage: 'Failed to delete message',
      ));
    }
  }

  // Read Status
  Future<void> _onMarkMessagesAsRead(
      MarkMessagesAsRead event,
      Emitter<ChatState> emit,
      ) async {
    try {
      await _firebaseDbHelper.markMessagesAsRead(event.roomId, event.userId);

      final updatedMessages = state.messages.map((msg) {
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

  // Contacts
  Future<void> _onLoadUserContacts(
      LoadUserContacts event,
      Emitter<ChatState> emit,
      ) async {
    try {
      emit(state.copyWith(isLoadingContacts: true));

      await _contactsSubscription?.cancel();
      _contactsSubscription = _firebaseDbHelper
          .getUserContacts(event.userId)
          .listen((contacts) => add(UserContactsLoaded(contacts)));
    } catch (e) {
      log('Error loading contacts: $e');
      emit(state.copyWith(
        isLoadingContacts: false,
        status: ChatStatus.failure,
        errorMessage: 'Failed to load contacts',
      ));
    }
  }

  void _onUserContactsLoaded(
      UserContactsLoaded event,
      Emitter<ChatState> emit,
      ) {
    emit(state.copyWith(
      contacts: event.contacts,
      filteredContacts: event.contacts,
      isLoadingContacts: false,
      status: ChatStatus.success,
    ));
  }

  void _onSearchContacts(
      SearchContacts event,
      Emitter<ChatState> emit,
      ) {
    if (event.query.isEmpty) {
      emit(state.copyWith(
        filteredContacts: state.contacts,
        searchQuery: null,
      ));
      return;
    }

    final filtered = state.contacts.where((contact) {
      return contact.name.toLowerCase().contains(event.query.toLowerCase()) ||
          (contact.email?.toLowerCase().contains(event.query.toLowerCase()) ?? false) ||
          (contact.phone?.contains(event.query) ?? false);
    }).toList();

    emit(state.copyWith(
      filteredContacts: filtered,
      searchQuery: event.query,
    ));
  }


  Future<void> _onStartTyping(
      StartTyping event,
      Emitter<ChatState> emit,
      ) async {
    try {
      await _firebaseDbHelper.startTyping(event.roomId, event.userId);

      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 3), () {
        add(StopTyping(event.roomId, event.userId));
      });

      final updatedTypingUsers = {...state.typingUsers};
      updatedTypingUsers['${event.roomId}_${event.userId}'] = true;

      emit(state.copyWith(typingUsers: updatedTypingUsers));
    } catch (e) {
      log('Error starting typing: $e');
    }
  }

  Future<void> _onStopTyping(
      StopTyping event,
      Emitter<ChatState> emit,
      ) async {
    try {
      await _firebaseDbHelper.stopTyping(event.roomId, event.userId);

      _typingTimer?.cancel();

      final updatedTypingUsers = {...state.typingUsers};
      updatedTypingUsers.remove('${event.roomId}_${event.userId}');

      emit(state.copyWith(typingUsers: updatedTypingUsers));
    } catch (e) {
      log('Error stopping typing: $e');
    }
  }

  // Online Status
  Future<void> _onUpdateOnlineStatus(
      UpdateOnlineStatus event,
      Emitter<ChatState> emit,
      ) async {
    try {
      await _firebaseDbHelper.updateOnlineStatus(event.userId, event.isOnline);

      final updatedOnlineUsers = {...state.onlineUsers};
      updatedOnlineUsers[event.userId] = event.isOnline;

      emit(state.copyWith(onlineUsers: updatedOnlineUsers));
    } catch (e) {
      log('Error updating online status: $e');
    }
  }

  // Error Handling
  void _onClearError(
      ClearError event,
      Emitter<ChatState> emit,
      ) {
    emit(state.copyWith(errorMessage: null));
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    _roomsSubscription?.cancel();
    _contactsSubscription?.cancel();
    _typingTimer?.cancel();
    return super.close();
  }
}