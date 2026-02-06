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
  final List<String> _selectedMembers = [];

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
            onPressed: () {
              if (_nameController.text.isNotEmpty) {
                contactProvider.createGroup(
                  _nameController.text,
                  memberUINs: _selectedMembers,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Группа создана'),
                    backgroundColor: Color(0xFF075E54),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Название группы',
                hintText: 'Введите название группы',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const Divider(height: 1),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Выберите участников',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: contacts.isEmpty
                ? const Center(
                    child: Text('Нет контактов для добавления'),
                  )
                : ListView.builder(
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      final isSelected = _selectedMembers.contains(contact.uin);
                      
                      return CheckboxListTile(
                        title: Text(contact.name),
                        subtitle: Text('UIN: ${contact.uin}'),
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _selectedMembers.add(contact.uin);
                            } else {
                              _selectedMembers.remove(contact.uin);
                            }
                          });
                        },
                        secondary: CircleAvatar(
                          backgroundColor: const Color(0xFF075E54),
                          child: Text(
                            contact.uin.substring(0, 1),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}