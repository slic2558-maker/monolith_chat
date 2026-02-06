import 'package:flutter/material.dart';
import '../../domain/entities/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final bool showTail;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.showTail = true,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: EdgeInsets.only(
          left: isMe ? 60 : 8,
          right: isMe ? 8 : 60,
          top: 4,
          bottom: 4,
        ),
        child: Row(
          mainAxisAlignment: 
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe && showTail)
              CustomPaint(
                painter: _MessageTailPainter(
                  color: isDark ? 
                    const Color(0xFF1F2C34) : Colors.white,
                  isLeft: true,
                ),
                size: const Size(8, 10),
              ),
            
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isMe
                    ? (isDark ? 
                        const Color(0xFF005C4B) : 
                        const Color(0xFFDCF8C6))
                    : (isDark ? 
                        const Color(0xFF1F2C34) : Colors.white),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: isMe ? 
                      const Radius.circular(16) : 
                      const Radius.circular(4),
                    bottomRight: isMe ? 
                      const Radius.circular(4) : 
                      const Radius.circular(16),
                  ),
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
                    // Quoted message (reply)
                    if (message.replyToMessageId != null && 
                        message.quotedText != null)
                      Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isDark ? 
                            Colors.black26 : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark ? 
                              Colors.grey[700]! : Colors.grey[300]!,
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
                                  color: isDark ? 
                                    Colors.white70 : Colors.black54,
                                ),
                              ),
                            Text(
                              message.quotedText!,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? 
                                  Colors.white70 : Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    
                    // Message text
                    if (message.type == MessageType.text)
                      Text(
                        message.text,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    
                    if (message.type == MessageType.image)
                      Column(
                        children: [
                          Container(
                            width: 200,
                            height: 150,
                            decoration: BoxDecoration(
                              color: isDark ? 
                                Colors.grey[800] : Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                              image: const DecorationImage(
                                image: AssetImage(
                                  'assets/images/placeholder_image.png'
                                ),
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
                                  color: isDark ? 
                                    Colors.white : Colors.black,
                                ),
                              ),
                            ),
                        ],
                      ),
                    
                    if (message.type == MessageType.voice)
                      Row(
                        children: [
                          Icon(
                            Icons.mic, 
                            color: isDark ? 
                              Colors.white70 : const Color(0xFF075E54),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${message.audioDuration} сек',
                            style: TextStyle(
                              color: isDark ? 
                                Colors.white70 : Colors.black,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.play_circle_fill,
                            color: isDark ? 
                              Colors.white70 : const Color(0xFF075E54),
                            size: 24,
                          ),
                        ],
                      ),
                    
                    // Reactions
                    if (message.reactions.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Wrap(
                          spacing: 4,
                          children: message.reactions.entries.map((entry) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isDark ? 
                                  Colors.grey[800] : Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                entry.value,
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    
                    // Message info (time, status)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            message.formattedTime,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? 
                                Colors.grey[400] : Colors.grey,
                            ),
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 4),
                            _buildStatusIcon(message.status, isDark),
                          ],
                          if (message.isEdited)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Text(
                                'ред.',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark ? 
                                    Colors.white60 : Colors.grey,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            if (isMe && showTail)
              CustomPaint(
                painter: _MessageTailPainter(
                  color: isDark ? 
                    const Color(0xFF005C4B) : 
                    const Color(0xFFDCF8C6),
                  isLeft: false,
                ),
                size: const Size(8, 10),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusIcon(MessageStatus status, bool isDark) {
    switch (status) {
      case MessageStatus.sending:
        return Icon(
          Icons.access_time,
          size: 14,
          color: isDark ? Colors.grey[400] : Colors.grey,
        );
      case MessageStatus.sent:
        return Icon(
          Icons.done,
          size: 14,
          color: isDark ? Colors.grey[400] : Colors.grey,
        );
      case MessageStatus.delivered:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.done,
              size: 14,
              color: isDark ? Colors.grey[400] : Colors.grey,
            ),
            Icon(
              Icons.done,
              size: 14,
              color: isDark ? Colors.grey[400] : Colors.grey,
            ),
          ],
        );
      case MessageStatus.read:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.done,
              size: 14,
              color: const Color(0xFF34B7F1),
            ),
            Icon(
              Icons.done,
              size: 14,
              color: const Color(0xFF34B7F1),
            ),
          ],
        );
      default:
        return const SizedBox();
    }
  }
}

class _MessageTailPainter extends CustomPainter {
  final Color color;
  final bool isLeft;
  
  _MessageTailPainter({required this.color, required this.isLeft});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    
    if (isLeft) {
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
      path.close();
    } else {
      path.moveTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.lineTo(0, 0);
      path.close();
    }
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}