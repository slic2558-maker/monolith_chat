import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 1)
class User {
  @HiveField(0)
  final String uin;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String? avatarUrl;
  
  @HiveField(3)
  final String? statusMessage;
  
  @HiveField(4)
  final String? phoneNumber;
  
  @HiveField(5)
  final String? email;
  
  @HiveField(6)
  final DateTime lastSeen;
  
  @HiveField(7)
  final bool isOnline;
  
  @HiveField(8)
  final bool isVerified;
  
  @HiveField(9)
  final Map<String, dynamic> metadata;
  
  @HiveField(10)
  final List<String> blockedUsers;
  
  @HiveField(11)
  final DateTime createdAt;
  
  @HiveField(12)
  final DateTime updatedAt;
  
  User({
    required this.uin,
    required this.name,
    this.avatarUrl,
    this.statusMessage,
    this.phoneNumber,
    this.email,
    required this.lastSeen,
    this.isOnline = false,
    this.isVerified = false,
    Map<String, dynamic>? metadata,
    List<String>? blockedUsers,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : metadata = metadata ?? {},
        blockedUsers = blockedUsers ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  User copyWith({
    String? name,
    String? avatarUrl,
    String? statusMessage,
    String? phoneNumber,
    String? email,
    DateTime? lastSeen,
    bool? isOnline,
    bool? isVerified,
    Map<String, dynamic>? metadata,
    List<String>? blockedUsers,
    DateTime? updatedAt,
  }) {
    return User(
      uin: uin,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      statusMessage: statusMessage ?? this.statusMessage,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      lastSeen: lastSeen ?? this.lastSeen,
      isOnline: isOnline ?? this.isOnline,
      isVerified: isVerified ?? this.isVerified,
      metadata: metadata ?? Map.from(this.metadata),
      blockedUsers: blockedUsers ?? List.from(this.blockedUsers),
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Current user singleton
  static User? _currentUser;
  
  static User get current {
    if (_currentUser == null) {
      throw Exception('User not initialized. Call User.initialize() first.');
    }
    return _currentUser!;
  }
  
  static Future<void> initialize({required User user}) async {
    _currentUser = user;
  }
  
  static bool get isInitialized => _currentUser != null;

  // Factory methods
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uin: json['uin'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      statusMessage: json['statusMessage'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
      lastSeen: DateTime.parse(json['lastSeen'] as String),
      isOnline: json['isOnline'] as bool? ?? false,
      isVerified: json['isVerified'] as bool? ?? false,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
      blockedUsers: List<String>.from(json['blockedUsers'] as List? ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uin': uin,
      'name': name,
      'avatarUrl': avatarUrl,
      'statusMessage': statusMessage,
      'phoneNumber': phoneNumber,
      'email': email,
      'lastSeen': lastSeen.toIso8601String(),
      'isOnline': isOnline,
      'isVerified': isVerified,
      'metadata': metadata,
      'blockedUsers': blockedUsers,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper methods
  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;
  
  bool isBlocked(String otherUIN) => blockedUsers.contains(otherUIN);
  
  void blockUser(String uin) {
    if (!blockedUsers.contains(uin)) {
      blockedUsers.add(uin);
    }
  }
  
  void unblockUser(String uin) {
    blockedUsers.remove(uin);
  }
  
  String get initials {
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          uin == other.uin;

  @override
  int get hashCode => uin.hashCode;

  @override
  String toString() {
    return 'User(uin: $uin, name: $name, online: $isOnline)';
  }
}