// lib/screens/chat_screen.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/contact.dart';
import '../models/message.dart';
import '../providers/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  final Contact contact;
  const ChatScreen({super.key, required this.contact});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  final FocusNode _focusNode = FocusNode();
  
  bool _isTyping = false;
  bool _isRecording = false;
  bool _showEmoji = false;
  Timer? _typingTimer;
  Timer? _recordingTimer;
  int _recordingSeconds = 0;
  
  final List<String> _emojis = [
    '😀', '😃', '😄', '😁', '😆', '😅', '😂', '🤣',
    '😊', '😇', '🙂', '🙃', '😉', '😌', '😍', '🥰',
    '😘', '😗', '😙', '😚', '😋', '😛', '😝', '😜',
    '🤪', '🤨', '🧐', '🤓', '😎', '🤩', '🥳', '😏',
    '😒', '😞', '😔', '😟', '😕', '🙁', '☹️', '😣',
    '😖', '😫', '😩', '🥺', '😢', '😭', '😤', '😠',
    '😡', '🤬', '🤯', '😳', '🥵', '🥶', '😱', '😨',
    '😰', '😥', '😓', '🤗', '🤔', '🤭', '🤫', '🤥',
    '😶', '😐', '😑', '😬', '🙄', '😯', '😦', '😧',
    '😮', '😲', '🥱', '😴', '🤤', '😪', '😵', '🤐',
    '🥴', '🤢', '🤮', '🤧', '😷', '🤒', '🤕', '🤑',
    '🤠', '😈', '👿', '👹', '👺', '🤡', '💩', '👻',
    '💀', '☠️', '👽', '👾', '🤖', '🎃', '😺', '😸',
    '😹', '😻', '😼', '😽', '🙀', '😿', '😾',
  ];
  
  @override
  void initState() {
    super.initState();
    _loadChatHistory();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _showEmoji) {
        setState(() => _showEmoji = false);
      }
    });
  }
  
  @override
  void dispose() {
    _typingTimer?.cancel();
    _recordingTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }
  
  void _loadChatHistory() {
    Provider.of<ChatProvider>(context, listen: false).loadMessages(widget.contact.id);
  }
  
  void _sendText() {
    if (_textController.text.trim().isEmpty) return;
    
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.sendTextMessage(widget.contact.id, _textController.text);
    
    _textController.clear();
    _scrollToBottom();
  }
  
  void _sendImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      chatProvider.sendImageMessage(widget.contact.id, image.path);
      _scrollToBottom();
    }
  }
  
  void _startRecording() {
    setState(() {
      _isRecording = true;
      _recordingSeconds = 0;
    });
    
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _recordingSeconds++);
    });
  }
  
  void _stopRecording() {
    _recordingTimer?.cancel();
    
    if (_recordingSeconds >= 1) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      // Временная заглушка вместо реальной записи
      chatProvider.sendVoiceMessage(
        widget.contact.id,
        'voice_${DateTime.now().millisecondsSinceEpoch}.mp3',
        _recordingSeconds,
      );
      _scrollToBottom();
    }
    
    setState(() => _isRecording = false);
  }
  
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  void _toggleEmojiKeyboard() {
    if (_showEmoji) {
      _focusNode.requestFocus();
    } else {
      _focusNode.unfocus();
    }
    setState(() => _showEmoji = !_showEmoji);
  }
  
  void _insertEmoji(String emoji) {
    final text = _textController.text;
    final selection = _textController.selection;
    final newText = text.replaceRange(
      selection.start,
      selection.end,
      emoji,
    );
    _textController.text = newText;
    _textController.selection = TextSelection.collapsed(
      offset: selection.start + emoji.length,
    );
  }

  // ДОБАВЛЕННЫЙ МЕТОД ДЛЯ ЗВОНКОВ
  void _showCallDialog(BuildContext context, {required bool isVideo}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isVideo ? 'Видеозвонок' : 'Звонок'),
        content: Text(
          isVideo 
            ? 'Начать видеозвонок с ${widget.contact.name}?'
            : 'Позвонить ${widget.contact.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isVideo
                      ? 'Видеозвонок ${widget.contact.name}... (симуляция)'
                      : 'Звонок ${widget.contact.name}... (симуляция)',
                  ),
                  backgroundColor: const Color(0xFF075E54),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Text(isVideo ? 'Видеозвонок' : 'Позвонить'),
          ),
        ],
      ),
    );
  }
  
  // НОВЫЙ МЕТОД: Очистить историю чата
  void _clearChatHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Очистить историю чата?'),
        content: const Text('Все сообщения в этом чате будут удалены. Контакт останется в списке.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              final chatProvider = context.read<ChatProvider>();
              chatProvider.clearChatHistory(widget.contact.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('История чата очищена'),
                  backgroundColor: Color(0xFF075E54),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Очистить', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  void _deleteChat(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить чат полностью?'),
        content: const Text('Чат и вся история будут удалены. Контакт останется в списке.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              final chatProvider = context.read<ChatProvider>();
              // Удаляем чат из ChatProvider
              chatProvider.deleteChat(widget.contact.id);
              
              Navigator.pop(context);
              
              // Показываем уведомление
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Чат удалён'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 2),
                ),
              );
              
              // Возвращаемся на предыдущий экран
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  // Виджет галочек статуса (WhatsApp-like)
  Widget _buildStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return const Icon(Icons.access_time, size: 14, color: Colors.grey);
      case MessageStatus.sent:
        return const Icon(Icons.done, size: 14, color: Colors.grey);
      case MessageStatus.delivered:
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.done, size: 14, color: Colors.grey),
            Icon(Icons.done, size: 14, color: Colors.grey),
          ],
        );
      case MessageStatus.read:
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.done, size: 14, color: Color(0xFF34B7F1)),
            Icon(Icons.done, size: 14, color: Color(0xFF34B7F1)),
          ],
        );
      case MessageStatus.error:
        return const Icon(Icons.error, size: 14, color: Colors.red);
    }
  }
  
  Widget _buildMessage(Message message) {
    final isMe = message.isSent;
    
    return Container(
      margin: EdgeInsets.only(
        bottom: 8,
        left: isMe ? 50 : 8,
        right: isMe ? 8 : 50,
      ),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (widget.contact.isGroup && !isMe)
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 4),
              child: Text(
                message.senderName ?? message.senderUIN,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFFDCF8C6) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.type == MessageType.image)
                  Column(
                    children: [
                      Container(
                        width: 200,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.photo, size: 50, color: Colors.grey),
                      ),
                      if (message.text != '📷 Фото')
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(message.text),
                        ),
                    ],
                  )
                else if (message.type == MessageType.voice)
                  Row(
                    children: [
                      const Icon(Icons.mic, color: Color(0xFF075E54)),
                      const SizedBox(width: 8),
                      Text('${message.audioDuration} сек'),
                    ],
                  )
                else
                  Text(message.text),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.only(top: 4, right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.formattedTime,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  _buildStatusIcon(message.status), // ← ГАЛОЧКИ СТАТУСА
                ],
                if (message.isEdited)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      'ред.',
                      style: TextStyle(
                        fontSize: 10,
                        color: isMe ? Colors.white60 : Colors.grey,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final messages = chatProvider.getMessages(widget.contact.id);
    
    return Scaffold(
      backgroundColor: const Color(0xFFECE5DD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF075E54),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.contact.name),
            Text(
              widget.contact.isGroup 
                ? '${widget.contact.isOnline ? 'онлайн' : ''}'
                : '${widget.contact.isOnline ? 'онлайн' : 'был ${widget.contact.lastSeen}'}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
  PopupMenuButton<String>(
    icon: const Icon(Icons.more_vert),
    onSelected: (value) {
      if (value == 'clear_chat') {
        _clearChatHistory(context);
      } else if (value == 'delete_chat') {
        _deleteChat(context);
      } else if (value == 'contact_info') {
        _showContactInfo(context);
      }
    },
    itemBuilder: (context) => [
      const PopupMenuItem(
        value: 'clear_chat',
        child: Row(
          children: [
            Icon(Icons.delete_sweep, color: Colors.blue),
            SizedBox(width: 8),
            Text('Очистить историю'),
          ],
        ),
      ),
      const PopupMenuItem(
        value: 'delete_chat',
        child: Row(
          children: [
            Icon(Icons.delete_forever, color: Colors.red),
            SizedBox(width: 8),
            Text('Удалить чат полностью'),
          ],
        ),
      ),
      const PopupMenuItem(
        value: 'contact_info',
        child: Row(
          children: [
            Icon(Icons.info, color: Colors.green),
            SizedBox(width: 8),
            Text('Информация о контакте'),
          ],
        ),
      ),
    ],
  ),
  if (!widget.contact.isGroup) ...[
    IconButton(
      icon: const Icon(Icons.video_call),
      onPressed: () => _showCallDialog(context, isVideo: true),
    ),
    IconButton(
      icon: const Icon(Icons.phone),
      onPressed: () => _showCallDialog(context, isVideo: false),
    ),
  ],
],
      ),
      body: GestureDetector(
        onTap: () {
          if (_showEmoji) {
            _toggleEmojiKeyboard();
          }
          _focusNode.unfocus();
        },
        child: Column(
          children: [
            if (_isTyping)
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.white,
                child: Row(
                  children: [
                    const SizedBox(width: 50),
                    Text(
                      '${widget.contact.name} печатает...',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: const Color(0xFF075E54),
                      ),
                    ),
                  ],
                ),
              ),
            
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFECE5DD),
                      Color(0xFFE0D8CF),
                    ],
                  ),
                ),
                child: ListView(
                  controller: _scrollController,
                  reverse: false,
                  padding: const EdgeInsets.all(16),
                  children: [
                    for (var message in messages) _buildMessage(message),
                  ],
                ),
              ),
            ),
            
            if (_showEmoji)
              Container(
                height: 250,
                color: const Color(0xFFF0F0F0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                    childAspectRatio: 1.0,
                    mainAxisSpacing: 4.0,
                    crossAxisSpacing: 4.0,
                  ),
                  padding: const EdgeInsets.all(8),
                  itemCount: _emojis.length,
                  itemBuilder: (context, index) {
                    return TextButton(
                      onPressed: () => _insertEmoji(_emojis[index]),
                      child: Text(
                        _emojis[index],
                        style: const TextStyle(fontSize: 24),
                      ),
                    );
                  },
                ),
              ),
            
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
                color: Color(0xFFECE5DD),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _showEmoji ? Icons.keyboard : Icons.emoji_emotions,
                      color: _showEmoji ? const Color(0xFF075E54) : Colors.grey,
                    ),
                    onPressed: _toggleEmojiKeyboard,
                  ),
                  
                  IconButton(
                    icon: const Icon(Icons.attach_file, color: Colors.grey),
                    onPressed: _sendImage,
                  ),
                  
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          hintText: _isRecording 
                            ? 'Запись: $_recordingSeconds сек' 
                            : 'Сообщение...',
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onChanged: (text) {
                          if (text.isNotEmpty && !_isTyping) {
                            setState(() => _isTyping = true);
                          }
                          _typingTimer?.cancel();
                          _typingTimer = Timer(const Duration(seconds: 2), () {
                            setState(() => _isTyping = false);
                          });
                        },
                        onSubmitted: (_) => _sendText(),
                      ),
                    ),
                  ),
                  
                  if (_isRecording)
                    GestureDetector(
                      onLongPressUp: _stopRecording,
                      child: Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        child: const Icon(Icons.mic, color: Colors.white),
                      ),
                    )
                  else
                    GestureDetector(
                      onLongPress: _startRecording,
                      child: Container(
                        margin: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isRecording ? Colors.red : const Color(0xFF075E54),
                        ),
                        child: IconButton(
                          icon: Icon(
                            _isRecording ? Icons.mic : Icons.send,
                            color: Colors.white,
                          ),
                          onPressed: _isRecording ? null : _sendText,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showContactInfo(BuildContext context) {
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
                  widget.contact.name.substring(0, 1),
                  style: const TextStyle(fontSize: 32, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Имя:', widget.contact.name),
            _buildInfoRow('UIN:', widget.contact.uin),
            if (widget.contact.isGroup)
              _buildInfoRow('Тип:', 'Групповой чат')
            else
              _buildInfoRow('Статус:', widget.contact.isOnline ? 'онлайн' : 'оффлайн'),
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
}