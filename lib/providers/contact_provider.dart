import 'package:flutter/material.dart';
import '../models/contact.dart';

class ContactProvider with ChangeNotifier {
  final List<Contact> _contacts = [];
  final List<Contact> _groups = [];

  List<Contact> get contacts => List.unmodifiable(_contacts);
  List<Contact> get groups => List.unmodifiable(_groups);
  List<Contact> get allChats => [..._groups, ..._contacts];

  void addContact(String uin, {String? name}) {
    if (_contacts.any((contact) => contact.uin == uin)) return;
    
    _contacts.add(Contact(
      uin: uin, 
      name: name ?? uin,  // если name не указан, используем uin
      isGroup: false,
    ));
    _contacts.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    notifyListeners();
  }

  // Удаление контакта БЕЗ удаления чата
  void removeContact(String uin) {
    _contacts.removeWhere((contact) => contact.uin == uin);
    notifyListeners();
    // Чат остаётся в ChatProvider
  }

  void createGroup(String name, {List<String>? memberUINs}) {
    final groupId = 'group_${DateTime.now().millisecondsSinceEpoch}';
    _groups.add(Contact.createGroup(id: groupId, name: name));
    notifyListeners();
  }

  void removeGroup(String groupId) {
    _groups.removeWhere((group) => group.id == groupId);
    notifyListeners();
  }

  Contact? getChat(String chatId) {
    // Сначала ищем в группах
    final group = _groups.firstWhere(
      (group) => group.id == chatId,
      orElse: () => Contact(
        uin: '', 
        name: 'Группа',  // добавить name
        isGroup: true,
      ),
    );
    if (group.uin.isNotEmpty) return group;
    
    // Потом ищем в контактах
    try {
      return _contacts.firstWhere((contact) => contact.uin == chatId);
    } catch (e) {
      return null; // Контакт не найден (возможно, удалён)
    }
  }

  void updateContactStatus(String uin, bool isOnline) {
    final index = _contacts.indexWhere((contact) => contact.uin == uin);
    if (index != -1) {
      final contact = _contacts[index];
      _contacts[index] = contact.copyWith(isOnline: isOnline);
      notifyListeners();
    }
  }
}