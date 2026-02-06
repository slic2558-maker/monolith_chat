import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import '../providers/contact_provider.dart';
import '../providers/chat_provider.dart';
import 'chat_screen.dart';
import 'create_group_screen.dart';
import 'new_chat_screen.dart';
import '../models/contact.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final myUIN = '428971';

    return Scaffold(
      backgroundColor: const Color(0xFFECE5DD),
      appBar: AppBar(
        title: const Text('Monolith Chat'),
        backgroundColor: const Color(0xFF075E54),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'new_chat',
            mini: true,
            backgroundColor: const Color(0xFF25D366),
            foregroundColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewChatScreen()),
              );
            },
            child: const Icon(Icons.chat),
          ),
          const SizedBox(height: 16),
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
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Ваш цифровой идентификатор (UIN)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Text(
                myUIN,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF075E54),
                  letterSpacing: 4,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            const Text(
              'Сообщите этот код собеседнику',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF128C7E), width: 2),
              ),
              child: Column(
                children: [
                  QrImageView(
                    data: myUIN,
                    version: QrVersions.auto,
                    size: 200,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'UIN: $myUIN',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Отсканируйте этот код',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            ElevatedButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: myUIN));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('UIN скопирован в буфер обмена'),
                    backgroundColor: Color(0xFF075E54),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Скопировать UIN'),
            ),
            const SizedBox(height: 40),
            
            Consumer2<ContactProvider, ChatProvider>(
  builder: (context, contactProvider, chatProvider, _) {
    // Получаем все ID чатов, которые есть в ChatProvider
    final chatIds = chatProvider.chats.keys.toList();
    
    if (chatIds.isEmpty) {
      return Column(
        children: [
          Icon(
            Icons.message,
            size: 64,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Нет активных чатов\nДобавьте контакт или создайте группу',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      );
    }
    
    // Для каждого чата получаем информацию о контакте
    final chatsToDisplay = chatIds.map((chatId) {
      final contact = contactProvider.getChat(chatId);
      final messages = chatProvider.getMessages(chatId);
      
      // Если контакт удален, но история есть - создаем временный контакт
      if (contact == null && messages.isNotEmpty) {
        return Contact(
          id: chatId,
          uin: chatId,
          name: 'Чат $chatId',
          isGroup: false,
        );
      }
      return contact;
    }).where((contact) => contact != null).cast<Contact>().toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'Чаты',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        ...chatsToDisplay.take(5).map((contact) {
          final lastMessage = chatProvider.getLastMessage((contact as Contact).id);
          
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: contact.isGroup 
                  ? const Color(0xFF128C7E)
                  : const Color(0xFF075E54),
              child: Icon(
                contact.isGroup ? Icons.group : Icons.person,
                color: Colors.white,
                size: contact.isGroup ? 20 : 24,
              ),
            ),
            title: Text(contact.name),
            subtitle: Text(
              lastMessage?.text ?? (contact.isGroup ? 'Групповой чат' : 'Нет сообщений'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(
              Icons.chat,
              color: Color(0xFF25D366),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(contact: contact),
                ),
              );
            },
          );
        }).toList(),
      ],
    );
  },
),
          ],
        ),
      ),
    );
  }
}