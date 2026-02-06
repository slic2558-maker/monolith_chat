import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

part 'message.g.dart';

@HiveType(typeId: 0)
class Message {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String chatId;
  
  @HiveField(2)
  final String senderUIN;
  
  @HiveField(3)
  final String? senderName;
  
  @HiveField(4)
  final String text;
  
  @HiveField(5)
  final DateTime timestamp;
  
  @HiveField(6)
  final bool isSent; // true = sent by me, false = received
  
  @HiveField(7)
  final MessageType type;
  
  @HiveField(8)
  final String? filePath;
  
  @HiveField(9)
  final String? fileUrl;
  
  @HiveField(10)
  final int? fileSize;
  
  @HiveField(11)
  final String? fileMimeType;
  
  @HiveField(12)
  final int? audioDuration;
  
  @HiveField(13)
  final String? thumbnailUrl;
  
  @HiveField(14)
  final bool isEdited;
  
  @HiveField(15)
  final DateTime? editedAt;
  
  @HiveField(16)
  final MessageStatus status;
  
  @HiveField(17)
  final String? replyToMessageId;
  
  @HiveField(18)
  final String? quotedText;
  
  @HiveField(19)
  final String? quotedSenderName;
  
  @HiveField(20)
  final Map<String, String> reactions; // UIN -> emoji
  
  @HiveField(21)
  final List<String> readBy; // List of UINs who read the message
  
  @HiveField(22)
  final List<String> deliveredTo; // List of UINs who received
  
  @HiveField(23)
  final bool isPinned;
  
  @HiveField(24)
  final DateTime? pinnedAt;
  
  @HiveField(25)
  final String? pinnedBy;
  
  @HiveField(26)
  final bool isDeleted;
  
  @HiveField(27)
  final DateTime? deletedAt;
  
  @HiveField(28)
  final String? deletedBy;
  
  @HiveField(29)
  final bool deleteForEveryone;
  
  @HiveField(30)
  final Map<String, dynamic> metadata;
  
  @HiveField(31)
  final String? localId; // For offline messages
  

  Message({
    required this.chatId,
    required this.senderUIN,
    this.senderName,
    required this.text,
    required this.timestamp,
    required this.isSent,
    this.type = MessageType.text,
    this.filePath,
    this.fileUrl,
    this.fileSize,
    this.fileMimeType,
    this.audioDuration,
    this.thumbnailUrl,
    this.isEdited = false,
    this.editedAt,
    this.status = MessageStatus.sending,
    this.replyToMessageId,
    this.quotedText,
    this.quotedSenderName,
    Map<String, String>? reactions,
    List<String>? readBy,
    List<String>? deliveredTo,
    this.isPinned = false,
    this.pinnedAt,
    this.pinnedBy,
    this.isDeleted = false,
    this.deletedAt,
    this.deletedBy,
    this.deleteForEveryone = false,
    Map<String, dynamic>? metadata,
    this.localId,
    String? id,
  })  : id = id ?? 'msg_${senderUIN}_${timestamp.millisecondsSinceEpoch}_${UniqueKey().hashCode}',
        reactions = reactions ?? {},
        readBy = readBy ?? [],
        deliveredTo = deliveredTo ?? [],
        metadata = metadata ?? {};

  // Copy with method
  Message copyWith({
    String? text,
    MessageType? type,
    String? filePath,
    String? fileUrl,
    int? fileSize,
    String? fileMimeType,
    int? audioDuration,
    String? thumbnailUrl,
    bool? isEdited,
    DateTime? editedAt,
    MessageStatus? status,
    String? replyToMessageId,
    String? quotedText,
    String? quotedSenderName,
    Map<String, String>? reactions,
    List<String>? readBy,
    List<String>? deliveredTo,
    bool? isPinned,
    DateTime? pinnedAt,
    String? pinnedBy,
    bool? isDeleted,
    DateTime? deletedAt,
    String? deletedBy,
    bool? deleteForEveryone,
    Map<String, dynamic>? metadata,
    String? localId,
  }) {
    return Message(
      id: id,
      chatId: chatId,
      senderUIN: senderUIN,
      senderName: senderName,
      text: text ?? this.text,
      timestamp: timestamp,
      isSent: isSent,
      type: type ?? this.type,
      filePath: filePath ?? this.filePath,
      fileUrl: fileUrl ?? this.fileUrl,
      fileSize: fileSize ?? this.fileSize,
      fileMimeType: fileMimeType ?? this.fileMimeType,
      audioDuration: audioDuration ?? this.audioDuration,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      status: status ?? this.status,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      quotedText: quotedText ?? this.quotedText,
      quotedSenderName: quotedSenderName ?? this.quotedSenderName,
      reactions: reactions ?? Map.from(this.reactions),
      readBy: readBy ?? List.from(this.readBy),
      deliveredTo: deliveredTo ?? List.from(this.deliveredTo),
      isPinned: isPinned ?? this.isPinned,
      pinnedAt: pinnedAt ?? this.pinnedAt,
      pinnedBy: pinnedBy ?? this.pinnedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      deletedBy: deletedBy ?? this.deletedBy,
      deleteForEveryone: deleteForEveryone ?? this.deleteForEveryone,
      metadata: metadata ?? Map.from(this.metadata),
      localId: localId ?? this.localId,
    );
  }

  // Factory constructors
  factory Message.textMessage({
    required String chatId,
    required String senderUIN,
    String? senderName,
    required String text,
    required DateTime timestamp,
    required bool isSent,
    MessageStatus status = MessageStatus.sending,
    String? replyToMessageId,
    String? quotedText,
    String? quotedSenderName,
  }) {
    return Message(
      chatId: chatId,
      senderUIN: senderUIN,
      senderName: senderName,
      text: text,
      timestamp: timestamp,
      isSent: isSent,
      type: MessageType.text,
      status: status,
      replyToMessageId: replyToMessageId,
      quotedText: quotedText,
      quotedSenderName: quotedSenderName,
    );
  }

  factory Message.imageMessage({
    required String chatId,
    required String senderUIN,
    String? senderName,
    required String filePath,
    String? fileUrl,
    String? caption,
    int? fileSize,
    String? thumbnailUrl,
    required DateTime timestamp,
    required bool isSent,
    MessageStatus status = MessageStatus.sending,
  }) {
    return Message(
      chatId: chatId,
      senderUIN: senderUIN,
      senderName: senderName,
      text: caption ?? '📷 Фото',
      timestamp: timestamp,
      isSent: isSent,
      type: MessageType.image,
      filePath: filePath,
      fileUrl: fileUrl,
      fileSize: fileSize,
      thumbnailUrl: thumbnailUrl,
      status: status,
    );
  }

  factory Message.voiceMessage({
    required String chatId,
    required String senderUIN,
    String? senderName,
    required String filePath,
    String? fileUrl,
    required int duration,
    required DateTime timestamp,
    required bool isSent,
    MessageStatus status = MessageStatus.sending,
  }) {
    return Message(
      chatId: chatId,
      senderUIN: senderUIN,
      senderName: senderName,
      text: '🎤 Голосовое сообщение',
      timestamp: timestamp,
      isSent: isSent,
      type: MessageType.voice,
      filePath: filePath,
      fileUrl: fileUrl,
      audioDuration: duration,
      status: status,
    );
  }

  factory Message.videoMessage({
    required String chatId,
    required String senderUIN,
    String? senderName,
    required String filePath,
    String? fileUrl,
    String? caption,
    int? duration,
    int? fileSize,
    String? thumbnailUrl,
    required DateTime timestamp,
    required bool isSent,
    MessageStatus status = MessageStatus.sending,
  }) {
    return Message(
      chatId: chatId,
      senderUIN: senderUIN,
      senderName: senderName,
      text: caption ?? '🎥 Видео',
      timestamp: timestamp,
      isSent: isSent,
      type: MessageType.video,
      filePath: filePath,
      fileUrl: fileUrl,
      audioDuration: duration,
      fileSize: fileSize,
      thumbnailUrl: thumbnailUrl,
      status: status,
    );
  }

  factory Message.fileMessage({
    required String chatId,
    required String senderUIN,
    String? senderName,
    required String fileName,
    required String filePath,
    String? fileUrl,
    required int fileSize,
    required String mimeType,
    required DateTime timestamp,
    required bool isSent,
    MessageStatus status = MessageStatus.sending,
  }) {
    return Message(
      chatId: chatId,
      senderUIN: senderUIN,
      senderName: senderName,
      text: '📎 $fileName',
      timestamp: timestamp,
      isSent: isSent,
      type: MessageType.file,
      filePath: filePath,
      fileUrl: fileUrl,
      fileSize: fileSize,
      fileMimeType: mimeType,
      status: status,
    );
  }

  factory Message.systemMessage({
    required String chatId,
    required String text,
    required DateTime timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return Message(
      chatId: chatId,
      senderUIN: 'system',
      senderName: 'System',
      text: text,
      timestamp: timestamp,
      isSent: false,
      type: MessageType.system,
      status: MessageStatus.read,
      metadata: metadata,
    );
  }

  // JSON serialization
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      chatId: json['chatId'] as String,
      senderUIN: json['senderUIN'] as String,
      senderName: json['senderName'] as String?,
      text: json['text'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isSent: json['isSent'] as bool,
      type: MessageType.values[json['type'] as int],
      filePath: json['filePath'] as String?,
      fileUrl: json['fileUrl'] as String?,
      fileSize: json['fileSize'] as int?,
      fileMimeType: json['fileMimeType'] as String?,
      audioDuration: json['audioDuration'] as int?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      isEdited: json['isEdited'] as bool? ?? false,
      editedAt: json['editedAt'] != null
          ? DateTime.parse(json['editedAt'] as String)
          : null,
      status: MessageStatus.values[json['status'] as int],
      replyToMessageId: json['replyToMessageId'] as String?,
      quotedText: json['quotedText'] as String?,
      quotedSenderName: json['quotedSenderName'] as String?,
      reactions: Map<String, String>.from(json['reactions'] as Map? ?? {}),
      readBy: List<String>.from(json['readBy'] as List? ?? []),
      deliveredTo: List<String>.from(json['deliveredTo'] as List? ?? []),
      isPinned: json['isPinned'] as bool? ?? false,
      pinnedAt: json['pinnedAt'] != null
          ? DateTime.parse(json['pinnedAt'] as String)
          : null,
      pinnedBy: json['pinnedBy'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'] as String)
          : null,
      deletedBy: json['deletedBy'] as String?,
      deleteForEveryone: json['deleteForEveryone'] as bool? ?? false,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
      localId: json['localId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'senderUIN': senderUIN,
      'senderName': senderName,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'isSent': isSent,
      'type': type.index,
      'filePath': filePath,
      'fileUrl': fileUrl,
      'fileSize': fileSize,
      'fileMimeType': fileMimeType,
      'audioDuration': audioDuration,
      'thumbnailUrl': thumbnailUrl,
      'isEdited': isEdited,
      'editedAt': editedAt?.toIso8601String(),
      'status': status.index,
      'replyToMessageId': replyToMessageId,
      'quotedText': quotedText,
      'quotedSenderName': quotedSenderName,
      'reactions': reactions,
      'readBy': readBy,
      'deliveredTo': deliveredTo,
      'isPinned': isPinned,
      'pinnedAt': pinnedAt?.toIso8601String(),
      'pinnedBy': pinnedBy,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
      'deletedBy': deletedBy,
      'deleteForEveryone': deleteForEveryone,
      'metadata': metadata,
      'localId': localId,
    };
  }

  // Helper methods
  String get formattedTime => DateFormat('HH:mm').format(timestamp);
  
  String get formattedDate => DateFormat('dd.MM.yy').format(timestamp);
  
  String get formattedDateTime => DateFormat('dd.MM.yy HH:mm').format(timestamp);
  
  bool get isMedia => type == MessageType.image || 
                      type == MessageType.video || 
                      type == MessageType.voice || 
                      type == MessageType.file;
  
  bool get isText => type == MessageType.text;
  
  bool get isSystem => type == MessageType.system;
  
  bool get canEdit => isText && !isDeleted && isSent;
  
  bool get canDelete => !isDeleted;
  
  bool get canReply => !isDeleted;
  
  bool get canForward => !isDeleted && !isSystem;
  
  bool get canPin => !isDeleted && !isSystem;
  
  bool get canReact => !isDeleted && !isSystem;
  
  void addReaction(String uin, String emoji) {
    reactions[uin] = emoji;
  }
  
  void removeReaction(String uin) {
    reactions.remove(uin);
  }
  
  void markAsRead(String uin) {
    if (!readBy.contains(uin)) {
      readBy.add(uin);
    }
  }
  
  void markAsDelivered(String uin) {
    if (!deliveredTo.contains(uin)) {
      deliveredTo.add(uin);
    }
  }
  
  void pin(String byUin) {
    copyWith(
      isPinned: true,
      pinnedAt: DateTime.now(),
      pinnedBy: byUin,
    );
  }
  
  void unpin() {
    copyWith(
      isPinned: false,
      pinnedAt: null,
      pinnedBy: null,
    );
  }
  
  void delete({bool forEveryone = false, String? byUin}) {
    copyWith(
      isDeleted: true,
      deletedAt: DateTime.now(),
      deletedBy: byUin,
      deleteForEveryone: forEveryone,
    );
  }
  
  void restore() {
    copyWith(
      isDeleted: false,
      deletedAt: null,
      deletedBy: null,
      deleteForEveryone: false,
    );
  }

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
    return 'Message{id: $id, type: $type, status: $status, text: $text}';
  }
}

@HiveType(typeId: 101)
enum MessageType {
  @HiveField(0)
  text,
  @HiveField(1)
  image,
  @HiveField(2)
  voice,
  @HiveField(3)
  video,
  @HiveField(4)
  file,
  @HiveField(5)
  system,
  @HiveField(6)
  location,
  @HiveField(7)
  contact,
  @HiveField(8)
  poll,
}

@HiveType(typeId: 102)
enum MessageStatus {
  @HiveField(0)
  sending,    // Отправляется (часики) ⏳
  @HiveField(1)
  sent,       // Отправлено - 1 серая галочка ✓
  @HiveField(2)
  delivered,  // Доставлено - 2 серые галочки ✓✓
  @HiveField(3)
  read,       // Прочитано - 2 синие галочки ✓✓🔵
  @HiveField(4)
  error,      // Ошибка отправки ❌
  @HiveField(5)
  pending,    // В очереди (оффлайн)
  @HiveField(6)
  cancelled,  // Отменено
}