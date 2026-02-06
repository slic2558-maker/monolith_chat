import 'package:flutter/material.dart';

class ChatInput extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final VoidCallback onAttach;
  final VoidCallback onVoiceStart;
  final VoidCallback onVoiceStop;
  final bool isRecording;
  
  const ChatInput({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSend,
    required this.onAttach,
    required this.onVoiceStart,
    required this.onVoiceStop,
    this.isRecording = false,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  bool _showEmoji = false;
  bool _isTyping = false;
  
  final List<String> _emojis = [
    '😀', '😃', '😄', '😁', '😆', '😅', '😂', '🤣',
    '😊', '😇', '🙂', '🙃', '😉', '😌', '😍', '🥰',
    '😘', '😗', '😙', '😚', '😋', '😛', '😝', '😜',
    '🤪', '🤨', '🧐', '🤓', '😎', '🤩', '🥳', '😏',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Column(
      children: [
        if (_showEmoji)
          Container(
            height: 250,
            color: isDark ? 
              const Color(0xFF1F2C34) : const Color(0xFFF0F0F0),
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
                color: isDark ? 
                  const Color(0xFF26333D) : const Color(0xFFE0E0E0),
              ),
            ),
            color: isDark ? 
              const Color(0xFF1F2C34) : const Color(0xFFECE5DD),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  _showEmoji ? Icons.keyboard : Icons.emoji_emotions,
                  color: _showEmoji 
                    ? (isDark ? 
                        const Color(0xFF00A884) : 
                        const Color(0xFF075E54))
                    : (isDark ? Colors.grey[400] : Colors.grey),
                ),
                onPressed: _toggleEmojiKeyboard,
              ),
              
              IconButton(
                icon: Icon(
                  Icons.attach_file,
                  color: isDark ? Colors.grey[400] : Colors.grey,
                ),
                onPressed: widget.onAttach,
              ),
              
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? 
                      const Color(0xFF2A3942) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    controller: widget.controller,
                    focusNode: widget.focusNode,
                    decoration: InputDecoration(
                      hintText: widget.isRecording 
                        ? 'Запись...' 
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
                    maxLines: 5,
                    minLines: 1,
                    onChanged: (text) {
                      setState(() => _isTyping = text.isNotEmpty);
                    },
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
              
              if (widget.isRecording)
                GestureDetector(
                  onLongPressUp: widget.onVoiceStop,
                  child: Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                    child: const Icon(
                      Icons.mic,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                )
              else if (_isTyping || widget.controller.text.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? 
                      const Color(0xFF00A884) : const Color(0xFF075E54),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                )
              else
                GestureDetector(
                  onLongPress: widget.onVoiceStart,
                  child: Container(
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? 
                        const Color(0xFF00A884) : const Color(0xFF075E54),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(
                        Icons.mic,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
  
  void _toggleEmojiKeyboard() {
    if (_showEmoji) {
      widget.focusNode.requestFocus();
    } else {
      widget.focusNode.unfocus();
    }
    setState(() => _showEmoji = !_showEmoji);
  }
  
  void _insertEmoji(String emoji) {
    final text = widget.controller.text;
    final selection = widget.controller.selection;
    final newText = text.replaceRange(
      selection.start,
      selection.end,
      emoji,
    );
    widget.controller.text = newText;
    widget.controller.selection = TextSelection.collapsed(
      offset: selection.start + emoji.length,
    );
  }
  
  void _sendMessage() {
    if (widget.controller.text.trim().isNotEmpty) {
      widget.onSend();
      widget.controller.clear();
      setState(() => _isTyping = false);
    }
  }
}