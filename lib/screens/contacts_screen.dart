import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/contact.dart';
import '../providers/contact_provider.dart';
import 'chat_screen.dart';
import 'create_group_screen.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _uinController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String _searchQuery = '';
  bool _showQRScanner = false;

  @override
  void initState() {
    super.initState();
    _showQRScanner = false;
  }

  @override
  Widget build(BuildContext context) {
    final contactProvider = Provider.of<ContactProvider>(context);
    final contacts = contactProvider.contacts;
    
    final filteredContacts = _searchQuery.isEmpty
        ? contacts
        : contacts.where((contact) {
            return contact.name.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Контакты'),
        backgroundColor: const Color(0xFF075E54),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'add_group',
            mini: true,
            backgroundColor: const Color(0xFF128C7E),
            foregroundColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateGroupScreen()),
              );
            },
            child: const Icon(Icons.group_add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'add_contact',
            backgroundColor: const Color(0xFF25D366),
            foregroundColor: Colors.white,
            onPressed: () {
              if (_showQRScanner) {
                setState(() => _showQRScanner = false);
              }
              _showAddContactDialog();
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
      body: _showQRScanner ? _buildQRScanner() : _buildContactsList(contactProvider, filteredContacts),
    );
  }

  Widget _buildQRScanner() {
    return Column(
      children: [
        AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() => _showQRScanner = false),
          ),
          title: const Text('Сканировать QR код'),
          backgroundColor: const Color(0xFF075E54),
          foregroundColor: Colors.white,
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF25D366), width: 3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(Icons.qr_code_scanner, size: 100, color: Color(0xFF25D366)),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Наведите камеру на QR код',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Симуляция сканирования QR кода
                    _uinController.text = '123456';
                    setState(() => _showQRScanner = false);
                    _showAddContactDialog();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Симуляция сканирования'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactsList(ContactProvider contactProvider, List<Contact> filteredContacts) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Поиск по имени...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        
        Expanded(
          child: filteredContacts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty
                            ? 'Список контактов пуст\nДобавьте контакт по UIN'
                            : 'Контакты не найдены',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: filteredContacts.length,
                  itemBuilder: (context, index) {
                    final contact = filteredContacts[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF075E54),
                          child: Text(
                            contact.name.substring(0, 1),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(contact.name),
                        subtitle: const Text('Нажмите для информации'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chat, color: Colors.blue),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(contact: contact),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _showDeleteDialog(context, contactProvider, contact),
                            ),
                          ],
                        ),
                        onTap: () => _showContactInfo(context, contact),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showAddContactDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить контакт'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      icon: const Icon(Icons.qr_code_scanner, color: Color(0xFF25D366)),
                      label: const Text('Сканировать QR'),
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() => _showQRScanner = true);
                      },
                    ),
                  ),
                ],
              ),
              const Divider(),
              TextField(
                controller: _uinController,
                decoration: const InputDecoration(
                  labelText: 'UIN контакта',
                  hintText: 'Введите UIN собеседника',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Имя (необязательно)',
                  hintText: 'Введите имя контакта',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _uinController.clear();
              _nameController.clear();
              Navigator.pop(context);
            },
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              final uin = _uinController.text.trim();
              final name = _nameController.text.trim();
              if (uin.isNotEmpty) {
                Provider.of<ContactProvider>(context, listen: false)
                  .addContact(uin, name: name.isNotEmpty ? name : null);
                _uinController.clear();
                _nameController.clear();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(name.isNotEmpty 
                      ? 'Контакт $name добавлен' 
                      : 'Контакт $uin добавлен'),
                    backgroundColor: const Color(0xFF075E54),
                  ),
                );
              }
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  void _showContactInfo(BuildContext context, Contact contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Информация о контакте'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                backgroundColor: const Color(0xFF075E54),
                radius: 40,
                child: Text(
                  contact.name.substring(0, 1),
                  style: const TextStyle(fontSize: 32, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Имя:', contact.name),
            _buildInfoRow('UIN:', contact.uin),
            _buildInfoRow('Добавлен:', 
              '${contact.dateAdded.day}.${contact.dateAdded.month}.${contact.dateAdded.year}'),
            _buildInfoRow('Статус:', contact.isOnline ? 'онлайн' : 'оффлайн'),
          ],
        ),
        actions: [
  TextButton(
    onPressed: () => Navigator.pop(context),
    child: const Text('Закрыть'),
  ),
  TextButton(
    onPressed: () {
      // Удаляем только контакт из ContactProvider
      Provider.of<ContactProvider>(context, listen: false)
        .removeContact(contact.uin);
      Navigator.pop(context); // Закрыть диалог
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Контакт "${contact.name}" удалён из списка (чат сохранён)'),
          backgroundColor: const Color(0xFF075E54),
          duration: const Duration(seconds: 2),
        ),
      );
    },
    child: const Text('Удалить контакт', style: TextStyle(color: Colors.red)),
  ),
  TextButton(
    onPressed: () {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(contact: contact),
        ),
      );
    },
    child: const Text('Написать', style: TextStyle(color: Color(0xFF25D366))),
  ),
],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

 void _showDeleteDialog(BuildContext context, ContactProvider provider, Contact contact) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Удалить контакт?'),
      content: const Text('Контакт будет удалён из списка. История чата сохранится.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        TextButton(
          onPressed: () {
            // Только удаляем контакт из ContactProvider
            provider.removeContact(contact.uin);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Контакт "${contact.name}" удалён из списка'),
                backgroundColor: const Color(0xFF075E54),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          child: const Text('Удалить', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

  @override
  void dispose() {
    _searchController.dispose();
    _uinController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}