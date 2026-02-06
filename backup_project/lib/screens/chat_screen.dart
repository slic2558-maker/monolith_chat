import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/contact.dart';
import '../models/message.dart';
import '../providers/chat_provider.dart';
import '../providers/contact_provider.dart';
import '../providers/theme_provider.dart';
import '../services/notification_service.dart';

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
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }
  
  void _loadChatHistory() {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.loadMessages(widget.contact.id);
  }
  
  void _sendText() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.sendTextMessage(widget.contact.id, text);
    
    _textController.clear();
    _scrollToBottom();
  }
  
  Future<void> _sendImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      await chatProvider.sendImageMessage(widget.contact.id, image.path);
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

  // Диалог для звонков
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
  
  // Виджет галочек статуса
  Widget _buildStatusIcon(MessageStatus status) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    
    switch (status) {
      case MessageStatus.sending:
        return Icon(Icons.access_time, size: 14, 
            color: isDark ? Colors.grey[400] : Colors.grey);
      case MessageStatus.sent:
        return Icon(Icons.done, size: 14, 
            color: isDark ? Colors.grey[400] : Colors.grey);
      case MessageStatus.delivered:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.done, size: 14, 
                color: isDark ? Colors.grey[400] : Colors.grey),
            Icon(Icons.done, size: 14, 
                color: isDark ? Colors.grey[400] : Colors.grey),
          ],
        );
      case MessageStatus.read:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.done, size: 14, color: const Color(0xFF34B7F1)),
            Icon(Icons.done, size: 14, color: const Color(0xFF34B7F1)),
          ],
        );
      case MessageStatus.error:
        return Icon(Icons.error, size: 14, color: Colors.red);
      default:
        return const SizedBox();
    }
  }
  
  // Свайп для ответа на сообщение
  void _showReplySheet(Message message) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('Ответить'),
              onTap: () {
                Navigator.pop(context);
                _showReplyInput(message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Копировать'),
              onTap: () {
                Clipboard.setData(ClipboardData(text: message.text));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Скопировано')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.forward),
              title: const Text('Переслать'),
              onTap: () {
                Navigator.pop(context);
                _showForwardDialog(message);
              },
            ),
            ListTile(
              leading: Icon(message.isPinned ? Icons.push_pin_outlined : Icons.push_pin),
              title: Text(message.isPinned ? 'Открепить' : 'Закрепить'),
              onTap: () {
                Navigator.pop(context);
                _togglePinMessage(message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Удалить', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteDialog(message);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _showReplyInput(Message message) {
    _textController.text = '';
    _focusNode.requestFocus();
    // TODO: Добавить preview ответа
  }
  
  void _showForwardDialog(Message message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Переслать сообщение'),
        content: const Text('Выберите чаты для пересылки'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Реализовать выбор чатов
              Navigator.pop(context);
            },
            child: const Text('Переслать'),
          ),
        ],
      ),
    );
  }
  
  void _togglePinMessage(Message message) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    if (message.isPinned) {
      chatProvider.unpinMessage(messageId: message.id);
    } else {
      chatProvider.pinMessage(messageId: message.id);
    }
  }
  
  void _showDeleteDialog(Message message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить сообщение?'),
        content: const Text('Удалить для всех или только для себя?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteMessage(message, forEveryone: false);
            },
            child: const Text('Для меня'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteMessage(message, forEveryone: true);
            },
            child: const Text('Для всех'),
          ),
        ],
      ),
    );
  }
  
  void _deleteMessage(Message message, {required bool forEveryone}) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.deleteMessage(message.id, forEveryone: forEveryone);
  }

  Widget _buildMessage(Message message) {
    final isMe = message.isSent;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return GestureDetector(
      onLongPress: () => _showReplySheet(message),
      child: Container(
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
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe 
                  ? (isDark ? const Color(0xFF005C4B) : const Color(0xFFDCF8C6))
                  : (isDark ? const Color(0xFF1F2C34) : Colors.white),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.replyToMessageId != null && message.quotedText != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black26 : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (message.quotedSenderName != null)
                            Text(
                              message.quotedSenderName!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          Text(
                            message.quotedText!,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  
                  if (message.type == MessageType.image)
                    Column(
                      children: [
                        Container(
                          width: 200,
                          height: 150,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[800] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                            image: const DecorationImage(
                              image: AssetImage('assets/placeholder_image.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        if (message.text != '📷 Фото')
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              message.text,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                      ],
                    )
                  else if (message.type == MessageType.voice)
                    Row(
                      children: [
                        Icon(Icons.mic, color: isDark ? Colors.white70 : const Color(0xFF075E54)),
                        const SizedBox(width: 8),
                        Text(
                          '${message.audioDuration} сек',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.play_circle_fill, 
                            color: isDark ? Colors.white70 : const Color(0xFF075E54)),
                      ],
                    )
                  else
                    Text(
                      message.text,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  
                  // Реакции
                  if (message.reactions.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Wrap(
                        spacing: 4,
                        children: message.reactions.entries.map((entry) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey[800] : Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${entry.value}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
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
                    style: TextStyle(
                      fontSize: 11, 
                      color: isDark ? Colors.grey[400] : Colors.grey,
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    _buildStatusIcon(message.status),
                  ],
                  if (message.isEdited)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        'ред.',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? Colors.white60 : Colors.grey,
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

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final contactProvider = Provider.of<ContactProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final messages = chatProvider.getMessages(widget.contact.id);
    final isDark = themeProvider.isDarkMode;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121B22) : const Color(0xFFECE5DD),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1F2C34) : const Color(0xFF075E54),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: GestureDetector(
          onTap: () => _showContactInfo(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.contact.name),
              Text(
                widget.contact.isGroup 
                  ? '${widget.contact.groupMembers?.length ?? 0} участников'
                  : '${widget.contact.isOnline ? 'онлайн' : widget.contact.lastSeenFormatted}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
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
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showContactInfo(context),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'search') {
                // TODO: Поиск в чате
              } else if (value == 'mute') {
                _toggleMute();
              } else if (value == 'wallpaper') {
                // TODO: Сменить обои
              } else if (value == 'clear') {
                _clearChat();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'search',
                child: Row(
                  children: [
                    Icon(Icons.search, size: 20),
                    SizedBox(width: 8),
                    Text('Поиск'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'mute',
                child: Row(
                  children: [
                    Icon(widget.contact.isMuted ? Icons.notifications_on : Icons.notifications_off, size: 20),
                    const SizedBox(width: 8),
                    Text(widget.contact.isMuted ? 'Включить уведомления' : 'Отключить уведомления'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'wallpaper',
                child: Row(
                  children: [
                    Icon(Icons.wallpaper, size: 20),
                    SizedBox(width: 8),
                    Text('Обои чата'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Очистить чат', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
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
                color: isDark ? const Color(0xFF1F2C34) : Colors.white,
                child: Row(
                  children: [
                    const SizedBox(width: 50),
                    Text(
                      '${widget.contact.name} печатает...',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: isDark ? const Color(0xFF00A884) : const Color(0xFF075E54),
                      ),
                    ),
                  ],
                ),
              ),
            
            Expanded(
              child: Container(
                decoration: widget.contact.wallpaper != null
                    ? BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(widget.contact.wallpaper!),
                          fit: BoxFit.cover,
                        ),
                      )
                    : null,
                child: messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              widget.contact.isGroup ? Icons.group : Icons.person,
                              size: 64,
                              color: isDark ? Colors.grey[700] : Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.contact.isGroup
                                  ? 'Нет сообщений в группе'
                                  : 'Начните общение',
                              style: TextStyle(
                                fontSize: 18,
                                color: isDark ? Colors.grey[400] : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView(
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
                color: isDark ? const Color(0xFF1F2C34) : const Color(0xFFF0F0F0),
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
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark ? const Color(0xFF26333D) : const Color(0xFFE0E0E0),
                  ),
                ),
                color: isDark ? const Color(0xFF1F2C34) : const Color(0xFFECE5DD),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _showEmoji ? Icons.keyboard : Icons.emoji_emotions,
                      color: _showEmoji 
                          ? (isDark ? const Color(0xFF00A884) : const Color(0xFF075E54))
                          : (isDark ? Colors.grey[400] : Colors.grey),
                    ),
                    onPressed: _toggleEmojiKeyboard,
                  ),
                  
                  IconButton(
                    icon: Icon(Icons.attach_file, 
                        color: isDark ? Colors.grey[400] : Colors.grey),
                    onPressed: _showAttachMenu,
                  ),
                  
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2A3942) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          hintText: _isRecording 
                            ? 'Запись: $_recordingSeconds сек' 
                            : 'Сообщение...',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, 
                            vertical: 12,
                          ),
                        ),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
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
                          color: _isRecording 
                              ? Colors.red 
                              : (isDark ? const Color(0xFF00A884) : const Color(0xFF075E54)),
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
  
  void _showAttachMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text('Галерея'),
              onTap: () {
                Navigator.pop(context);
                _sendImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text('Камера'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.description, color: Colors.orange),
              title: const Text('Документ'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Выбор документа
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on, color: Colors.red),
              title: const Text('Местоположение'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Отправка местоположения
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_phone, color: Colors.purple),
              title: const Text('Контакт'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Отправка контакта
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      await chatProvider.sendImageMessage(widget.contact.id, photo.path);
      _scrollToBottom();
    }
  }
  
  void _toggleMute() {
    final contactProvider = Provider.of<ContactProvider>(context, listen: false);
    contactProvider.toggleMute(widget.contact.uin, duration: const Duration(hours: 8));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.contact.isMuted 
            ? 'Уведомления включены'
            : 'Уведомления отключены на 8 часов',
        ),
      ),
    );
  }
  
  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Очистить чат?'),
        content: const Text('Все сообщения будут удалены. Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              final chatProvider = Provider.of<ChatProvider>(context, listen: false);
              chatProvider.clearChat(widget.contact.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Чат очищен')),
              );
            },
            child: const Text('Очистить'),
          ),
        ],
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
            if (widget.contact.dateAdded != null)
              _buildInfoRow('Добавлен:', 
                '${widget.contact.dateAdded.day}.${widget.contact.dateAdded.month}.${widget.contact.dateAdded.year}'),
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