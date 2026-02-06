import 'package:hive/hive.dart';
import '../../domain/entities/contact.dart';
import '../../domain/entities/message.dart';

part 'hive_adapters.g.dart';

@HiveType(typeId: 1)
class ContactAdapter extends TypeAdapter<Contact> {
  @override
  final int typeId = 1;

  @override
  Contact read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    
    return Contact(
      id: fields[0] as String,
      uin: fields[1] as String,
      name: fields[2] as String,
      dateAdded: fields[3] as DateTime,
      isOnline: fields[4] as bool,
      lastSeen: fields[5] as DateTime?,
      isGroup: fields[6] as bool,
      groupMembers: (fields[7] as List?)?.cast<String>(),
      groupAdmin: fields[8] as String?,
      groupDescription: fields[9] as String?,
      groupAvatar: fields[10] as String?,
      isFavorite: fields[11] as bool,
      isBlocked: fields[12] as bool,
      notificationsMuted: fields[13] as bool,
      muteUntil: fields[14] as DateTime?,
      customName: fields[15] as String?,
      statusMessage: fields[16] as String?,
      avatarUrl: fields[17] as String?,
      wallpaper: fields[18] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Contact obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.uin)
      ..writeByte(2)..write(obj.name)
      ..writeByte(3)..write(obj.dateAdded)
      ..writeByte(4)..write(obj.isOnline)
      ..writeByte(5)..write(obj.lastSeen)
      ..writeByte(6)..write(obj.isGroup)
      ..writeByte(7)..write(obj.groupMembers)
      ..writeByte(8)..write(obj.groupAdmin)
      ..writeByte(9)..write(obj.groupDescription)
      ..writeByte(10)..write(obj.groupAvatar)
      ..writeByte(11)..write(obj.isFavorite)
      ..writeByte(12)..write(obj.isBlocked)
      ..writeByte(13)..write(obj.notificationsMuted)
      ..writeByte(14)..write(obj.muteUntil)
      ..writeByte(15)..write(obj.customName)
      ..writeByte(16)..write(obj.statusMessage)
      ..writeByte(17)..write(obj.avatarUrl)
      ..writeByte(18)..write(obj.wallpaper);
  }
}

// Для генерации: flutter packages pub run build_runner build