// lib/models/message.dart
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

enum MessageType { text, image, voice, file, video, location, contact, system }

enum MessageStatus { sending, sent, delivered, read, error }

class Message {
  final String id;
  final String chatId;
  final String senderUIN;
  final String? senderName;
  final String text;
  final DateTime timestamp;
  final bool isSent;
  final MessageType type;
  final String? filePath;
  final String? thumbnailPath;
  final int? audioDuration;
  final int? videoDuration;
  final int? fileSize;
  final String? fileName;
  final bool isEdited;
  final MessageStatus status;
  
  // Новые поля для улучшений
  final Message? replyTo;              // Ответ на сообщение
  final bool isForwarded;              // Пересланное сообщение
  final String? originalSenderName;    // Имя оригинального отправителя (для пересылки)
  final DateTime? forwardedAt;         // Время пересылки
  
  // Реакции на сообщение (userId -> emoji)
  final Map<String, String> reactions;
  
  // Информация о прочтении (userId -> время прочтения)
  final Map<String, DateTime> readBy;
  
  // Пометка о важности
  final bool isStarred;
  
  // Сообщение удалено для отправителя/получателя
  final bool deletedForSender;
  final bool deletedForReceiver;

  Message({
    required this.chatId,
    required this.senderUIN,
    this.senderName,
    required this.text,
    required this.timestamp,
    required this.isSent,
    this.type = MessageType.text,
    this.filePath,
    this.thumbnailPath,
    this.audioDuration,
    this.videoDuration,
    this.fileSize,
    this.fileName,
    this.isEdited = false,
    this.status = MessageStatus.sending,
    this.replyTo,
    this.isForwarded = false,
    this.originalSenderName,
    this.forwardedAt,
    this.reactions = const {},
    this.readBy = const {},
    this.isStarred = false,
    this.deletedForSender = false,
    this.deletedForReceiver = false,
    String? id,
  }) : id = id ?? const Uuid().v4();

  // Конструктор копирования
  Message copyWith({
    String? chatId,
    String? senderUIN,
    String? senderName,
    String? text,
    DateTime? timestamp,
    bool? isSent,
    MessageType? type,
    String? filePath,
    String? thumbnailPath,
    int? audioDuration,
    int? videoDuration,
    int? fileSize,
    String? fileName,
    bool? isEdited,
    MessageStatus? status,
    Message? replyTo,
    bool? isForwarded,
    String? originalSenderName,
    DateTime? forwardedAt,
    Map<String, String>? reactions,
    Map<String, DateTime>? readBy,
    bool? isStarred,
    bool? deletedForSender,
    bool? deletedForReceiver,
  }) {
    return Message(
      id: id,
      chatId: chatId ?? this.chatId,
      senderUIN: senderUIN ?? this.senderUIN,
      senderName: senderName ?? this.senderName,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      isSent: isSent ?? this.isSent,
      type: type ?? this.type,
      filePath: filePath ?? this.filePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      audioDuration: audioDuration ?? this.audioDuration,
      videoDuration: videoDuration ?? this.videoDuration,
      fileSize: fileSize ?? this.fileSize,
      fileName: fileName ?? this.fileName,
      isEdited: isEdited ?? this.isEdited,
      status: status ?? this.status,
      replyTo: replyTo ?? this.replyTo,
      isForwarded: isForwarded ?? this.isForwarded,
      originalSenderName: originalSenderName ?? this.originalSenderName,
      forwardedAt: forwardedAt ?? this.forwardedAt,
      reactions: reactions ?? this.reactions,
      readBy: readBy ?? this.readBy,
      isStarred: isStarred ?? this.isStarred,
      deletedForSender: deletedForSender ?? this.deletedForSender,
      deletedForReceiver: deletedForReceiver ?? this.deletedForReceiver,
    );
  }

  // Добавить реакцию
  Message addReaction(String userId, String emoji) {
    final newReactions = Map<String, String>.from(reactions);
    newReactions[userId] = emoji;
    return copyWith(reactions: newReactions);
  }

  // Удалить реакцию
  Message removeReaction(String userId) {
    final newReactions = Map<String, String>.from(reactions);
    newReactions.remove(userId);
    return copyWith(reactions: newReactions);
  }

  // Отметить как прочитанное
  Message markAsRead(String userId) {
    final newReadBy = Map<String, DateTime>.from(readBy);
    newReadBy[userId] = DateTime.now();
    return copyWith(readBy: newReadBy);
  }

  // Проверить, прочитано ли пользователем
  bool isReadBy(String userId) => readBy.containsKey(userId);

  // Получить время прочтения
  DateTime? getReadTime(String userId) => readBy[userId];

  // Фабричные конструкторы для разных типов сообщений

  factory Message.textMessage({
    required String chatId,
    required String senderUIN,
    String? senderName,
    required String text,
    DateTime? timestamp,
    bool isSent = true,
    MessageStatus status = MessageStatus.sent,
    Message? replyTo,
    bool isForwarded = false,
    String? originalSenderName,
    DateTime? forwardedAt,
  }) {
    return Message(
      chatId: chatId,
      senderUIN: senderUIN,
      senderName: senderName,
      text: text,
      timestamp: timestamp ?? DateTime.now(),
      isSent: isSent,
      type: MessageType.text,
      status: status,
      replyTo: replyTo,
      isForwarded: isForwarded,
      originalSenderName: originalSenderName,
      forwardedAt: forwardedAt,
    );
  }

  factory Message.imageMessage({
    required String chatId,
    required String senderUIN,
    String? senderName,
    required String filePath,
    String? thumbnailPath,
    String? caption,
    int? fileSize,
    DateTime? timestamp,
    bool isSent = true,
    MessageStatus status = MessageStatus.sent,
    Message? replyTo,
  }) {
    return Message(
      chatId: chatId,
      senderUIN: senderUIN,
      senderName: senderName,
      text: caption ?? '📷 Фото',
      timestamp: timestamp ?? DateTime.now(),
      isSent: isSent,
      type: MessageType.image,
      filePath: filePath,
      thumbnailPath: thumbnailPath,
      fileSize: fileSize,
      status: status,
      replyTo: replyTo,
    );
  }

  factory Message.videoMessage({
    required String chatId,
    required String senderUIN,
    String? senderName,
    required String filePath,
    String? thumbnailPath,
    String? caption,
    int? duration,
    int? fileSize,
    DateTime? timestamp,
    bool isSent = true,
    MessageStatus status = MessageStatus.sent,
    Message? replyTo,
  }) {
    return Message(
      chatId: chatId,
      senderUIN: senderUIN,
      senderName: senderName,
      text: caption ?? '🎬 Видео',
      timestamp: timestamp ?? DateTime.now(),
      isSent: isSent,
      type: MessageType.video,
      filePath: filePath,
      thumbnailPath: thumbnailPath,
      videoDuration: duration,
      fileSize: fileSize,
      status: status,
      replyTo: replyTo,
    );
  }

  factory Message.voiceMessage({
    required String chatId,
    required String senderUIN,
    String? senderName,
    required String filePath,
    required int duration,
    DateTime? timestamp,
    bool isSent = true,
    MessageStatus status = MessageStatus.sent,
    Message? replyTo,
  }) {
    return Message(
      chatId: chatId,
      senderUIN: senderUIN,
      senderName: senderName,
      text: '🎤 Голосовое сообщение',
      timestamp: timestamp ?? DateTime.now(),
      isSent: isSent,
      type: MessageType.voice,
      filePath: filePath,
      audioDuration: duration,
      status: status,
      replyTo: replyTo,
    );
  }

  factory Message.fileMessage({
    required String chatId,
    required String senderUIN,
    String? senderName,
    required String filePath,
    required String fileName,
    required int fileSize,
    String? text,
    DateTime? timestamp,
    bool isSent = true,
    MessageStatus status = MessageStatus.sent,
    Message? replyTo,
  }) {
    return Message(
      chatId: chatId,
      senderUIN: senderUIN,
      senderName: senderName,
      text: text ?? '📎 Файл: $fileName',
      timestamp: timestamp ?? DateTime.now(),
      isSent: isSent,
      type: MessageType.file,
      filePath: filePath,
      fileName: fileName,
      fileSize: fileSize,
      status: status,
      replyTo: replyTo,
    );
  }

  factory Message.forwardedMessage({
    required Message originalMessage,
    required String chatId,
    required String senderUIN,
    String? senderName,
    DateTime? forwardedAt,
  }) {
    return Message(
      id: const Uuid().v4(),
      chatId: chatId,
      senderUIN: senderUIN,
      senderName: senderName,
      text: originalMessage.text,
      timestamp: forwardedAt ?? DateTime.now(),
      isSent: true,
      type: originalMessage.type,
      filePath: originalMessage.filePath,
      thumbnailPath: originalMessage.thumbnailPath,
      audioDuration: originalMessage.audioDuration,
      videoDuration: originalMessage.videoDuration,
      fileSize: originalMessage.fileSize,
      fileName: originalMessage.fileName,
      isEdited: originalMessage.isEdited,
      status: MessageStatus.sent,
      replyTo: null,
      isForwarded: true,
      originalSenderName: originalMessage.senderName,
      forwardedAt: forwardedAt ?? DateTime.now(),
      reactions: {},
      readBy: {},
      isStarred: false,
      deletedForSender: false,
      deletedForReceiver: false,
    );
  }

  // Вспомогательные методы

  String get formattedTime => DateFormat('HH:mm').format(timestamp);
  String get formattedDate => DateFormat('dd.MM.yy').format(timestamp);
  
  bool get hasMedia => type == MessageType.image || 
                       type == MessageType.video || 
                       type == MessageType.voice || 
                       type == MessageType.file;
  
  bool get canBeReplied => type != MessageType.system;
  
  bool get canBeForwarded => type != MessageType.system;
  
  bool get canBeStarred => type != MessageType.system;
  
  String get displayText {
    if (isForwarded && originalSenderName != null) {
      return 'Пересланное сообщение от $originalSenderName';
    }
    return text;
  }

  List<String> get reactionsList => reactions.values.toSet().toList();
  
  int get reactionCount => reactions.length;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Message &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Message{id: $id, type: $type, status: $status, text: $text, '
           'isForwarded: $isForwarded, reactions: $reactions}';
  }
}

// Класс для результата выбора медиа
class MediaFile {
  final String path;
  final String? thumbnailPath;
  final int size;
  final String? name;
  final int? duration;
  final bool isVideo;

  MediaFile({
    required this.path,
    this.thumbnailPath,
    required this.size,
    this.name,
    this.duration,
    required this.isVideo,
  });
}