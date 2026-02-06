class Contact {
  final String id;
  final String uin;
  final String name;
  final DateTime dateAdded;
  final bool isOnline;
  final String lastSeen;
  final bool isGroup;

  Contact({
    String? id,
    required this.uin,
    required this.name,  // Убрать повторный параметр ниже
    this.isOnline = false,
    this.lastSeen = 'только что',
    this.isGroup = false,  // Убрать повторный параметр ниже
    DateTime? dateAdded,
  })  : id = id ?? uin,
        dateAdded = dateAdded ?? DateTime.now();

  Contact copyWith({
    String? name,
    bool? isOnline,
    String? lastSeen,
    bool? isGroup,
  }) {
    return Contact(
      id: id,
      uin: uin,
      name: name ?? this.name,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      isGroup: isGroup ?? this.isGroup,  // Добавить isGroup
      dateAdded: dateAdded,
    );
  }

  // Для групп
  static Contact createGroup({
    required String id,
    required String name,
    List<String>? members,
  }) {
    return Contact(
      id: id,
      uin: 'group_$id',
      name: name,
      isGroup: true,
    );
  }

  @override
  String toString() => 'Contact(id: $id, name: $name, group: $isGroup)';
}