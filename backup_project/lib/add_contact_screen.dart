import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/contact_provider.dart';

class AddContactScreen extends StatefulWidget {
  const AddContactScreen({super.key});

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final TextEditingController _uinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить контакт'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Введите UIN собеседника',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _uinController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'UIN (6 цифр)',
                hintText: 'Например: 222522',
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                final enteredUIN = _uinController.text;
                if (enteredUIN.length == 6) {
                  // Получаем провайдер и добавляем контакт
                  final contactProvider =
                      Provider.of<ContactProvider>(context, listen: false);
                  contactProvider.addContact(enteredUIN);

                  // Показываем уведомление об успехе
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Контакт $enteredUIN добавлен'),
                      duration: const Duration(seconds: 1),
                    ),
                  );

                  // Закрываем экран
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('UIN должен содержать 6 цифр'),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Добавить в контакты'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}