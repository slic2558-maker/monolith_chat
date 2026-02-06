import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:image_picker/image_picker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/contact.dart';
import '../../data/repositories/chat_repository.dart';
import '../../core/services/notification_service.dart';
import '../../core/utils/validators.dart';
import '../providers/auth_provider.dart';

part 'chat_provider.g.dart';

@Riverpod(keepAlive: true)
class Chat extends _$Chat {
  late ChatRepository _repository;
  final Record _audioRecorder = Record();
  final ImagePicker _imagePicker = ImagePicker();
  Timer? _simulationTimer;
  String? _recordingPath;
  
  @override
  Future<Map<String, List<Message>>> build() async {
    _repository = ref.watch(chatRepositoryProvider);
    await _repository.init();
    
    // Load initial chats
    final contacts = await _repository.getContacts();
    final chats = <String, List<Message>>{};
    
    for (final contact in contacts) {
      final messages = await _repository.getMessages(contact.id, limit: 20);
      chats[contact.id] = messages;
    }
    
    return chats;
  }
  
  // Get messages for specific chat
  Future<List<Message>> getChatMessages(String chatId) async {
    await _ensureInitialized();
    return _repository.getMessages(chatId);
  }
  
  // Send text message
  Future<void> sendTextMessage({
    required String chatId,
    required String text,
    String? replyToMessageId,
  }) async {
    if (!Validators.isValidMessage(text)) return;
    
    await _ensureInitialized();
    
    final auth = ref.read(authProvider);
    final currentUIN = auth.value?.uin ?? AppConstants.defaultUserUIN;
    final currentName = auth.value?.name ?? AppConstants.defaultUserName;
    
    final message = Message.textMessage(
      chatId: chatId,
      senderUIN: currentUIN,
      senderName: currentName,
      text: text,
      timestamp: DateTime.now(),
      isSent: true,
      status: MessageStatus.sending,
      replyToMessageId: replyToMessageId,
    );
    
    // Add to local state
    _addMessageToState(chatId, message);
    
    // Save to repository
    await _repository.saveMessage(message);
    
    // Simulate sending process
    _simulateMessageSending(message);
    
    // Send notification to contact (simulated)
    _sendNotification(chatId, message);
    
    // Auto-reply for demo
    _scheduleAutoReply(chatId, text);
  }
  
  // Send image message
  Future<void> sendImageMessage({
    required String chatId,
    required String filePath,
    String? caption,
  }) async {
    await _ensureInitialized();
    
    final auth = ref.read(authProvider);
    final currentUIN = auth.value?.uin ?? AppConstants.defaultUserUIN;
    final currentName = auth.value?.name ?? AppConstants.defaultUserName;
    
    final message = Message.imageMessage(
      chatId: chatId,
      senderUIN: currentUIN,
      senderName: currentName,
      filePath: filePath,
      caption: caption,
      timestamp: DateTime.now(),
      isSent: true,
      status: MessageStatus.sending,
    );
    
    _addMessageToState(chatId, message);
    await _repository.saveMessage(message);
    _simulateMessageSending(message);
  }
  
  // Start voice recording
  Future<void> startVoiceRecording(String chatId) async {
    if (await _audioRecorder.hasPermission()) {
      final path = '/storage/emulated/0/MonolithChat/Voice/${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _audioRecorder.start(
        path: path,
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        samplingRate: 44100,
      );
      _recordingPath = path;
    }
  }
  
  // Stop and send voice recording
  Future<void> stopAndSendVoiceRecording(String chatId) async {
    final path = _recordingPath;
    if (path == null) return;
    
    final duration = await _audioRecorder.stop();
    _recordingPath = null;
    
    if (duration != null && duration > 0) {
      await sendVoiceMessage(
        chatId: chatId,
        filePath: path,
        duration: duration,
      );
    }
  }
  
  // Send voice message
  Future<void> sendVoiceMessage({
    required String chatId,
    required String filePath,
    required int duration,
  }) async {
    await _ensureInitialized();
    
    final auth = ref.read(authProvider);
    final currentUIN = auth.value?.uin ?? AppConstants.defaultUserUIN;
    final currentName = auth.value?.name ?? AppConstants.defaultUserName;
    
    final message = Message.voiceMessage(
      chatId: chatId,
      senderUIN: currentUIN,
      senderName: currentName,
      filePath: filePath,
      duration: duration,
      timestamp: DateTime.now(),
      isSent: true,
      status: MessageStatus.sending,
    );
    
    _addMessageToState(chatId, message);
    await _repository.saveMessage(message);
    _simulateMessageSending(message);
  }
  
  // Pick and send image from gallery
  Future<void> pickAndSendImage(String chatId) async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await sendImageMessage(chatId: chatId, filePath: image.path);
    }
  }
  
  // Pick and send multiple images
  Future<void> pickAndSendMultipleImages(String chatId) async {
    final images = await _imagePicker.pickMultiImage();
    for (final image in images) {
      await sendImageMessage(chatId: chatId, filePath: image.path);
    }
  }
  
  // Pick and send file
  Future<void> pickAndSendFile(String chatId) async {
    // Note: image_picker doesn't support generic files
    // You might need file_picker package
    // For now, we'll use image as placeholder
    await pickAndSendImage(chatId);
  }
  
  // Edit message
  Future<void> editMessage({
    required String messageId,
    required String newText,
  }) async {
    if (!Validators.isValidMessage(newText)) return;
    
    await _ensureInitialized();
    
    final message = await _repository.getMessage(messageId);
    if (message != null && message.canEdit) {
      final updatedMessage = message.copyWith(
        text: newText,
        isEdited: true,
        editedAt: DateTime.now(),
      );
      
      await _repository.updateMessage(updatedMessage);
      _updateMessageInState(updatedMessage);
    }
  }
  
  // Delete message
  Future<void> deleteMessage({
    required String messageId,
    bool forEveryone = false,
  }) async {
    await _ensureInitialized();
    
    await _repository.deleteMessage(messageId, forEveryone: forEveryone);
    
    // Update state
    final chats = Map<String, List<Message>>.from(state.value ?? {});
    for (final chatId in chats.keys) {
      final index = chats[chatId]!.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        if (forEveryone) {
          chats[chatId]!.removeAt(index);
        } else {
          final message = chats[chatId]![index];
          chats[chatId]![index] = message.copyWith(isDeleted: true);
        }
        break;
      }
    }
    
    state = AsyncData(chats);
  }
  
  // Reply to message
  Future<void> replyToMessage({
    required String chatId,
    required String messageId,
    required String text,
  }) async {
    final message = await _repository.getMessage(messageId);
    if (message != null) {
      await sendTextMessage(
        chatId: chatId,
        text: text,
        replyToMessageId: messageId,
        quotedText: message.text,
        quotedSenderName: message.senderName,
      );
    }
  }
  
  // Forward message
  Future<void> forwardMessage({
    required String messageId,
    required List<String> toChatIds,
  }) async {
    await _ensureInitialized();
    
    final originalMessage = await _repository.getMessage(messageId);
    if (originalMessage == null || !originalMessage.canForward) return;
    
    for (final chatId in toChatIds) {
      final forwardedMessage = originalMessage.copyWith(
        id: 'fwd_${originalMessage.id}_${DateTime.now().millisecondsSinceEpoch}',
        chatId: chatId,
        timestamp: DateTime.now(),
        status: MessageStatus.sending,
        isSent: true,
      );
      
      _addMessageToState(chatId, forwardedMessage);
      await _repository.saveMessage(forwardedMessage);
      _simulateMessageSending(forwardedMessage);
    }
  }
  
  // Add reaction
  Future<void> addReaction({
    required String messageId,
    required String emoji,
  }) async {
    await _ensureInitialized();
    
    final auth = ref.read(authProvider);
    final currentUIN = auth.value?.uin ?? AppConstants.defaultUserUIN;
    
    await _repository.addReaction(messageId, currentUIN, emoji);
    
    // Update state
    final message = await _repository.getMessage(messageId);
    if (message != null) {
      _updateMessageInState(message);
    }
  }
  
  // Remove reaction
  Future<void> removeReaction({
    required String messageId,
  }) async {
    await _ensureInitialized();
    
    final auth = ref.read(authProvider);
    final currentUIN = auth.value?.uin ?? AppConstants.defaultUserUIN;
    
    await _repository.removeReaction(messageId, currentUIN);
    
    // Update state
    final message = await _repository.getMessage(messageId);
    if (message != null) {
      _updateMessageInState(message);
    }
  }
  
  // Pin message
  Future<void> pinMessage({
    required String messageId,
  }) async {
    await _ensureInitialized();
    
    final auth = ref.read(authProvider);
    final currentUIN = auth.value?.uin ?? AppConstants.defaultUserUIN;
    
    await _repository.pinMessage(messageId, currentUIN);
    
    // Update state
    final message = await _repository.getMessage(messageId);
    if (message != null) {
      _updateMessageInState(message);
    }
  }
  
  // Unpin message
  Future<void> unpinMessage({
    required String messageId,
  }) async {
    await _ensureInitialized();
    
    await _repository.unpinMessage(messageId);
    
    // Update state
    final message = await _repository.getMessage(messageId);
    if (message != null) {
      _updateMessageInState(message);
    }
  }
  
  // Get pinned messages
  Future<List<Message>> getPinnedMessages(String chatId) async {
    await _ensureInitialized();
    return _repository.getPinnedMessages(chatId);
  }
  
  // Search in chat
  Future<List<Message>> searchInChat({
    required String chatId,
    required String query,
  }) async {
    await _ensureInitialized();
    return _repository.searchMessages(chatId, query);
  }
  
  // Mark as read
  Future<void> markAsRead({
    required String messageId,
  }) async {
    await _ensureInitialized();
    
    final auth = ref.read(authProvider);
    final currentUIN = auth.value?.uin ?? AppConstants.defaultUserUIN;
    
    await _repository.markAsRead(messageId, currentUIN);
    
    // Update state
    final message = await _repository.getMessage(messageId);
    if (message != null) {
      _updateMessageInState(message);
    }
  }
  
  // Mark all as read in chat
  Future<void> markAllAsRead(String chatId) async {
    await _ensureInitialized();
    
    final messages = await _repository.getMessages(chatId);
    final auth = ref.read(authProvider);
    final currentUIN = auth.value?.uin ?? AppConstants.defaultUserUIN;
    
    for (final message in messages) {
      if (message.isSent && !message.readBy.contains(currentUIN)) {
        await _repository.markAsRead(message.id, currentUIN);
      }
    }
    
    // Refresh state
    final updatedMessages = await _repository.getMessages(chatId);
    final chats = Map<String, List<Message>>.from(state.value ?? {});
    chats[chatId] = updatedMessages;
    state = AsyncData(chats);
  }
  
  // Clear chat
  Future<void> clearChat(String chatId) async {
    await _ensureInitialized();
    await _repository.clearChat(chatId);
    
    // Update state
    final chats = Map<String, List<Message>>.from(state.value ?? {});
    chats[chatId] = [];
    state = AsyncData(chats);
  }
  
  // Get unread count
  Future<int> getUnreadCount(String chatId) async {
    await _ensureInitialized();
    
    final auth = ref.read(authProvider);
    final currentUIN = auth.value?.uin ?? AppConstants.defaultUserUIN;
    
    return _repository.getUnreadCount(chatId, currentUIN);
  }
  
  // Get all unread counts
  Future<Map<String, int>> getAllUnreadCounts() async {
    await _ensureInitialized();
    
    final auth = ref.read(authProvider);
    final currentUIN = auth.value?.uin ?? AppConstants.defaultUserUIN;
    
    return _repository.getUnreadCounts(currentUIN);
  }
  
  // Load more messages (pagination)
  Future<void> loadMoreMessages(String chatId) async {
    await _ensureInitialized();
    
    final currentMessages = state.value?[chatId] ?? [];
    final newMessages = await _repository.getMessages(
      chatId,
      limit: AppConstants.messagesPerPage,
      offset: currentMessages.length,
    );
    
    if (newMessages.isNotEmpty) {
      final chats = Map<String, List<Message>>.from(state.value ?? {});
      chats[chatId] = [...currentMessages, ...newMessages];
      state = AsyncData(chats);
    }
  }
  
  // Helper methods
  Future<void> _ensureInitialized() async {
    if (state.value == null) {
      await future;
    }
  }
  
  void _addMessageToState(String chatId, Message message) {
    final chats = Map<String, List<Message>>.from(state.value ?? {});
    
    if (!chats.containsKey(chatId)) {
      chats[chatId] = [];
    }
    
    chats[chatId]!.insert(0, message); // Newest first
    state = AsyncData(chats);
  }
  
  void _updateMessageInState(Message updatedMessage) {
    final chats = Map<String, List<Message>>.from(state.value ?? {});
    
    for (final chatId in chats.keys) {
      final index = chats[chatId]!.indexWhere((m) => m.id == updatedMessage.id);
      if (index != -1) {
        chats[chatId]![index] = updatedMessage;
        break;
      }
    }
    
    state = AsyncData(chats);
  }
  
  void _simulateMessageSending(Message message) {
    // Check connectivity
    Connectivity().checkConnectivity().then((result) {
      if (result == ConnectivityResult.none) {
        // No internet - mark as pending
        _updateMessageStatus(message.id, message.chatId, MessageStatus.pending);
        return;
      }
      
      // Simulate sending process
      Future.delayed(const Duration(seconds: 1), () {
        _updateMessageStatus(message.id, message.chatId, MessageStatus.sent);
      });
      
      Future.delayed(const Duration(seconds: 2), () {
        _updateMessageStatus(message.id, message.chatId, MessageStatus.delivered);
      });
      
      Future.delayed(const Duration(seconds: 3), () {
        _updateMessageStatus(message.id, message.chatId, MessageStatus.read);
      });
    });
  }
  
  void _updateMessageStatus(String messageId, String chatId, MessageStatus status) {
    final chats = state.value;
    if (chats == null) return;
    
    for (final chat in chats.keys) {
      if (chat == chatId) {
        final index = chats[chat]!.indexWhere((m) => m.id == messageId);
        if (index != -1) {
          final message = chats[chat]![index];
          final updatedMessage = message.copyWith(status: status);
          
          final updatedChats = Map<String, List<Message>>.from(chats);
          updatedChats[chat]![index] = updatedMessage;
          
          state = AsyncData(updatedChats);
          
          // Update in repository
          _repository.updateMessage(updatedMessage);
          
          break;
        }
      }
    }
  }
  
  void _sendNotification(String chatId, Message message) {
    final notificationService = NotificationService();
    
    // Get contact name for notification
    final contactProvider = ref.read(contactProvider.notifier);
    final contact = contactProvider.getContactSync(chatId);
    
    notificationService.showMessageNotification(
      title: contact?.displayName ?? 'Новое сообщение',
      body: message.text,
      chatId: chatId,
      messageId: message.id,
      isGroup: contact?.isGroup ?? false,
    );
  }
  
  void _scheduleAutoReply(String chatId, String originalText) {
    // Only auto-reply to messages not sent by me
    final contactProvider = ref.read(contactProvider.notifier);
    final contact = contactProvider.getContactSync(chatId);
    
    if (contact != null && !contact.isGroup) {
      Future.delayed(const Duration(seconds: 2), () {
        _receiveAutoReply(chatId, originalText);
      });
    }
  }
  
  void _receiveAutoReply(String chatId, String originalMessage) {
    final replies = [
      'Привет! Я получил твоё сообщение: "$originalMessage"',
      'Спасибо за сообщение! Я на связи.',
      'Интересно! Я думаю об этом...',
      'Хорошо! Давай обсудим это подробнее.',
      'Понял твоё сообщение. Что дальше?',
    ];
    
    final randomIndex = DateTime.now().millisecond % replies.length;
    final replyText = replies[randomIndex];
    
    final auth = ref.read(authProvider);
    final contactProvider = ref.read(contactProvider.notifier);
    final contact = contactProvider.getContactSync(chatId);
    
    if (contact != null) {
      final message = Message.textMessage(
        chatId: chatId,
        senderUIN: contact.uin,
        senderName: contact.displayName,
        text: replyText,
        timestamp: DateTime.now(),
        isSent: false,
        status: MessageStatus.read,
      );
      
      _addMessageToState(chatId, message);
      _repository.saveMessage(message);
    }
  }
  
  @override
  void dispose() {
    _simulationTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }
}

// Provider for active chat
@Riverpod(keepAlive: true)
class ActiveChat extends _$ActiveChat {
  @override
  String? build() {
    return null;
  }
  
  void setActive(String chatId) {
    state = chatId;
  }
  
  void clear() {
    state = null;
  }
}

// Provider for typing indicator
@Riverpod(keepAlive: true)
class TypingStatus extends _$TypingStatus {
  final Map<String, Timer> _typingTimers = {};
  
  @override
  Map<String, bool> build() {
    return {};
  }
  
  void startTyping(String chatId) {
    // Cancel existing timer
    _typingTimers[chatId]?.cancel();
    
    // Set typing to true
    state = {...state, chatId: true};
    
    // Set timer to stop typing after 3 seconds
    _typingTimers[chatId] = Timer(const Duration(seconds: 3), () {
      stopTyping(chatId);
    });
  }
  
  void stopTyping(String chatId) {
    _typingTimers[chatId]?.cancel();
    _typingTimers.remove(chatId);
    
    state = {...state, chatId: false};
  }
  
  bool isTyping(String chatId) {
    return state[chatId] ?? false;
  }
  
  @override
  void dispose() {
    for (final timer in _typingTimers.values) {
      timer.cancel();
    }
    _typingTimers.clear();
    super.dispose();
  }
}