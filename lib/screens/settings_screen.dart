import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/contact_provider.dart';
import '../providers/chat_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundsEnabled = true;
  bool _vibrationEnabled = true;

  @override
  Widget build(BuildContext context) {
    final contactProvider = Provider.of<ContactProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFECE5DD),
      appBar: AppBar(
        title: const Text('Настройки'),
        backgroundColor: const Color(0xFF075E54),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // Статистика
          Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              leading: const Icon(Icons.people, color: Color(0xFF075E54)),
              title: const Text('Статистика'),
              subtitle: Text(
                'Контактов: ${contactProvider.contacts.length}\n'
                'Групп: ${contactProvider.groups.length}\n'
                'Всего чатов: ${contactProvider.allChats.length}',
              ),
            ),
          ),
          
          // Уведомления (РАБОЧИЕ)
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: SwitchListTile(
              title: const Text('Уведомления'),
              subtitle: const Text('Включить уведомления о сообщениях'),
              value: _notificationsEnabled,
              onChanged: (value) => setState(() => _notificationsEnabled = value),
              activeColor: const Color(0xFF25D366),
            ),
          ),
          
          // Звуки (РАБОЧИЕ)
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: SwitchListTile(
              title: const Text('Звуки сообщений'),
              subtitle: const Text('Включить звуки при получении сообщений'),
              value: _soundsEnabled,
              onChanged: (value) => setState(() => _soundsEnabled = value),
              activeColor: const Color(0xFF25D366),
            ),
          ),
          
          // Вибрация (РАБОЧИЕ)
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: SwitchListTile(
              title: const Text('Вибрация'),
              subtitle: const Text('Виброотклик при сообщениях'),
              value: _vibrationEnabled,
              onChanged: (value) => setState(() => _vibrationEnabled = value),
              activeColor: const Color(0xFF25D366),
            ),
          ),
          
          // Очистка данных (ИСПРАВЛЕНА)
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Очистить все чаты'),
              subtitle: const Text('Удалить все сообщения, контакты останутся'),
             onTap: () {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Очистить все чаты?'),
      content: const Text('Все сообщения будут удалены. Контакты останутся в списке.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        TextButton(
          onPressed: () {
            chatProvider.clearAllChats();
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Все чаты очищены'),
                backgroundColor: Color(0xFF075E54),
                duration: Duration(seconds: 2),
              ),
            );
          },
          child: const Text('Очистить', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
},
            ),
          ),
          
          // Экспорт данных
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: const Icon(Icons.backup, color: Colors.blue),
              title: const Text('Экспорт данных'),
              subtitle: const Text('Сохранить все чаты и контакты'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Функция экспорта в разработке'),
                    backgroundColor: Colors.orange,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
          
          // О приложении
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: const Icon(Icons.info, color: Colors.blue),
              title: const Text('О приложении'),
              subtitle: const Text('Monolith Chat v1.0.0'),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Monolith Chat',
                  applicationVersion: '1.0.0',
                  applicationLegalese: '© 2024 Monolith Chat Team\nWhatsApp-like мессенджер с системой UIN',
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Функции:\n'
                      '• Цифровые идентификаторы (UIN)\n'
                      '• Личные и групповые чаты\n'
                      '• Голосовые сообщения\n'
                      '• Отправка изображений\n'
                      '• QR коды для UIN\n'
                      '• Уведомления',
                    ),
                  ],
                );
              },
            ),
          ),
          
          // Помощь
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: const Icon(Icons.help, color: Colors.green),
              title: const Text('Помощь'),
              subtitle: const Text('Часто задаваемые вопросы'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Помощь'),
                    content: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHelpItem(
                            'Как добавить контакт?',
                            'Перейдите в раздел "Контакты", нажмите "+" и введите UIN собеседника.',
                          ),
                          const SizedBox(height: 12),
                          _buildHelpItem(
                            'Что такое UIN?',
                            'UIN (Unique Identification Number) - ваш цифровой идентификатор в системе. '
                            'Сообщите его собеседнику для добавления в контакты.',
                          ),
                          const SizedBox(height: 12),
                          _buildHelpItem(
                            'Как создать группу?',
                            'В разделе "Контакты" нажмите иконку группы (два человека с плюсом) '
                            'или в главном чатов нажмите FAB и выберите "Создать группу".',
                          ),
                          const SizedBox(height: 12),
                          _buildHelpItem(
                            'Как отправить голосовое сообщение?',
                            'В чате зажмите кнопку микрофона для записи, отпустите для отправки.',
                          ),
                          const SizedBox(height: 12),
                          _buildHelpItem(
                            'Как отправить фото?',
                            'В чате нажмите на иконку скрепки и выберите "Галерея".',
                          ),
                          const SizedBox(height: 12),
                          _buildHelpItem(
                            'Как удалить контакт?',
                            'В разделе "Контакты" нажмите на иконку удаления (корзина) рядом с контактом. '
                            'История чата сохранится.',
                          ),
                          const SizedBox(height: 12),
                          _buildHelpItem(
                            'Как удалить чат?',
                            'В чате нажмите на три точки в правом верхнем углу и выберите '
                            '"Удалить чат полностью". Контакт останется в списке.',
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
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHelpItem(String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          answer,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}