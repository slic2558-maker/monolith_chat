import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

part 'status.g.dart';

@HiveType(typeId: 3)
class Status {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String creatorUIN;
  
  @HiveField(2)
  final String? creatorName;
  
  @HiveField(3)
  final String? avatarUrl;
  
  @HiveField(4)
  final StatusType type;
  
  @HiveField(5)
  final String? text;
  
  @HiveField(6)
  final String? mediaUrl;
  
  @HiveField(7)
  final String? thumbnailUrl;
  
  @HiveField(8)
  final String? filePath;
  
  @HiveField(9)
  final int? duration;
  
  @HiveField(10)
  final DateTime createdAt;
  
  @HiveField(11)
  final DateTime expiresAt;
  
  @HiveField(12)
  final List<String> viewers;
  
  @HiveField(13)
  final int viewCount;
  
  @HiveField(14)
  final bool isMuted;
  
  @HiveField(15)
  final Map<String, dynamic> metadata;

  Status({
    required this.creatorUIN,
    this.creatorName,
    this.avatarUrl,
    required this.type,
    this.text,
    this.mediaUrl,
    this.thumbnailUrl,
    this.filePath,
    this.duration,
    DateTime? createdAt,
    DateTime? expiresAt,
    List<String>? viewers,
    int? viewCount,
    this.isMuted = false,
    Map<String, dynamic>? metadata,
    String? id,
  })  : id = id ?? 'status_${creatorUIN}_${DateTime.now().millisecondsSinceEpoch}',
        createdAt = createdAt ?? DateTime.now(),
        expiresAt = expiresAt ?? DateTime.now().add(const Duration(hours: 24)),
        viewers = viewers ?? [],
        viewCount = viewCount ?? 0,
        metadata = metadata ?? {};

  // Copy with
  Status copyWith({
    String? creatorName,
    String? avatarUrl,
    StatusType? type,
    String? text,
    String? mediaUrl,
    String? thumbnailUrl,
    String? filePath,
    int? duration,
    DateTime? expiresAt,
    List<String>? viewers,
    int? viewCount,
    bool? isMuted,
    Map<String, dynamic>? metadata,
  }) {
    return Status(
      id: id,
      creatorUIN: creatorUIN,
      creatorName: creatorName ?? this.creatorName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      type: type ?? this.type,
      text: text ?? this.text,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      filePath: filePath ?? this.filePath,
      duration: duration ?? this.duration,
      createdAt: createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      viewers: viewers ?? List.from(this.viewers),
      viewCount: viewCount ?? this.viewCount,
      isMuted: isMuted ?? this.isMuted,
      metadata: metadata ?? Map.from(this.metadata),
    );
  }

  // Factories
  factory Status.textStatus({
    required String creatorUIN,
    String? creatorName,
    required String text,
    String? avatarUrl,
    DateTime? expiresAt,
  }) {
    return Status(
      creatorUIN: creatorUIN,
      creatorName: creatorName,
      avatarUrl: avatarUrl,
      type: StatusType.text,
      text: text,
      expiresAt: expiresAt,
    );
  }

  factory Status.imageStatus({
    required String creatorUIN,
    String? creatorName,
    required String imageUrl,
    String? thumbnailUrl,
    String? filePath,
    String? caption,
    String? avatarUrl,
    DateTime? expiresAt,
  }) {
    return Status(
      creatorUIN: creatorUIN,
      creatorName: creatorName,
      avatarUrl: avatarUrl,
      type: StatusType.image,
      text: caption,
      mediaUrl: imageUrl,
      thumbnailUrl: thumbnailUrl,
      filePath: filePath,
      expiresAt: expiresAt,
    );
  }

  factory Status.videoStatus({
    required String creatorUIN,
    String? creatorName,
    required String videoUrl,
    String? thumbnailUrl,
    String? filePath,
    int? duration,
    String? caption,
    String? avatarUrl,
    DateTime? expiresAt,
  }) {
    return Status(
      creatorUIN: creatorUIN,
      creatorName: creatorName,
      avatarUrl: avatarUrl,
      type: StatusType.video,
      text: caption,
      mediaUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      filePath: filePath,
      duration: duration,
      expiresAt: expiresAt,
    );
  }

  // JSON
  factory Status.fromJson(Map<String, dynamic> json) {
    return Status(
      id: json['id'] as String,
      creatorUIN: json['creatorUIN'] as String,
      creatorName: json['creatorName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      type: StatusType.values[json['type'] as int],
      text: json['text'] as String?,
      mediaUrl: json['mediaUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      filePath: json['filePath'] as String?,
      duration: json['duration'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      viewers: List<String>.from(json['viewers'] as List),
      viewCount: json['viewCount'] as int,
      isMuted: json['isMuted'] as bool? ?? false,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creatorUIN': creatorUIN,
      'creatorName': creatorName,
      'avatarUrl': avatarUrl,
      'type': type.index,
      'text': text,
      'mediaUrl': mediaUrl,
      'thumbnailUrl': thumbnailUrl,
      'filePath': filePath,
      'duration': duration,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'viewers': viewers,
      'viewCount': viewCount,
      'isMuted': isMuted,
      'metadata': metadata,
    };
  }

  // Helper methods
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  
  bool get isViewed => viewers.isNotEmpty;
  
  Duration get timeLeft => expiresAt.difference(DateTime.now());
  
  String get timeLeftFormatted {
    final left = timeLeft;
    if (left.inHours > 0) return '${left.inHours}ч';
    if (left.inMinutes > 0) return '${left.inMinutes}мин';
    return '${left.inSeconds}сек';
  }
  
  String get createdAtFormatted {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inSeconds < 60) return 'Только что';
    if (difference.inMinutes < 60) return '${difference.inMinutes} мин назад';
    if (difference.inHours < 24) return '${difference.inHours} ч назад';
    return DateFormat('dd.MM.yy HH:mm').format(createdAt);
  }
  
  void addViewer(String uin) {
    if (!viewers.contains(uin)) {
      viewers.add(uin);
    }
  }
  
  bool hasViewed(String uin) => viewers.contains(uin);
  
  int get remainingViews {
    // WhatsApp shows status to first 100 viewers in detail
    return 100 - viewers.length;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Status &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Status{id: $id, creator: $creatorUIN, type: $type}';
  }
}

@HiveType(typeId: 103)
enum StatusType {
  @HiveField(0)
  text,
  @HiveField(1)
  image,
  @HiveField(2)
  video,
}