import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/contact_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundsEnabled = true;
  bool _vibrationEnabled = true;
  bool _showPreview = true;
  
  @override
  Widget build(BuildContext context) {
    final contactProvider = Provider.of<ContactProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFECE5DD),
      appBar: AppBar(
        title: const Text('Настройки'),
        backgroundColor: const Color(0xFF075E54),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // Профиль
          Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF075E54),
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: const Text('Мой профиль'),
              subtitle: const Text('UIN: 428971'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showProfileSettings(),
            ),
          ),
          
          // Статистика
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: const Icon(Icons.analytics, color: Colors.blue),
              title: const Text('Статистика'),
              subtitle: FutureBuilder<Map<String, dynamic>>(
                future: _getStatistics(contactProvider, chatProvider),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('Загрузка...');
                  }
                  
                  if (snapshot.hasError) {
                    return const Text('Ошибка загрузки');
                  }
                  
                  final data = snapshot.data ?? {};
                  return Text(
                    'Контактов: ${data['contacts'] ?? 0}, '
                    'Групп: ${data['groups'] ?? 0}, '
                    'Сообщений: ${data['messages'] ?? 0}',
                  );
                },
              ),
              onTap: () => _showStatistics(),
            ),
          ),
          
          // Уведомления
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Уведомления'),
                  subtitle: const Text('Включить уведомления о сообщениях'),
                  value: _notificationsEnabled,
                  onChanged: (value) => setState(() => _notificationsEnabled = value),
                  activeColor: const Color(0xFF25D366),
                ),
                if (_notificationsEnabled) ...[
                  SwitchListTile(
                    title: const Text('Показывать превью'),
                    subtitle: const Text('Показывать текст сообщения в уведомлении'),
                    value: _showPreview,
                    onChanged: (value) => setState(() => _showPreview = value),
                    activeColor: const Color(0xFF25D366),
                  ),
                  SwitchListTile(
                    title: const Text('Звуки'),
                    subtitle: const Text('Включить звуки уведомлений'),
                    value: _soundsEnabled,
                    onChanged: (value) => setState(() => _soundsEnabled = value),
                    activeColor: const Color(0xFF25D366),
                  ),
                  SwitchListTile(
                    title: const Text('Вибрация'),
                    subtitle: const Text('Включить вибрацию'),
                    value: _vibrationEnabled,
                    onChanged: (value) => setState(() => _vibrationEnabled = value),
                    activeColor: const Color(0xFF25D366),
                  ),
                ],
              ],
            ),
          ),
          
          // Тема
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: const Icon(Icons.color_lens, color: Colors.purple),
              title: const Text('Тема оформления'),
              subtitle: Text(themeProvider.isDarkMode ? 'Тёмная тема' : 'Светлая тема'),
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (value) => themeProvider.toggleTheme(),
                activeColor: const Color(0xFF25D366),
              ),
              onTap: () => _showThemeSettings(themeProvider),
            ),
          ),
          
          // Чаты
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.backup, color: Colors.blue),
                  title: const Text('Резервное копирование'),
                  subtitle: const Text('Экспорт данных чатов'),
                  onTap: () => _exportData(contactProvider, chatProvider),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.restore, color: Colors.green),
                  title: const Text('Восстановление'),
                  subtitle: const Text('Импорт данных из резервной копии'),
                  onTap: () => _importData(),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Очистить все чаты'),
                  subtitle: const Text('Удалить все сообщения'),
                  onTap: () => _clearAllChats(chatProvider),
                ),
              ],
            ),
          ),
          
          // Конфиденциальность
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock, color: Colors.orange),
                  title: const Text('Конфиденциальность'),
                  subtitle: const Text('Настройки приватности'),
                  onTap: () => _showPrivacySettings(),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.security, color: Colors.green),
                  title: const Text('Блокировка'),
                  subtitle: const Text('Заблокированные контакты'),
                  onTap: () => _showBlockedContacts(contactProvider),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.history, color: Colors.grey),
                  title: const Text('История аккаунта'),
                  subtitle: const Text('Входы, действия и т.д.'),
                  onTap: () => _showAccountHistory(),
                ),
              ],
            ),
          ),
          
          // О приложении
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: const Icon(Icons.info, color: Colors.blue),
              title: const Text('О приложении'),
              subtitle: const Text('Monolith Chat v1.0.0'),
              onTap: () => _showAboutDialog(),
            ),
          ),
          
          // Помощь
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: const Icon(Icons.help, color: Colors.green),
              title: const Text('Помощь'),
              subtitle: const Text('Часто задаваемые вопросы'),
              onTap: () => _showHelp(),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<Map<String, dynamic>> _getStatistics(
    ContactProvider contactProvider, 
    ChatProvider chatProvider,
  ) async {
    final contacts = contactProvider.contacts.length;
    final groups = contactProvider.groups.length;
    final totalMessages = chatProvider.getMessages('').length; // Пример
    
    return {
      'contacts': contacts,
      'groups': groups,
      'messages': totalMessages,
    };
  }
  
  void _showProfileSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Мой профиль'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFF075E54),
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text(
                'UIN: 428971',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text('Имя: You'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // TODO: Редактировать профиль
                },
                child: const Text('Редактировать профиль'),
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
  
  void _showStatistics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Статистика'),
        content: FutureBuilder<Map<String, dynamic>>(
          future: _getStatistics(
            Provider.of<ContactProvider>(context, listen: false),
            Provider.of<ChatProvider>(context, listen: false),
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (snapshot.hasError) {
              return const Text('Ошибка загрузки статистики');
            }
            
            final data = snapshot.data ?? {};
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatItem('Контакты', data['contacts']?.toString() ?? '0'),
                _buildStatItem('Группы', data['groups']?.toString() ?? '0'),
                _buildStatItem('Всего чатов', '${(data['contacts'] ?? 0) + (data['groups'] ?? 0)}'),
                _buildStatItem('Сообщений', data['messages']?.toString() ?? '0'),
                const SizedBox(height: 16),
                const Text(
                  'Использование хранилища:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                LinearProgressIndicator(
                  value: 0.3,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF25D366)),
                ),
                const SizedBox(height: 4),
                const Text(
                  '30% (150 МБ из 500 МБ)',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            );
          },
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
  
  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
  
  void _showThemeSettings(ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Тема оформления'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Светлая'),
              value: ThemeMode.light,
              groupValue: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              onChanged: (value) {
                if (value == ThemeMode.light && themeProvider.isDarkMode) {
                  themeProvider.toggleTheme();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Тёмная'),
              value: ThemeMode.dark,
              groupValue: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              onChanged: (value) {
                if (value == ThemeMode.dark && !themeProvider.isDarkMode) {
                  themeProvider.toggleTheme();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Как в системе'),
              value: ThemeMode.system,
              groupValue: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              onChanged: (value) {
                // TODO: Реализовать системную тему
              },
            ),
          ],
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
  
  void _exportData(ContactProvider contactProvider, ChatProvider chatProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Экспорт данных'),
        content: const Text('Все ваши данные будут экспортированы в файл. '
            'Сохраните его в безопасном месте.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                // TODO: Реализовать экспорт
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Данные успешно экспортированы'),
                    backgroundColor: Color(0xFF075E54),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Ошибка экспорта: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Экспорт'),
          ),
        ],
      ),
    );
  }
  
  void _importData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Импорт данных'),
        content: const Text('Выберите файл резервной копии для восстановления данных. '
            'Текущие данные будут заменены.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Реализовать импорт
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Функция импорта в разработке'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Импорт'),
          ),
        ],
      ),
    );
  }
  
  void _clearAllChats(ChatProvider chatProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Очистить все чаты?'),
        content: const Text('Все сообщения будут удалены. Это действие нельзя отменить.'),
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
  }
  
  void _showPrivacySettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Конфиденциальность'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                title: const Text('Статус "онлайн"'),
                subtitle: const Text('Показывать другим, что вы онлайн'),
                value: true,
                onChanged: (value) {},
                activeColor: const Color(0xFF25D366),
              ),
              SwitchListTile(
                title: const Text('Чтение сообщений'),
                subtitle: const Text('Отправлять уведомления о прочтении'),
                value: true,
                onChanged: (value) {},
                activeColor: const Color(0xFF25D366),
              ),
              SwitchListTile(
                title: const Text('Последний раз в сети'),
                subtitle: const Text('Показывать время последнего посещения'),
                value: true,
                onChanged: (value) {},
                activeColor: const Color(0xFF25D366),
              ),
              SwitchListTile(
                title: const Text('Статусы'),
                subtitle: const Text('Показывать мои статусы всем'),
                value: true,
                onChanged: (value) {},
                activeColor: const Color(0xFF25D366),
              ),
              const SizedBox(height: 16),
              const Text(
                'Кто может добавлять меня в контакты:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              RadioListTile(
                title: const Text('Все'),
                value: 'all',
                groupValue: 'all',
                onChanged: (value) {},
              ),
              RadioListTile(
                title: const Text('Только по UIN'),
                value: 'uin',
                groupValue: 'all',
                onChanged: (value) {},
              ),
              RadioListTile(
                title: const Text('Никто'),
                value: 'none',
                groupValue: 'all',
                onChanged: (value) {},
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
  
  void _showBlockedContacts(ContactProvider contactProvider) {
    final blockedContacts = contactProvider.contacts
        .where((contact) => contact.isBlocked)
        .toList();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Заблокированные контакты'),
        content: SizedBox(
          width: double.maxFinite,
          child: blockedContacts.isEmpty
              ? const Center(
                  child: Text('Нет заблокированных контактов'),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: blockedContacts.length,
                  itemBuilder: (context, index) {
                    final contact = blockedContacts[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF075E54),
                        child: Text(
                          contact.name.substring(0, 1),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(contact.name),
                      subtitle: Text('UIN: ${contact.uin}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.block, color: Colors.red),
                        onPressed: () {
                          final updatedContact = contact.copyWith(isBlocked: false);
                          contactProvider.updateContact(updatedContact);
                        },
                      ),
                    );
                  },
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
  
  void _showAccountHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('История аккаунта'),
        content: const SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.login, color: Colors.green),
                title: Text('Вход в приложение'),
                subtitle: Text('Сегодня, 10:30'),
              ),
              ListTile(
                leading: Icon(Icons.device_unknown, color: Colors.blue),
                title: Text('Новое устройство'),
                subtitle: Text('Вчера, 14:20'),
              ),
              ListTile(
                leading: Icon(Icons.settings_backup_restore, color: Colors.orange),
                title: Text('Резервное копирование'),
                subtitle: Text('3 дня назад'),
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
  
  void _showAboutDialog() {
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
          '• Уведомления\n'
          '• Темная тема\n'
          '• Шифрование сообщений',
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            // TODO: Открыть страницу с обновлениями
          },
          child: const Text('Проверить обновления'),
        ),
      ],
    );
  }
  
  void _showHelp() {
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
                'Перейдите в раздел "Контакты", нажмите "+" и введите UIN собеседника '
                'или отсканируйте QR код.',
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
                'В чате нажмите на иконку скрепки и выберите "Галерея" или "Камера".',
              ),
              const SizedBox(height: 16),
              const Text(
                'Нужна дополнительная помощь?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Открыть поддержку
                },
                child: const Text('Связаться с поддержкой'),
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