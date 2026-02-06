import 'package:hive/hive.dart';

part 'contact.g.dart';

@HiveType(typeId: 1)
class Contact {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String uin;
  
  @HiveField(2)
  final String name;
  
  @HiveField(3)
  final DateTime dateAdded;
  
  @HiveField(4)
  final bool isOnline;
  
  @HiveField(5)
  final DateTime? lastSeen;
  
  @HiveField(6)
  final bool isGroup;
  
  @HiveField(7)
  final List<String>? groupMembers;
  
  @HiveField(8)
  final String? groupAdmin;
  
  @HiveField(9)
  final String? groupDescription;
  
  @HiveField(10)
  final String? groupAvatar;
  
  @HiveField(11)
  final bool isFavorite;
  
  @HiveField(12)
  final bool isBlocked;
  
  @HiveField(13)
  final bool notificationsMuted;
  
  @HiveField(14)
  final DateTime? muteUntil;
  
  @HiveField(15)
  final String? customName;
  
  @HiveField(16)
  final String? statusMessage;
  
  @HiveField(17)
  final String? avatarUrl;
  
  @HiveField(18)
  final String? wallpaper;

  Contact({
    String? id,
    required this.uin,
    required this.name,
    DateTime? dateAdded,
    this.isOnline = false,
    this.lastSeen,
    this.isGroup = false,
    this.groupMembers,
    this.groupAdmin,
    this.groupDescription,
    this.groupAvatar,
    this.isFavorite = false,
    this.isBlocked = false,
    this.notificationsMuted = false,
    this.muteUntil,
    this.customName,
    this.statusMessage,
    this.avatarUrl,
    this.wallpaper,
  })  : id = id ?? uin,
        dateAdded = dateAdded ?? DateTime.now(),
        groupMembers = isGroup ? (groupMembers ?? []) : null;

  // Копирование с изменениями
  Contact copyWith({
    String? name,
    bool? isOnline,
    DateTime? lastSeen,
    bool? isFavorite,
    bool? isBlocked,
    bool? notificationsMuted,
    DateTime? muteUntil,
    String? customName,
    String? statusMessage,
    String? avatarUrl,
    String? wallpaper,
    List<String>? groupMembers,
    String? groupAdmin,
    String? groupDescription,
    String? groupAvatar,
  }) {
    return Contact(
      id: id,
      uin: uin,
      name: name ?? this.name,
      dateAdded: dateAdded,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      isGroup: isGroup,
      groupMembers: groupMembers ?? this.groupMembers,
      groupAdmin: groupAdmin ?? this.groupAdmin,
      groupDescription: groupDescription ?? this.groupDescription,
      groupAvatar: groupAvatar ?? this.groupAvatar,
      isFavorite: isFavorite ?? this.isFavorite,
      isBlocked: isBlocked ?? this.isBlocked,
      notificationsMuted: notificationsMuted ?? this.notificationsMuted,
      muteUntil: muteUntil ?? this.muteUntil,
      customName: customName ?? this.customName,
      statusMessage: statusMessage ?? this.statusMessage,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      wallpaper: wallpaper ?? this.wallpaper,
    );
  }

  // Фабрика для создания группы
  static Contact createGroup({
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
    );
  }

  // Сериализация в JSON
  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] as String,
      uin: json['uin'] as String,
      name: json['name'] as String,
      dateAdded: DateTime.parse(json['dateAdded'] as String),
      isOnline: json['isOnline'] as bool? ?? false,
      lastSeen: json['lastSeen'] != null 
          ? DateTime.parse(json['lastSeen'] as String) 
          : null,
      isGroup: json['isGroup'] as bool? ?? false,
      groupMembers: json['groupMembers'] != null
          ? List<String>.from(json['groupMembers'] as List)
          : null,
      groupAdmin: json['groupAdmin'] as String?,
      groupDescription: json['groupDescription'] as String?,
      groupAvatar: json['groupAvatar'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      isBlocked: json['isBlocked'] as bool? ?? false,
      notificationsMuted: json['notificationsMuted'] as bool? ?? false,
      muteUntil: json['muteUntil'] != null
          ? DateTime.parse(json['muteUntil'] as String)
          : null,
      customName: json['customName'] as String?,
      statusMessage: json['statusMessage'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      wallpaper: json['wallpaper'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uin': uin,
      'name': name,
      'dateAdded': dateAdded.toIso8601String(),
      'isOnline': isOnline,
      'lastSeen': lastSeen?.toIso8601String(),
      'isGroup': isGroup,
      'groupMembers': groupMembers,
      'groupAdmin': groupAdmin,
      'groupDescription': groupDescription,
      'groupAvatar': groupAvatar,
      'isFavorite': isFavorite,
      'isBlocked': isBlocked,
      'notificationsMuted': notificationsMuted,
      'muteUntil': muteUntil?.toIso8601String(),
      'customName': customName,
      'statusMessage': statusMessage,
      'avatarUrl': avatarUrl,
      'wallpaper': wallpaper,
    };
  }

  // Вспомогательные методы
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
    return '${lastSeen!.day}.${lastSeen!.month}.${lastSeen!.year}';
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
          : DateTime(2100, 1, 1);
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

// Адаптер для Hive будет сгенерирован автоматически
// Запусти: flutter packages pub run build_runner build