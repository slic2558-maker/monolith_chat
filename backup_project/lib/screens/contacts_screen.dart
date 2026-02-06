import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/contact.dart';
import '../providers/contact_provider.dart';
import 'chat_screen.dart';
import 'add_contact_screen.dart';
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
  MobileScannerController? _qrController;
  
  @override
  void initState() {
    super.initState();
    _showQRScanner = false;
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _uinController.dispose();
    _nameController.dispose();
    _qrController?.dispose();
    super.dispose();
  }
  
  void _startQRScanner() {
    setState(() {
      _showQRScanner = true;
      _qrController = MobileScannerController(
        formats: [BarcodeFormat.qrCode],
        autoStart: true,
      );
    });
  }
  
  void _stopQRScanner() {
    setState(() {
      _showQRScanner = false;
      _qrController?.stop();
      _qrController?.dispose();
      _qrController = null;
    });
  }
  
  void _onQRCodeDetected(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    
    if (barcodes.isNotEmpty) {
      final String qrData = barcodes.first.rawValue ?? '';
      
      // Обработка QR кода
      _processQRData(qrData);
      
      // Остановить сканирование после успешного распознавания
      _stopQRScanner();
    }
  }
  
  void _processQRData(String qrData) {
    // Ожидаемый формат: "MONOLITH_CONTACT:UIN:NAME" или просто UIN
    final parts = qrData.split(':');
    
    if (parts.length >= 3 && parts[0] == 'MONOLITH_CONTACT') {
      final uin = parts[1];
      final name = parts[2];
      
      _uinController.text = uin;
      _nameController.text = name;
      
      _showAddContactDialog(prefilled: true);
    } else if (_isValidUIN(qrData)) {
      _uinController.text = qrData;
      _showAddContactDialog(prefilled: true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Неверный формат QR кода'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  bool _isValidUIN(String uin) {
    return uin.length == 6 && RegExp(r'^\d+$').hasMatch(uin);
  }

  @override
  Widget build(BuildContext context) {
    final contactProvider = Provider.of<ContactProvider>(context);
    final contacts = contactProvider.contacts;
    
    final filteredContacts = _searchQuery.isEmpty
        ? contacts
        : contacts.where((contact) {
            return contact.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                   contact.uin.contains(_searchQuery);
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Контакты'),
        backgroundColor: const Color(0xFF075E54),
        foregroundColor: Colors.white,
        actions: [
          if (_showQRScanner)
            IconButton(
              icon: const Icon(Icons.flash_on),
              onPressed: () {
                if (_qrController != null) {
                  _qrController!.toggleTorch();
                }
              },
            ),
        ],
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
                _stopQRScanner();
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
            onPressed: _stopQRScanner,
          ),
          title: const Text('Сканировать QR код'),
          backgroundColor: const Color(0xFF075E54),
          foregroundColor: Colors.white,
        ),
        Expanded(
          child: Stack(
            children: [
              MobileScanner(
                controller: _qrController,
                onDetect: _onQRCodeDetected,
              ),
              
              // Overlay с рамкой для сканирования
              Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF25D366), width: 3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              
              // Инструкция
              Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.black.withOpacity(0.7),
                  child: const Column(
                    children: [
                      Text(
                        'Наведите камеру на QR код контакта',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'QR код должен содержать UIN контакта',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Поиск по имени или UIN...',
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
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                tooltip: 'Сканировать QR код',
                onPressed: _startQRScanner,
              ),
            ],
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
                      if (_searchQuery.isEmpty) ...[
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.qr_code_scanner),
                          label: const Text('Сканировать QR код'),
                          onPressed: _startQRScanner,
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => _showAddContactDialog(),
                          child: const Text('Добавить вручную'),
                        ),
                      ],
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: filteredContacts.length,
                  itemBuilder: (context, index) {
                    final contact = filteredContacts[index];
                    return _buildContactCard(contactProvider, contact);
                  },
                ),
        ),
      ],
    );
  }
  
  Widget _buildContactCard(ContactProvider contactProvider, Contact contact) {
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
        title: Row(
          children: [
            Expanded(
              child: Text(
                contact.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (contact.isOnline)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('UIN: ${contact.uin}'),
            if (!contact.isOnline && contact.lastSeen != null)
              Text(
                'Был(а): ${contact.lastSeenFormatted}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.chat, color: Colors.blue),
              tooltip: 'Написать сообщение',
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
              tooltip: 'Удалить контакт',
              onPressed: () => _showDeleteDialog(context, contactProvider, contact),
            ),
          ],
        ),
        onTap: () => _showContactInfo(context, contact),
        onLongPress: () => _showContactActions(context, contactProvider, contact),
      ),
    );
  }
  
  void _showContactActions(BuildContext context, ContactProvider provider, Contact contact) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Редактировать'),
              onTap: () {
                Navigator.pop(context);
                _showEditContactDialog(contact);
              },
            ),
            ListTile(
              leading: Icon(
                contact.isFavorite ? Icons.star : Icons.star_border,
                color: Colors.orange,
              ),
              title: Text(contact.isFavorite ? 'Убрать из избранного' : 'Добавить в избранное'),
              onTap: () {
                Navigator.pop(context);
                provider.toggleFavorite(contact.uin);
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
                contact.isMuted ? Icons.notifications_on : Icons.notifications_off,
                color: Colors.purple,
              ),
              title: Text(contact.isMuted ? 'Включить уведомления' : 'Отключить уведомления'),
              onTap: () {
                Navigator.pop(context);
                provider.toggleMute(contact.uin, duration: const Duration(hours: 8));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      contact.isMuted
                        ? 'Уведомления включены'
                        : 'Уведомления отключены на 8 часов',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: Text(contact.isBlocked ? 'Разблокировать' : 'Заблокировать'),
              onTap: () {
                Navigator.pop(context);
                _toggleBlockContact(provider, contact);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.green),
              title: const Text('Поделиться контактом'),
              onTap: () {
                Navigator.pop(context);
                _shareContact(contact);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _showAddContactDialog({bool prefilled = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить контакт'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!prefilled)
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        icon: const Icon(Icons.qr_code_scanner, color: Color(0xFF25D366)),
                        label: const Text('Сканировать QR'),
                        onPressed: () {
                          Navigator.pop(context);
                          _startQRScanner();
                        },
                      ),
                    ),
                  ],
                ),
              if (!prefilled) const Divider(),
              TextField(
                controller: _uinController,
                decoration: const InputDecoration(
                  labelText: 'UIN контакта',
                  hintText: 'Введите 6-значный UIN',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
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
              
              if (uin.length != 6 || !RegExp(r'^\d+$').hasMatch(uin)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('UIN должен состоять из 6 цифр'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              Provider.of<ContactProvider>(context, listen: false)
                .addContact(uin, name: name.isNotEmpty ? name : null)
                .then((_) {
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
                })
                .catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ошибка: $error'),
                      backgroundColor: Colors.red,
                    ),
                  );
                });
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }
  
  void _showEditContactDialog(Contact contact) {
    final nameController = TextEditingController(text: contact.name);
    final customNameController = TextEditingController(text: contact.customName);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Редактировать контакт'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Имя',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: customNameController,
                decoration: const InputDecoration(
                  labelText: 'Псевдоним (необязательно)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              final updatedContact = contact.copyWith(
                name: nameController.text.trim(),
                customName: customNameController.text.trim().isEmpty 
                  ? null 
                  : customNameController.text.trim(),
              );
              
              Provider.of<ContactProvider>(context, listen: false)
                .updateContact(updatedContact);
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Контакт обновлен')),
              );
            },
            child: const Text('Сохранить'),
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
              if (contact.customName != null)
                _buildInfoRow('Псевдоним:', contact.customName!),
              _buildInfoRow('UIN:', contact.uin),
              _buildInfoRow('Добавлен:', 
                '${contact.dateAdded.day}.${contact.dateAdded.month}.${contact.dateAdded.year}'),
              _buildInfoRow('Статус:', contact.isOnline ? 'онлайн' : 'оффлайн'),
              if (!contact.isOnline && contact.lastSeen != null)
                _buildInfoRow('Был(а) в сети:', contact.lastSeenFormatted),
              if (contact.isBlocked)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    '⚠️ Этот контакт заблокирован',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              if (contact.isMuted)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    '🔇 Уведомления отключены',
                    style: TextStyle(color: Colors.orange),
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
              provider.removeContact(contact.uin, context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Контакт удалён'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  void _toggleBlockContact(ContactProvider provider, Contact contact) {
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
  
  void _shareContact(Contact contact) {
    // Генерация QR кода для контакта
    final qrData = 'MONOLITH_CONTACT:${contact.uin}:${contact.name}';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Поделиться контактом'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Отсканируйте этот QR код чтобы добавить контакт:'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // TODO: Добавить генератор QR кода
                  // QrImageView(
                  //   data: qrData,
                  //   size: 150,
                  // ),
                  Container(
                    width: 150,
                    height: 150,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.qr_code, size: 50, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'UIN: ${contact.uin}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Имя: ${contact.name}'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Реализовать копирование UIN
              Clipboard.setData(ClipboardData(text: contact.uin));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('UIN скопирован')),
              );
            },
            child: const Text('Копировать UIN'),
          ),
        ],
      ),
    );
  }
}