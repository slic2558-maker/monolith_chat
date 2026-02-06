import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import '../providers/contact_provider.dart';
import 'chat_screen.dart';
import 'create_group_screen.dart';
import 'new_chat_screen.dart';
import 'contacts_screen.dart';
import 'settings_screen.dart';

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
            
            Consumer<ContactProvider>(
              builder: (context, contactProvider, _) {
                final allChats = contactProvider.allChats;
                
                if (allChats.isEmpty) {
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
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ContactsScreen(),
                                ),
                              );
                            },
                            child: const Text('Добавить контакт'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CreateGroupScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF128C7E),
                            ),
                            child: const Text('Создать группу'),
                          ),
                        ],
                      ),
                    ],
                  );
                }
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Недавние чаты',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    ...allChats.take(5).map((chat) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: chat.isGroup 
                                ? const Color(0xFF128C7E)
                                : const Color(0xFF075E54),
                            child: Icon(
                              chat.isGroup ? Icons.group : Icons.person,
                              color: Colors.white,
                              size: chat.isGroup ? 20 : 24,
                            ),
                          ),
                          title: Text(chat.name),
                          subtitle: Text(
                            chat.isGroup ? 'Групповой чат' : 'Был(а) недавно',
                          ),
                          trailing: const Icon(
                            Icons.chat,
                            color: Color(0xFF25D366),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(contact: chat),
                              ),
                            );
                          },
                          onLongPress: () => _showChatOptions(context, chat),
                        ),
                      );
                    }).toList(),
                    
                    if (allChats.length > 5)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Center(
                          child: TextButton(
                            onPressed: () {
                              // TODO: Переход ко всем чатам
                            },
                            child: const Text('Показать все чаты'),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ContactsScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          }
        },
        backgroundColor: const Color(0xFF075E54),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Чаты',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: 'Контакты',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Настройки',
          ),
        ],
      ),
    );
  }
  
  void _showChatOptions(BuildContext context, Contact chat) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.archive, color: Colors.blue),
              title: const Text('Архивировать чат'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Архивировать чат
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_off, color: Colors.orange),
              title: const Text('Отключить уведомления'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Отключить уведомления
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Удалить чат'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteChatDialog(context, chat);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _showDeleteChatDialog(BuildContext context, Contact chat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить чат?'),
        content: Text('Чат с ${chat.name} будет удален. Сообщения останутся в архиве.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Удалить чат
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Чат с ${chat.name} удален')),
              );
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}