import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/message.dart';
import '../models/contact.dart';
import '../services/notification_service.dart';
import '../core/utils/validators.dart';

class ChatProvider with ChangeNotifier {
  final Map<String, List<Message>> _chats = {};
  late Box<Message> _messagesBox;
  Timer? _simulationTimer;
  
  // Храним последнее сообщение для каждого чата для быстрого доступа
  final Map<String, Message?> _lastMessages = {};
  
  // Храним непрочитанные сообщения
  final Map<String, int> _unreadCounts = {};
  
  ChatProvider() {
    _initStorage();
  }
  
  Future<void> _initStorage() async {
    _messagesBox = await Hive.openBox<Message>('messages');
    await _loadMessagesFromStorage();
  }
  
  Future<void> _loadMessagesFromStorage() async {
    final allMessages = _messagesBox.values.toList();
    
    for (final message in allMessages) {
      if (!message.isDeleted) {
        _chats.putIfAbsent(message.chatId, () => []);
        _chats[message.chatId]!.add(message);
      }
    }
    
    // Сортировка сообщений в каждом чате
    for (final chatId in _chats.keys) {
      _chats[chatId]!.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      _updateLastMessage(chatId);
      _updateUnreadCount(chatId);
    }
    
    notifyListeners();
  }
  
  List<Message> getMessages(String chatId) {
    return _chats[chatId] ?? [];
  }
  
  Message? getLastMessage(String chatId) {
    return _lastMessages[chatId];
  }
  
  int getUnreadCount(String chatId) {
    return _unreadCounts[chatId] ?? 0;
  }
  
  Map<String, int> getAllUnreadCounts() {
    return Map.from(_unreadCounts);
  }
  
  void _updateLastMessage(String chatId) {
    final messages = _chats[chatId];
    if (messages != null && messages.isNotEmpty) {
      _lastMessages[chatId] = messages.last;
    } else {
      _lastMessages.remove(chatId);
    }
  }
  
  void _updateUnreadCount(String chatId) {
    final messages = _chats[chatId];
    if (messages == null) {
      _unreadCounts.remove(chatId);
      return;
    }
    
    // Подсчитываем непрочитанные сообщения (не от нас и не прочитанные)
    final unreadCount = messages.where((msg) {
      return !msg.isSent && !msg.readBy.contains('current_user_uin');
    }).length;
    
    _unreadCounts[chatId] = unreadCount;
  }
  
  // Отправить текстовое сообщение
  Future<void> sendTextMessage(String chatId, String text, {
    String? replyToMessageId,
    String? quotedText,
    String? quotedSenderName,
  }) async {
    if (!Validators.isValidMessage(text)) return;
    
    _chats.putIfAbsent(chatId, () => []);
    
    final message = Message.textMessage(
      chatId: chatId,
      senderUIN: 'current_user_uin', // Должен браться из AuthProvider
      text: text,
      timestamp: DateTime.now(),
      isSent: true,
      status: MessageStatus.sending,
      replyToMessageId: replyToMessageId,
      quotedText: quotedText,
      quotedSenderName: quotedSenderName,
    );
    
    _chats[chatId]!.add(message);
    await _saveMessage(message);
    
    notifyListeners();
    _scrollToBottom();
    
    _simulateMessageSending(message);
    
    // Автоответ для демонстрации
    _scheduleAutoReply(chatId, text);
  }
  
  // Отправить изображение
  Future<void> sendImageMessage(String chatId, String filePath, {
    String? caption,
    String? fileUrl,
    int? fileSize,
    String? thumbnailUrl,
  }) async {
    _chats.putIfAbsent(chatId, () => []);
    
    final message = Message.imageMessage(
      chatId: chatId,
      senderUIN: 'current_user_uin',
      filePath: filePath,
      fileUrl: fileUrl,
      caption: caption,
      fileSize: fileSize,
      thumbnailUrl: thumbnailUrl,
      timestamp: DateTime.now(),
      isSent: true,
      status: MessageStatus.sending,
    );
    
    _chats[chatId]!.add(message);
    await _saveMessage(message);
    
    notifyListeners();
    _scrollToBottom();
    _simulateMessageSending(message);
    
    // Автоответ на фото
    _scheduleAutoReply(chatId, '📷 Фото');
  }
  
  // Отправить голосовое сообщение
  Future<void> sendVoiceMessage(String chatId, String filePath, int duration) async {
    _chats.putIfAbsent(chatId, () => []);
    
    final message = Message.voiceMessage(
      chatId: chatId,
      senderUIN: 'current_user_uin',
      filePath: filePath,
      duration: duration,
      timestamp: DateTime.now(),
      isSent: true,
      status: MessageStatus.sending,
    );
    
    _chats[chatId]!.add(message);
    await _saveMessage(message);
    
    notifyListeners();
    _scrollToBottom();
    _simulateMessageSending(message);
    
    // Автоответ на голосовое
    _scheduleAutoReply(chatId, '🎤 Голосовое сообщение');
  }
  
  // Редактировать сообщение
  Future<void> editMessage(String messageId, String newText) async {
    for (final chatId in _chats.keys) {
      final index = _chats[chatId]!.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        final oldMessage = _chats[chatId]![index];
        final newMessage = oldMessage.copyWith(
          text: newText,
          isEdited: true,
          editedAt: DateTime.now(),
        );
        
        _chats[chatId]![index] = newMessage;
        await _saveMessage(newMessage);
        
        notifyListeners();
        break;
      }
    }
  }
  
  // Удалить сообщение
  Future<void> deleteMessage(String messageId, {bool forEveryone = false}) async {
    for (final chatId in _chats.keys) {
      final index = _chats[chatId]!.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        final message = _chats[chatId]![index];
        
        if (forEveryone) {
          // Удаление для всех
          _chats[chatId]!.removeAt(index);
          await _messagesBox.delete(messageId);
        } else {
          // Удаление только для себя
          final deletedMessage = message.copyWith(
            isDeleted: true,
            deletedAt: DateTime.now(),
          );
          _chats[chatId]![index] = deletedMessage;
          await _saveMessage(deletedMessage);
        }
        
        notifyListeners();
        _updateLastMessage(chatId);
        break;
      }
    }
  }
  
  // Ответить на сообщение
  Future<void> replyToMessage({
    required String chatId,
    required String messageId,
    required String text,
  }) async {
    final originalMessage = _getMessageById(messageId);
    if (originalMessage == null) return;
    
    await sendTextMessage(
      chatId,
      text,
      replyToMessageId: messageId,
      quotedText: originalMessage.text,
      quotedSenderName: originalMessage.senderName,
    );
  }
  
  // Переслать сообщение
  Future<void> forwardMessage({
    required String messageId,
    required List<String> toChatIds,
  }) async {
    final originalMessage = _getMessageById(messageId);
    if (originalMessage == null) return;
    
    for (final chatId in toChatIds) {
      final forwardedMessage = originalMessage.copyWith(
        id: 'fwd_${originalMessage.id}_${DateTime.now().millisecondsSinceEpoch}',
        chatId: chatId,
        timestamp: DateTime.now(),
        status: MessageStatus.sending,
        isSent: true,
        replyToMessageId: null,
        quotedText: null,
        quotedSenderName: null,
      );
      
      _chats.putIfAbsent(chatId, () => []);
      _chats[chatId]!.add(forwardedMessage);
      await _saveMessage(forwardedMessage);
      
      _simulateMessageSending(forwardedMessage);
    }
    
    notifyListeners();
  }
  
  // Добавить реакцию
  Future<void> addReaction({
    required String messageId,
    required String emoji,
  }) async {
    final message = _getMessageById(messageId);
    if (message == null) return;
    
    final updatedMessage = message.copyWith(
      reactions: {...message.reactions, 'current_user_uin': emoji},
    );
    
    await _updateMessageInChat(updatedMessage);
  }
  
  // Удалить реакцию
  Future<void> removeReaction({
    required String messageId,
  }) async {
    final message = _getMessageById(messageId);
    if (message == null) return;
    
    final reactions = Map<String, String>.from(message.reactions);
    reactions.remove('current_user_uin');
    
    final updatedMessage = message.copyWith(reactions: reactions);
    await _updateMessageInChat(updatedMessage);
  }
  
  // Закрепить сообщение
  Future<void> pinMessage({
    required String messageId,
  }) async {
    final message = _getMessageById(messageId);
    if (message == null) return;
    
    final updatedMessage = message.copyWith(
      isPinned: true,
      pinnedAt: DateTime.now(),
      pinnedBy: 'current_user_uin',
    );
    
    await _updateMessageInChat(updatedMessage);
  }
  
  // Открепить сообщение
  Future<void> unpinMessage({
    required String messageId,
  }) async {
    final message = _getMessageById(messageId);
    if (message == null) return;
    
    final updatedMessage = message.copyWith(
      isPinned: false,
      pinnedAt: null,
      pinnedBy: null,
    );
    
    await _updateMessageInChat(updatedMessage);
  }
  
  // Получить закрепленные сообщения
  List<Message> getPinnedMessages(String chatId) {
    final messages = _chats[chatId];
    if (messages == null) return [];
    
    return messages
        .where((message) => message.isPinned && !message.isDeleted)
        .toList();
  }
  
  // Поиск в чате
  List<Message> searchInChat(String chatId, String query) {
    final messages = _chats[chatId];
    if (messages == null) return [];
    
    return messages
        .where((message) =>
            !message.isDeleted &&
            message.text.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
  
  // Пометить как прочитанное
  Future<void> markAsRead(String messageId) async {
    final message = _getMessageById(messageId);
    if (message == null || message.readBy.contains('current_user_uin')) return;
    
    final updatedMessage = message.copyWith(
      status: MessageStatus.read,
      readBy: [...message.readBy, 'current_user_uin'],
    );
    
    await _updateMessageInChat(updatedMessage);
    _updateUnreadCount(message.chatId);
  }
  
  // Пометить все как прочитанные в чате
  Future<void> markAllAsRead(String chatId) async {
    final messages = _chats[chatId];
    if (messages == null) return;
    
    for (final message in messages) {
      if (!message.isSent && !message.readBy.contains('current_user_uin')) {
        final updatedMessage = message.copyWith(
          status: MessageStatus.read,
          readBy: [...message.readBy, 'current_user_uin'],
        );
        await _saveMessage(updatedMessage);
      }
    }
    
    // Обновить в памяти
    final updatedMessages = await _messagesBox.values
        .where((m) => m.chatId == chatId)
        .toList();
    _chats[chatId] = updatedMessages;
    
    _updateUnreadCount(chatId);
    notifyListeners();
  }
  
  // Получить сообщение по ID
  Message? _getMessageById(String messageId) {
    for (final chatMessages in _chats.values) {
      final message = chatMessages.firstWhere(
        (m) => m.id == messageId,
        orElse: () => Message.textMessage(
          chatId: '',
          senderUIN: '',
          text: '',
          timestamp: DateTime.now(),
          isSent: false,
        ),
      );
      if (message.id.isNotEmpty) return message;
    }
    return null;
  }
  
  // Обновить сообщение в чате
  Future<void> _updateMessageInChat(Message updatedMessage) async {
    final chatId = updatedMessage.chatId;
    final messages = _chats[chatId];
    if (messages == null) return;
    
    final index = messages.indexWhere((m) => m.id == updatedMessage.id);
    if (index != -1) {
      messages[index] = updatedMessage;
      await _saveMessage(updatedMessage);
      notifyListeners();
      _updateLastMessage(chatId);
    }
  }
  
  // Сохранить сообщение в хранилище
  Future<void> _saveMessage(Message message) async {
    await _messagesBox.put(message.id, message);
  }
  
  // Симуляция отправки
  void _simulateMessageSending(Message message) {
    Future.delayed(const Duration(seconds: 1), () {
      _updateMessageStatus(message.id, MessageStatus.sent);
    });
    
    Future.delayed(const Duration(seconds: 2), () {
      _updateMessageStatus(message.id, MessageStatus.delivered);
    });
    
    Future.delayed(const Duration(seconds: 3), () {
      _updateMessageStatus(message.id, MessageStatus.read);
    });
  }
  
  void _updateMessageStatus(String messageId, MessageStatus status) {
    final message = _getMessageById(messageId);
    if (message == null) return;
    
    final updatedMessage = message.copyWith(status: status);
    _updateMessageInChat(updatedMessage);
  }
  
  // Автоответ
  void _scheduleAutoReply(String chatId, String originalMessage) {
    Timer(const Duration(seconds: 2), () {
      _receiveAutoReply(chatId, originalMessage);
    });
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
    
    final message = Message.textMessage(
      chatId: chatId,
      senderUIN: chatId, // Отправляем от имени собеседника
      text: replyText,
      timestamp: DateTime.now(),
      isSent: false,
      status: MessageStatus.read,
    );
    
    _chats.putIfAbsent(chatId, () => []);
    _chats[chatId]!.add(message);
    _saveMessage(message);
    
    // Отправить уведомление
    NotificationService().showMessageNotification(
      title: 'Новое сообщение',
      body: replyText,
      chatId: chatId,
      messageId: message.id,
    );
    
    notifyListeners();
    _updateLastMessage(chatId);
    _updateUnreadCount(chatId);
  }
  
  // Загрузить историю (для демо)
  void loadMessages(String chatId) {
    if (!_chats.containsKey(chatId) || _chats[chatId]!.isEmpty) {
      final messages = [
        Message.textMessage(
          chatId: chatId,
          senderUIN: chatId,
          text: 'Привет! Как дела?',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          isSent: false,
          status: MessageStatus.read,
        ),
        Message.textMessage(
          chatId: chatId,
          senderUIN: 'current_user_uin',
          text: 'Привет! Всё отлично, спасибо!',
          timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
          isSent: true,
          status: MessageStatus.read,
        ),
        Message.imageMessage(
          chatId: chatId,
          senderUIN: chatId,
          filePath: 'placeholder.jpg',
          caption: 'Вот фото из отпуска!',
          timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
          isSent: false,
          status: MessageStatus.read,
        ),
        Message.voiceMessage(
          chatId: chatId,
          senderUIN: 'current_user_uin',
          filePath: 'voice_placeholder.mp3',
          duration: 30,
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
          isSent: true,
          status: MessageStatus.read,
        ),
      ];
      
      _chats[chatId] = messages;
      _updateLastMessage(chatId);
      _updateUnreadCount(chatId);
      notifyListeners();
    }
  }
  
  // Удалить чат
  Future<void> deleteChat(String chatId) async {
    // Пометить все сообщения как удаленные
    final messages = _chats[chatId];
    if (messages != null) {
      for (final message in messages) {
        final deletedMessage = message.copyWith(
          isDeleted: true,
          deletedAt: DateTime.now(),
        );
        await _saveMessage(deletedMessage);
      }
    }
    
    _chats.remove(chatId);
    _lastMessages.remove(chatId);
    _unreadCounts.remove(chatId);
    
    notifyListeners();
  }
  
  // Очистить чат
  Future<void> clearChat(String chatId) async {
    final messages = _chats[chatId];
    if (messages != null) {
      for (final message in messages) {
        await _messagesBox.delete(message.id);
      }
    }
    
    _chats.remove(chatId);
    _lastMessages.remove(chatId);
    _unreadCounts.remove(chatId);
    
    notifyListeners();
  }
  
  // Очистить ВСЕ чаты
  Future<void> clearAllChats() async {
    await _messagesBox.clear();
    _chats.clear();
    _lastMessages.clear();
    _unreadCounts.clear();
    notifyListeners();
  }
  
  void _scrollToBottom() {
    // Этот метод должен вызываться из UI
    // Здесь просто заглушка
  }
  
  @override
  void dispose() {
    _simulationTimer?.cancel();
    _messagesBox.close();
    super.dispose();
  }
}