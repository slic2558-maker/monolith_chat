import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/contact_provider.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<String> _selectedMembers = [];
  final List<String> _searchResults = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      if (_searchQuery.isNotEmpty) {
        _updateSearchResults();
      } else {
        _searchResults.clear();
      }
    });
  }
  
  void _updateSearchResults() {
    final contactProvider = Provider.of<ContactProvider>(context, listen: false);
    final allContacts = contactProvider.contacts;
    
    _searchResults.clear();
    _searchResults.addAll(
      allContacts
          .where((contact) =>
              contact.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              contact.uin.contains(_searchQuery))
          .map((contact) => contact.uin)
          .toList(),
    );
  }
  
  void _toggleMemberSelection(String uin) {
    setState(() {
      if (_selectedMembers.contains(uin)) {
        _selectedMembers.remove(uin);
      } else {
        _selectedMembers.add(uin);
      }
    });
  }
  
  Future<void> _createGroup() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Введите название группы'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_selectedMembers.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Выберите хотя бы 2 участника'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    try {
      final contactProvider = Provider.of<ContactProvider>(context, listen: false);
      await contactProvider.createGroup(
        name,
        memberUINs: _selectedMembers,
      );
      
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Группа "$name" создана'),
          backgroundColor: const Color(0xFF075E54),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Widget _buildSelectedMembers() {
    if (_selectedMembers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Выберите участников группы',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              'Участники:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedMembers.map((uin) {
              final contactProvider = Provider.of<ContactProvider>(context, listen: false);
              final contact = contactProvider.getChat(uin);
              final name = contact?.name ?? uin;
              
              return Chip(
                label: Text(name),
                avatar: CircleAvatar(
                  backgroundColor: const Color(0xFF075E54),
                  child: Text(
                    name.substring(0, 1),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => _toggleMemberSelection(uin),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contactProvider = Provider.of<ContactProvider>(context);
    final contacts = contactProvider.contacts;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создать группу'),
        backgroundColor: const Color(0xFF075E54),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _createGroup,
          ),
        ],
      ),
      body: Column(
        children: [
          // Информация о группе
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Название группы *',
                    hintText: 'Введите название группы',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 100,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Описание (необязательно)',
                    hintText: 'Введите описание группы',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  maxLength: 500,
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Поиск участников
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Выберите участников',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
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
                ),
              ],
            ),
          ),
          
          // Выбранные участники
          _buildSelectedMembers(),
          
          const Divider(height: 1),
          
          // Список контактов
          Expanded(
            child: _searchQuery.isNotEmpty && _searchResults.isEmpty
                ? const Center(
                    child: Text(
                      'Контакты не найдены',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _searchQuery.isNotEmpty 
                        ? _searchResults.length 
                        : contacts.length,
                    itemBuilder: (context, index) {
                      final contact = _searchQuery.isNotEmpty
                          ? contactProvider.getChat(_searchResults[index])
                          : contacts[index];
                      
                      if (contact == null) return const SizedBox();
                      
                      final isSelected = _selectedMembers.contains(contact.uin);
                      
                      return CheckboxListTile(
                        title: Text(contact.name),
                        subtitle: Text('UIN: ${contact.uin}'),
                        value: isSelected,
                        onChanged: (bool? value) {
                          _toggleMemberSelection(contact.uin);
                        },
                        secondary: CircleAvatar(
                          backgroundColor: const Color(0xFF075E54),
                          child: Text(
                            contact.name.substring(0, 1),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}