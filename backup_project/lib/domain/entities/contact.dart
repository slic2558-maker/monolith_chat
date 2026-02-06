import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

part 'contact.g.dart';

@HiveType(typeId: 2)
class Contact {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String uin;
  
  @HiveField(2)
  final String name;
  
  @HiveField(3)
  final String? customName;
  
  @HiveField(4)
  final String? avatarUrl;
  
  @HiveField(5)
  final String? statusMessage;
  
  @HiveField(6)
  final DateTime dateAdded;
  
  @HiveField(7)
  final DateTime lastInteraction;
  
  @HiveField(8)
  final bool isOnline;
  
  @HiveField(9)
  final DateTime? lastSeen;
  
  @HiveField(10)
  final bool isFavorite;
  
  @HiveField(11)
  final bool isBlocked;
  
  @HiveField(12)
  final bool isGroup;
  
  @HiveField(13)
  final List<String>? groupMembers;
  
  @HiveField(14)
  final String? groupAdmin;
  
  @HiveField(15)
  final String? groupDescription;
  
  @HiveField(16)
  final String? groupAvatar;
  
  @HiveField(17)
  final Map<String, dynamic> metadata;
  
  @HiveField(18)
  final bool notificationsMuted;
  
  @HiveField(19)
  final DateTime? muteUntil;
  
  @HiveField(20)
  final String? wallpaper;

  Contact({
    String? id,
    required this.uin,
    required this.name,
    this.customName,
    this.avatarUrl,
    this.statusMessage,
    DateTime? dateAdded,
    DateTime? lastInteraction,
    this.isOnline = false,
    this.lastSeen,
    this.isFavorite = false,
    this.isBlocked = false,
    this.isGroup = false,
    this.groupMembers,
    this.groupAdmin,
    this.groupDescription,
    this.groupAvatar,
    Map<String, dynamic>? metadata,
    this.notificationsMuted = false,
    this.muteUntil,
    this.wallpaper,
  })  : id = id ?? uin,
        dateAdded = dateAdded ?? DateTime.now(),
        lastInteraction = lastInteraction ?? DateTime.now(),
        metadata = metadata ?? {},
        groupMembers = groupMembers ?? (isGroup ? [] : null);

  // Copy with
  Contact copyWith({
    String? name,
    String? customName,
    String? avatarUrl,
    String? statusMessage,
    DateTime? lastInteraction,
    bool? isOnline,
    DateTime? lastSeen,
    bool? isFavorite,
    bool? isBlocked,
    bool? isGroup,
    List<String>? groupMembers,
    String? groupAdmin,
    String? groupDescription,
    String? groupAvatar,
    Map<String, dynamic>? metadata,
    bool? notificationsMuted,
    DateTime? muteUntil,
    String? wallpaper,
  }) {
    return Contact(
      id: id,
      uin: uin,
      name: name ?? this.name,
      customName: customName ?? this.customName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      statusMessage: statusMessage ?? this.statusMessage,
      dateAdded: dateAdded,
      lastInteraction: lastInteraction ?? this.lastInteraction,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      isFavorite: isFavorite ?? this.isFavorite,
      isBlocked: isBlocked ?? this.isBlocked,
      isGroup: isGroup ?? this.isGroup,
      groupMembers: groupMembers ?? this.groupMembers,
      groupAdmin: groupAdmin ?? this.groupAdmin,
      groupDescription: groupDescription ?? this.groupDescription,
      groupAvatar: groupAvatar ?? this.groupAvatar,
      metadata: metadata ?? Map.from(this.metadata),
      notificationsMuted: notificationsMuted ?? this.notificationsMuted,
      muteUntil: muteUntil ?? this.muteUntil,
      wallpaper: wallpaper ?? this.wallpaper,
    );
  }

  // Factory for group creation
  factory Contact.createGroup({
    required String name,
    required List<String> members,
    String? admin,
    String? description,
    String? avatar,
  }) {
    final groupId = 'group_${DateTime.now().millisecondsSinceEpoch}';
    return Contact(
      id: groupId,
      uin: groupId,
      name: name,
      isGroup: true,
      groupMembers: members,
      groupAdmin: admin,
      groupDescription: description,
      groupAvatar: avatar,
      dateAdded: DateTime.now(),
      lastInteraction: DateTime.now(),
    );
  }

  // Factory from JSON
  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] as String,
      uin: json['uin'] as String,
      name: json['name'] as String,
      customName: json['customName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      statusMessage: json['statusMessage'] as String?,
      dateAdded: DateTime.parse(json['dateAdded'] as String),
      lastInteraction: DateTime.parse(json['lastInteraction'] as String),
      isOnline: json['isOnline'] as bool? ?? false,
      lastSeen: json['lastSeen'] != null
          ? DateTime.parse(json['lastSeen'] as String)
          : null,
      isFavorite: json['isFavorite'] as bool? ?? false,
      isBlocked: json['isBlocked'] as bool? ?? false,
      isGroup: json['isGroup'] as bool? ?? false,
      groupMembers: json['groupMembers'] != null
          ? List<String>.from(json['groupMembers'] as List)
          : null,
      groupAdmin: json['groupAdmin'] as String?,
      groupDescription: json['groupDescription'] as String?,
      groupAvatar: json['groupAvatar'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
      notificationsMuted: json['notificationsMuted'] as bool? ?? false,
      muteUntil: json['muteUntil'] != null
          ? DateTime.parse(json['muteUntil'] as String)
          : null,
      wallpaper: json['wallpaper'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uin': uin,
      'name': name,
      'customName': customName,
      'avatarUrl': avatarUrl,
      'statusMessage': statusMessage,
      'dateAdded': dateAdded.toIso8601String(),
      'lastInteraction': lastInteraction.toIso8601String(),
      'isOnline': isOnline,
      'lastSeen': lastSeen?.toIso8601String(),
      'isFavorite': isFavorite,
      'isBlocked': isBlocked,
      'isGroup': isGroup,
      'groupMembers': groupMembers,
      'groupAdmin': groupAdmin,
      'groupDescription': groupDescription,
      'groupAvatar': groupAvatar,
      'metadata': metadata,
      'notificationsMuted': notificationsMuted,
      'muteUntil': muteUntil?.toIso8601String(),
      'wallpaper': wallpaper,
    };
  }

  // Helper methods
  String get displayName => customName ?? name;
  
  bool get hasAvatar => (isGroup ? groupAvatar : avatarUrl) != null;
  
  String get avatar => isGroup ? groupAvatar ?? '' : avatarUrl ?? '';
  
  bool get isMuted => notificationsMuted || (muteUntil?.isAfter(DateTime.now()) ?? false);
  
  String get lastSeenFormatted {
    if (lastSeen == null) return 'никогда';
    final now = DateTime.now();
    final difference = now.difference(lastSeen!);
    
    if (difference.inSeconds < 60) return 'только что';
    if (difference.inMinutes < 60) return '${difference.inMinutes} мин назад';
    if (difference.inHours < 24) return '${difference.inHours} ч назад';
    if (difference.inDays < 7) return '${difference.inDays} д назад';
    return DateFormat('dd.MM.yy').format(lastSeen!);
  }
  
  bool isAdmin(String uin) => isGroup && groupAdmin == uin;
  
  bool isMember(String uin) => isGroup && (groupMembers?.contains(uin) ?? false);
  
  void addMember(String uin) {
    if (isGroup && !(groupMembers?.contains(uin) ?? false)) {
      groupMembers?.add(uin);
    }
  }
  
  void removeMember(String uin) {
    if (isGroup) {
      groupMembers?.remove(uin);
    }
  }
  
  void toggleFavorite() => copyWith(isFavorite: !isFavorite);
  
  void toggleMute({Duration? duration}) {
    if (notificationsMuted) {
      copyWith(notificationsMuted: false, muteUntil: null);
    } else {
      final muteUntil = duration != null
          ? DateTime.now().add(duration)
          : DateTime(2100, 1, 1); // Forever
      copyWith(notificationsMuted: true, muteUntil: muteUntil);
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Contact &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Contact(id: $id, name: $displayName, group: $isGroup)';
  }
}