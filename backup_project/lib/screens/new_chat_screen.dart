import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/contact_provider.dart';
import 'chat_screen.dart';
import 'add_contact_screen.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        title: const Text('Новый чат'),
        backgroundColor: const Color(0xFF075E54),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск контактов...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
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
                            ? 'Нет контактов\nДобавьте контакт в разделе "Контакты"'
                            : 'Контакты не найдены',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        if (_searchQuery.isEmpty) ...[
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddContactScreen(),
                                ),
                              );
                            },
                            child: const Text('Добавить контакт'),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredContacts.length,
                    itemBuilder: (context, index) {
                      final contact = filteredContacts[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF075E54),
                          child: Text(
                            contact.name.substring(0, 1),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(contact.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('UIN: ${contact.uin}'),
                            if (contact.isOnline)
                              const Text(
                                'онлайн',
                                style: TextStyle(color: Colors.green, fontSize: 12),
                              ),
                          ],
                        ),
                        trailing: contact.isBlocked
                            ? const Icon(Icons.block, color: Colors.red, size: 16)
                            : null,
                        onTap: () {
                          if (contact.isBlocked) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Этот контакт заблокирован'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(contact: contact),
                            ),
                          );
                        },
                        onLongPress: () => _showContactOptions(context, contact),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
  
  void _showContactOptions(BuildContext context, Contact contact) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info, color: Colors.blue),
              title: const Text('Информация'),
              onTap: () {
                Navigator.pop(context);
                _showContactInfo(context, contact);
              },
            ),
            ListTile(
              leading: Icon(
                contact.isFavorite ? Icons.star : Icons.star_border,
                color: Colors.orange,
              ),
              title: Text(contact.isFavorite ? 'Убрать из избранного' : 'В избранное'),
              onTap: () {
                Navigator.pop(context);
                Provider.of<ContactProvider>(context, listen: false)
                  .toggleFavorite(contact.uin);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      contact.isFavorite
                        ? 'Убрано из избранного'
                        : 'Добавлено в избранное',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(
                contact.isBlocked ? Icons.check_circle : Icons.block,
                color: contact.isBlocked ? Colors.green : Colors.red,
              ),
              title: Text(contact.isBlocked ? 'Разблокировать' : 'Заблокировать'),
              onTap: () {
                Navigator.pop(context);
                _toggleBlockContact(context, contact);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _toggleBlockContact(BuildContext context, Contact contact) {
    final provider = Provider.of<ContactProvider>(context, listen: false);
    final updatedContact = contact.copyWith(isBlocked: !contact.isBlocked);
    provider.updateContact(updatedContact);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          contact.isBlocked
            ? 'Контакт разблокирован'
            : 'Контакт заблокирован',
        ),
      ),
    );
  }
  
  void _showContactInfo(BuildContext context, Contact contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Информация о контакте'),
        content: SingleChildScrollView(
          child: Column(
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
              _buildInfoRow('Статус:', contact.isOnline ? 'онлайн' : 'оффлайн'),
              if (!contact.isOnline && contact.lastSeen != null)
                _buildInfoRow('Был(а) в сети:', contact.lastSeenFormatted),
              if (contact.dateAdded != null)
                _buildInfoRow('Добавлен:', 
                  '${contact.dateAdded.day}.${contact.dateAdded.month}.${contact.dateAdded.year}'),
              if (contact.isBlocked)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    '⚠️ Этот контакт заблокирован',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
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
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}