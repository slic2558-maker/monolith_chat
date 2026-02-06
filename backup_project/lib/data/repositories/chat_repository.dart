import 'package:hive/hive.dart';
import 'package:riverpod/riverpod.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/contact.dart';
import '../../core/utils/encryption_service.dart';
import '../../core/constants/app_constants.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

class ChatRepository {
  late Box<Message> _messagesBox;
  late Box<Contact> _contactsBox;
  
  Future<void> init() async {
    _messagesBox = await Hive.openBox<Message>(AppConstants.messagesBox);
    _contactsBox = await Hive.openBox<Contact>(AppConstants.contactsBox);
  }
  
  // Messages
  Future<List<Message>> getMessages(String chatId, {int limit = 50, int offset = 0}) async {
    await init();
    final allMessages = _messagesBox.values
        .where((msg) => msg.chatId == chatId && !msg.isDeleted)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return allMessages.skip(offset).take(limit).toList();
  }
  
  Future<Message?> getMessage(String messageId) async {
    await init();
    return _messagesBox.values.firstWhere(
      (msg) => msg.id == messageId,
      orElse: () => Message.textMessage(
        chatId: '',
        senderUIN: '',
        text: '',
        timestamp: DateTime.now(),
        isSent: false,
      ),
    );
  }
  
  Future<void> saveMessage(Message message) async {
    await init();
    
    // Encrypt sensitive data before saving
    final encryptedMessage = await EncryptionService.encryptMessage(message.toJson());
    final decryptedMessage = await Message.fromJson(await EncryptionService.decryptMessage(encryptedMessage));
    
    await _messagesBox.put(message.id, decryptedMessage);
  }
  
  Future<void> saveMessages(List<Message> messages) async {
    await init();
    final batch = _messagesBox.batch();
    
    for (final message in messages) {
      final encryptedMessage = await EncryptionService.encryptMessage(message.toJson());
      final decryptedMessage = await Message.fromJson(await EncryptionService.decryptMessage(encryptedMessage));
      batch.put(message.id, decryptedMessage);
    }
    
    await batch.commit();
  }
  
  Future<void> updateMessage(Message message) async {
    await saveMessage(message);
  }
  
  Future<void> deleteMessage(String messageId, {bool forEveryone = false}) async {
    await init();
    final message = await getMessage(messageId);
    if (message != null) {
      final updatedMessage = message.copyWith(
        isDeleted: true,
        deletedAt: DateTime.now(),
        deleteForEveryone: forEveryone,
      );
      await saveMessage(updatedMessage);
    }
  }
  
  Future<void> deleteMessages(List<String> messageIds) async {
    await init();
    final batch = _messagesBox.batch();
    
    for (final id in messageIds) {
      final message = await getMessage(id);
      if (message != null) {
        final updatedMessage = message.copyWith(
          isDeleted: true,
          deletedAt: DateTime.now(),
        );
        batch.put(id, updatedMessage);
      }
    }
    
    await batch.commit();
  }
  
  Future<void> clearChat(String chatId) async {
    await init();
    final messages = await getMessages(chatId, limit: 10000);
    await deleteMessages(messages.map((m) => m.id).toList());
  }
  
  Future<void> markAsRead(String messageId, String readerUIN) async {
    await init();
    final message = await getMessage(messageId);
    if (message != null) {
      final updatedMessage = message.copyWith(
        status: MessageStatus.read,
        readBy: [...message.readBy, readerUIN],
      );
      await saveMessage(updatedMessage);
    }
  }
  
  Future<void> markAsDelivered(String messageId, String receiverUIN) async {
    await init();
    final message = await getMessage(messageId);
    if (message != null) {
      final updatedMessage = message.copyWith(
        status: MessageStatus.delivered,
        deliveredTo: [...message.deliveredTo, receiverUIN],
      );
      await saveMessage(updatedMessage);
    }
  }
  
  Future<void> addReaction(String messageId, String reactorUIN, String emoji) async {
    await init();
    final message = await getMessage(messageId);
    if (message != null) {
      final reactions = Map<String, String>.from(message.reactions);
      reactions[reactorUIN] = emoji;
      final updatedMessage = message.copyWith(reactions: reactions);
      await saveMessage(updatedMessage);
    }
  }
  
  Future<void> removeReaction(String messageId, String reactorUIN) async {
    await init();
    final message = await getMessage(messageId);
    if (message != null) {
      final reactions = Map<String, String>.from(message.reactions);
      reactions.remove(reactorUIN);
      final updatedMessage = message.copyWith(reactions: reactions);
      await saveMessage(updatedMessage);
    }
  }
  
  Future<void> pinMessage(String messageId, String pinnerUIN) async {
    await init();
    final message = await getMessage(messageId);
    if (message != null) {
      final updatedMessage = message.copyWith(
        isPinned: true,
        pinnedAt: DateTime.now(),
        pinnedBy: pinnerUIN,
      );
      await saveMessage(updatedMessage);
    }
  }
  
  Future<void> unpinMessage(String messageId) async {
    await init();
    final message = await getMessage(messageId);
    if (message != null) {
      final updatedMessage = message.copyWith(
        isPinned: false,
        pinnedAt: null,
        pinnedBy: null,
      );
      await saveMessage(updatedMessage);
    }
  }
  
  Future<List<Message>> getPinnedMessages(String chatId) async {
    await init();
    return _messagesBox.values
        .where((msg) => msg.chatId == chatId && msg.isPinned && !msg.isDeleted)
        .toList()
      ..sort((a, b) => (b.pinnedAt ?? b.timestamp).compareTo(a.pinnedAt ?? a.timestamp));
  }
  
  Future<List<Message>> searchMessages(String chatId, String query) async {
    await init();
    return _messagesBox.values
        .where((msg) =>
            msg.chatId == chatId &&
            !msg.isDeleted &&
            msg.text.toLowerCase().contains(query.toLowerCase()))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
  
  Future<Message?> getLastMessage(String chatId) async {
    await init();
    final messages = await getMessages(chatId, limit: 1);
    return messages.isNotEmpty ? messages.first : null;
  }
  
  Future<int> getUnreadCount(String chatId, String userUIN) async {
    await init();
    return _messagesBox.values
        .where((msg) =>
            msg.chatId == chatId &&
            !msg.isDeleted &&
            msg.isSent &&
            !msg.readBy.contains(userUIN))
        .length;
  }
  
  Future<Map<String, int>> getUnreadCounts(String userUIN) async {
    await init();
    final counts = <String, int>{};
    
    for (final message in _messagesBox.values) {
      if (!message.isDeleted && 
          message.isSent && 
          !message.readBy.contains(userUIN)) {
        counts[message.chatId] = (counts[message.chatId] ?? 0) + 1;
      }
    }
    
    return counts;
  }
  
  // Contacts
  Future<List<Contact>> getContacts() async {
    await init();
    return _contactsBox.values.toList()
      ..sort((a, b) => b.lastInteraction.compareTo(a.lastInteraction));
  }
  
  Future<Contact?> getContact(String uin) async {
    await init();
    return _contactsBox.values.firstWhere(
      (contact) => contact.uin == uin,
      orElse: () => Contact(uin: '', name: ''),
    );
  }
  
  Future<void> saveContact(Contact contact) async {
    await init();
    await _contactsBox.put(contact.id, contact);
  }
  
  Future<void> saveContacts(List<Contact> contacts) async {
    await init();
    final batch = _contactsBox.batch();
    
    for (final contact in contacts) {
      batch.put(contact.id, contact);
    }
    
    await batch.commit();
  }
  
  Future<void> updateContact(Contact contact) async {
    await saveContact(contact);
  }
  
  Future<void> deleteContact(String uin) async {
    await init();
    final contact = await getContact(uin);
    if (contact != null) {
      await _contactsBox.delete(contact.id);
    }
  }
  
  Future<void> toggleFavorite(String uin) async {
    await init();
    final contact = await getContact(uin);
    if (contact != null) {
      await saveContact(contact.copyWith(isFavorite: !contact.isFavorite));
    }
  }
  
  Future<void> toggleMute(String uin, {Duration? duration}) async {
    await init();
    final contact = await getContact(uin);
    if (contact != null) {
      if (contact.notificationsMuted) {
        await saveContact(contact.copyWith(
          notificationsMuted: false,
          muteUntil: null,
        ));
      } else {
        final muteUntil = duration != null
            ? DateTime.now().add(duration)
            : DateTime(2100, 1, 1);
        await saveContact(contact.copyWith(
          notificationsMuted: true,
          muteUntil: muteUntil,
        ));
      }
    }
  }
  
  Future<List<Contact>> searchContacts(String query) async {
    await init();
    return _contactsBox.values
        .where((contact) =>
            contact.displayName.toLowerCase().contains(query.toLowerCase()) ||
            contact.uin.contains(query))
        .toList()
      ..sort((a, b) => b.lastInteraction.compareTo(a.lastInteraction));
  }
  
  Future<List<Contact>> getFavorites() async {
    await init();
    return _contactsBox.values
        .where((contact) => contact.isFavorite)
        .toList()
      ..sort((a, b) => b.lastInteraction.compareTo(a.lastInteraction));
  }
  
  Future<List<Contact>> getGroups() async {
    await init();
    return _contactsBox.values
        .where((contact) => contact.isGroup)
        .toList()
      ..sort((a, b) => b.lastInteraction.compareTo(a.lastInteraction));
  }
  
  // Statistics
  Future<Map<String, dynamic>> getStatistics() async {
    await init();
    
    final totalMessages = _messagesBox.values.length;
    final totalContacts = _contactsBox.values.length;
    final totalGroups = _contactsBox.values.where((c) => c.isGroup).length;
    
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final messagesToday = _messagesBox.values
        .where((msg) => msg.timestamp.isAfter(startOfDay))
        .length;
    
    return {
      'totalMessages': totalMessages,
      'totalContacts': totalContacts,
      'totalGroups': totalGroups,
      'messagesToday': messagesToday,
      'storageUsed': await _calculateStorageSize(),
    };
  }
  
  Future<String> _calculateStorageSize() async {
    final messagesSize = await _messagesBox.compact();
    final contactsSize = await _contactsBox.compact();
    final totalBytes = messagesSize + contactsSize;
    
    if (totalBytes < 1024) return '${totalBytes}B';
    if (totalBytes < 1024 * 1024) return '${(totalBytes / 1024).toStringAsFixed(1)}KB';
    return '${(totalBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
  
  // Backup & Restore
  Future<String> exportData() async {
    await init();
    
    final data = {
      'contacts': _contactsBox.values.map((c) => c.toJson()).toList(),
      'messages': _messagesBox.values.map((m) => m.toJson()).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
      'version': AppConstants.appVersion,
    };
    
    return json.encode(data);
  }
  
  Future<void> importData(String jsonData) async {
    await init();
    
    try {
      final data = json.decode(jsonData) as Map<String, dynamic>;
      
      if (data['version'] != AppConstants.appVersion) {
        throw Exception('Несовместимая версия данных');
      }
      
      final contactsJson = data['contacts'] as List;
      final messagesJson = data['messages'] as List;
      
      final contacts = contactsJson
          .map((json) => Contact.fromJson(json as Map<String, dynamic>))
          .toList();
      
      final messages = messagesJson
          .map((json) => Message.fromJson(json as Map<String, dynamic>))
          .toList();
      
      await saveContacts(contacts);
      await saveMessages(messages);
      
    } catch (e) {
      throw Exception('Ошибка импорта данных: $e');
    }
  }
  
  // Cleanup
  Future<void> clearAllData() async {
    await init();
    await _messagesBox.clear();
    await _contactsBox.clear();
  }
  
  Future<void> cleanupExpiredMessages() async {
    await init();
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    
    final expiredMessages = _messagesBox.values
        .where((msg) => msg.timestamp.isBefore(thirtyDaysAgo) && !msg.isPinned)
        .map((msg) => msg.id)
        .toList();
    
    if (expiredMessages.isNotEmpty) {
      await deleteMessages(expiredMessages);
    }
  }
  
  Future<void> close() async {
    await _messagesBox.close();
    await _contactsBox.close();
  }
}