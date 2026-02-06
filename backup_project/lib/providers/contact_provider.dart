import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/contact.dart';
import '../providers/chat_provider.dart';

class ContactProvider with ChangeNotifier {
  List<Contact> _contacts = [];
  List<Contact> _groups = [];
  late Box<Contact> _contactsBox;
  
  ContactProvider() {
    _initStorage();
  }
  
  Future<void> _initStorage() async {
    _contactsBox = await Hive.openBox<Contact>('contacts');
    await _loadContactsFromStorage();
  }
  
  Future<void> _loadContactsFromStorage() async {
    final allContacts = _contactsBox.values.toList();
    
    _contacts = allContacts.where((c) => !c.isGroup).toList();
    _groups = allContacts.where((c) => c.isGroup).toList();
    
    _sortContacts();
    notifyListeners();
  }
  
  List<Contact> get contacts => List.unmodifiable(_contacts);
  List<Contact> get groups => List.unmodifiable(_groups);
  List<Contact> get allChats => [..._groups, ..._contacts];
  
  void _sortContacts() {
    _contacts.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    _groups.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
  }
  
  Future<void> addContact(String uin, {String? name, String? customName}) async {
    // Проверка на дубликаты
    if (_contacts.any((contact) => contact.uin == uin)) {
      throw Exception('Контакт уже существует');
    }
    
    final contact = Contact(
      uin: uin,
      name: name ?? uin,
      customName: customName,
      dateAdded: DateTime.now(),
      lastSeen: DateTime.now(),
    );
    
    _contacts.add(contact);
    await _contactsBox.put(contact.id, contact);
    
    _sortContacts();
    notifyListeners();
  }
  
  // Удаление контакта с синхронизацией с ChatProvider
  Future<void> removeContact(String uin, BuildContext context) async {
    final contactIndex = _contacts.indexWhere((contact) => contact.uin == uin);
    if (contactIndex == -1) return;
    
    final contact = _contacts[contactIndex];
    
    // Удаляем из хранилища
    await _contactsBox.delete(contact.id);
    
    // Удаляем из локального списка
    _contacts.removeAt(contactIndex);
    
    // Удаляем чат (синхронизация с ChatProvider)
    final chatProvider = context.read<ChatProvider>();
    await chatProvider.deleteChat(contact.id);
    
    notifyListeners();
  }
  
  Future<void> createGroup(String name, {List<String>? memberUINs}) async {
    final groupId = 'group_${DateTime.now().millisecondsSinceEpoch}';
    final group = Contact.createGroup(
      name: name,
      members: memberUINs ?? [],
    );
    
    _groups.add(group);
    await _contactsBox.put(group.id, group);
    
    _sortContacts();
    notifyListeners();
  }
  
  Future<void> removeGroup(String groupId, BuildContext context) async {
    final groupIndex = _groups.indexWhere((group) => group.id == groupId);
    if (groupIndex == -1) return;
    
    final group = _groups[groupIndex];
    
    // Удаляем из хранилища
    await _contactsBox.delete(group.id);
    
    // Удаляем из локального списка
    _groups.removeAt(groupIndex);
    
    // Удаляем чат
    final chatProvider = context.read<ChatProvider>();
    await chatProvider.deleteChat(group.id);
    
    notifyListeners();
  }
  
  Contact? getChat(String chatId) {
    // Сначала ищем в группах
    final group = _groups.firstWhere(
      (group) => group.id == chatId,
      orElse: () => Contact(uin: '', name: '', isGroup: true),
    );
    if (group.uin.isNotEmpty) return group;
    
    // Затем в контактах
    try {
      return _contacts.firstWhere((contact) => contact.uin == chatId);
    } catch (e) {
      return null;
    }
  }
  
  Future<void> updateContactStatus(String uin, bool isOnline) async {
    final index = _contacts.indexWhere((contact) => contact.uin == uin);
    if (index != -1) {
      final contact = _contacts[index];
      final updatedContact = contact.copyWith(
        isOnline: isOnline,
        lastSeen: DateTime.now(),
      );
      
      _contacts[index] = updatedContact;
      await _contactsBox.put(updatedContact.id, updatedContact);
      notifyListeners();
    }
  }
  
  Future<void> toggleFavorite(String uin) async {
    final index = _contacts.indexWhere((contact) => contact.uin == uin);
    if (index != -1) {
      final contact = _contacts[index];
      final updatedContact = contact.copyWith(isFavorite: !contact.isFavorite);
      
      _contacts[index] = updatedContact;
      await _contactsBox.put(updatedContact.id, updatedContact);
      notifyListeners();
    }
  }
  
  Future<void> toggleMute(String uin, {Duration? duration}) async {
    final contact = getChat(uin);
    if (contact == null) return;
    
    final updatedContact = contact.copyWith(
      notificationsMuted: !contact.notificationsMuted,
      muteUntil: duration != null ? DateTime.now().add(duration) : null,
    );
    
    await updateContact(updatedContact);
  }
  
  Future<void> updateContact(Contact contact) async {
    await _contactsBox.put(contact.id, contact);
    
    // Обновляем в локальном списке
    if (contact.isGroup) {
      final index = _groups.indexWhere((g) => g.id == contact.id);
      if (index != -1) {
        _groups[index] = contact;
      }
    } else {
      final index = _contacts.indexWhere((c) => c.id == contact.id);
      if (index != -1) {
        _contacts[index] = contact;
      }
    }
    
    _sortContacts();
    notifyListeners();
  }
  
  // Поиск контактов
  List<Contact> searchContacts(String query) {
    if (query.isEmpty) return allChats;
    
    final lowercaseQuery = query.toLowerCase();
    return allChats.where((contact) {
      return contact.displayName.toLowerCase().contains(lowercaseQuery) ||
             contact.uin.contains(lowercaseQuery);
    }).toList();
  }
  
  // Получить избранные контакты
  List<Contact> getFavoriteContacts() {
    return _contacts.where((contact) => contact.isFavorite).toList();
  }
  
  // Экспорт контактов
  Future<String> exportContacts() async {
    final contactsJson = _contacts.map((c) => c.toJson()).toList();
    final groupsJson = _groups.map((g) => g.toJson()).toList();
    
    return {
      'contacts': contactsJson,
      'groups': groupsJson,
      'exportedAt': DateTime.now().toIso8601String(),
    }.toString();
  }
  
  // Импорт контактов
  Future<void> importContacts(String jsonData) async {
    // TODO: Реализовать импорт из JSON
    // Для простоты просто обновляем из хранилища
    await _loadContactsFromStorage();
  }
  
  @override
  void dispose() {
    _contactsBox.close();
    super.dispose();
  }
}