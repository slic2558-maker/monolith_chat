import 'dart:async';
import 'package:flutter/material.dart';
import '../models/message.dart';

class ChatProvider with ChangeNotifier {
  final Map<String, List<Message>> _chats = {};
  
  // Геттер для доступа к приватному полю (для home_screen)
  Map<String, List<Message>> get chats => Map.from(_chats);
  
  List<Message> getMessages(String chatId) {
    return _chats[chatId] ?? [];
  }
  
  // Отправить текстовое сообщение
  void sendTextMessage(String chatId, String text) {
    if (text.trim().isEmpty) return;
    
    _chats.putIfAbsent(chatId, () => []);
    
    final message = Message.textMessage(
      chatId: chatId,
      senderUIN: '428971',
      text: text,
      timestamp: DateTime.now(),
      isSent: true,
      status: MessageStatus.sending,
    );
    
    _chats[chatId]!.add(message);
    notifyListeners();
    
    _simulateMessageSending(message, chatId);
    
    // Автоответ с задержкой
    Timer(const Duration(seconds: 2), () {
      _receiveAutoReply(chatId, text);
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
    
    final randomReply = replies[DateTime.now().millisecond % replies.length];
    
    receiveTextMessage(
      chatId,
      randomReply,
      senderUIN: chatId,
    );
  }
  
  // Отправить изображение
  void sendImageMessage(String chatId, String filePath, {String? caption}) {
    _chats.putIfAbsent(chatId, () => []);
    
    final message = Message.imageMessage(
      chatId: chatId,
      senderUIN: '428971',
      filePath: filePath,
      caption: caption,
      timestamp: DateTime.now(),
      isSent: true,
      status: MessageStatus.sending,
    );
    
    _chats[chatId]!.add(message);
    notifyListeners();
    
    _simulateMessageSending(message, chatId);
    
    // Автоответ на фото
    Timer(const Duration(seconds: 2), () {
      receiveTextMessage(
        chatId,
        'Классное фото! 📷',
        senderUIN: chatId,
      );
    });
  }
  
  // Отправить голосовое сообщение
  void sendVoiceMessage(String chatId, String filePath, int duration) {
    _chats.putIfAbsent(chatId, () => []);
    
    final message = Message.voiceMessage(
      chatId: chatId,
      senderUIN: '428971',
      filePath: filePath,
      duration: duration,
      timestamp: DateTime.now(),
      isSent: true,
      status: MessageStatus.sending,
    );
    
    _chats[chatId]!.add(message);
    notifyListeners();
    
    _simulateMessageSending(message, chatId);
    
    // Автоответ на голосовое
    Timer(const Duration(seconds: 2), () {
      receiveTextMessage(
        chatId,
        'Понял твоё голосовое сообщение! 🎤',
        senderUIN: chatId,
      );
    });
  }
  
  // Симуляция отправки
  void _simulateMessageSending(Message message, String chatId) {
    Timer(const Duration(seconds: 1), () {
      _updateMessageStatus(message.id, chatId, MessageStatus.sent);
    });
    
    Timer(const Duration(seconds: 2), () {
      _updateMessageStatus(message.id, chatId, MessageStatus.delivered);
    });
    
    Timer(const Duration(seconds: 3), () {
      _updateMessageStatus(message.id, chatId, MessageStatus.read);
    });
  }
  
  void _updateMessageStatus(String messageId, String chatId, MessageStatus newStatus) {
    final messages = _chats[chatId];
    if (messages == null) return;
    
    final index = messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      final oldMessage = messages[index];
      final updatedMessage = oldMessage.copyWith(status: newStatus);
      
      messages[index] = updatedMessage;
      notifyListeners();
    }
  }
  
  // Получить сообщение
  void receiveTextMessage(String chatId, String text, {required String senderUIN}) {
    _chats.putIfAbsent(chatId, () => []);
    
    final message = Message.textMessage(
      chatId: chatId,
      senderUIN: senderUIN,
      text: text,
      timestamp: DateTime.now(),
      isSent: false,
      status: MessageStatus.read,
    );
    
    _chats[chatId]!.add(message);
    notifyListeners();
  }
  
  // Загрузить историю
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
          senderUIN: '428971',
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
          senderUIN: '428971',
          filePath: 'voice_placeholder.mp3',
          duration: 30,
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
          isSent: true,
          status: MessageStatus.read,
        ),
      ];
      
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      _chats[chatId] = messages;
      notifyListeners();
    }
  }
  
  // Удалить чат полностью (удаляет из _chats)
  void deleteChat(String chatId) {
    _chats.remove(chatId);
    notifyListeners();
  }
  
  // Очистить историю чата (оставляет пустой чат)
  void clearChatHistory(String chatId) {
    if (_chats.containsKey(chatId)) {
      _chats[chatId]!.clear();
      notifyListeners();
    }
  }
  
  // Удалить сообщение
  void deleteMessage(String messageId) {
    for (final chatId in _chats.keys) {
      final initialLength = _chats[chatId]!.length;
      _chats[chatId]!.removeWhere((m) => m.id == messageId);
      
      if (_chats[chatId]!.length != initialLength) {
        notifyListeners();
        break;
      }
    }
  }
  
  // Очистить чат (синоним clearChatHistory)
  void clearChat(String chatId) {
    clearChatHistory(chatId);
  }
  
  // Очистить ВСЕ чаты
  void clearAllChats() {
    _chats.clear();
    notifyListeners();
  }
  
  // Остальные методы...
  Message? getLastMessage(String chatId) {
    final messages = _chats[chatId];
    if (messages == null || messages.isEmpty) return null;
    return messages.last;
  }
  
  void editMessage(String messageId, String newText) {
    for (final chatId in _chats.keys) {
      final index = _chats[chatId]!.indexWhere((m) => m.id == messageId);
      
      if (index != -1) {
        final oldMessage = _chats[chatId]![index];
        final newMessage = oldMessage.copyWith(text: newText, isEdited: true);
        
        _chats[chatId]![index] = newMessage;
        notifyListeners();
        break;
      }
    }
  }
}