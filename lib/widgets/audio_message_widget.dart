import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/message.dart';

class AudioMessageWidget extends StatefulWidget {
  final Message message;
  final bool isSentByMe;
  
  const AudioMessageWidget({
    super.key,
    required this.message,
    required this.isSentByMe,
  });
  
  @override
  State<AudioMessageWidget> createState() => _AudioMessageWidgetState();
}

class _AudioMessageWidgetState extends State<AudioMessageWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration? _duration;
  Duration? _position;
  
  @override
  void initState() {
    super.initState();
    _initAudio();
  }
  
  Future<void> _initAudio() async {
    try {
      if (widget.message.mediaUrl != null) {
        await _audioPlayer.setUrl(widget.message.mediaUrl!);
        _duration = _audioPlayer.duration;
      }
    } catch (e) {
      print('Ошибка загрузки аудио: $e');
    }
    
    _audioPlayer.playerStateStream.listen((state) {
      if (state.playing) {
        setState(() {
          _isPlaying = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isPlaying = false;
        });
      }
    });
    
    _audioPlayer.positionStream.listen((position) {
      setState(() {
        _position = position;
      });
    });
  }
  
  Future<void> _togglePlay() async {
    if (_isLoading) return;
    
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      setState(() => _isLoading = true);
      try {
        await _audioPlayer.play();
      } catch (e) {
        print('Ошибка воспроизведения: $e');
        setState(() => _isLoading = false);
      }
    }
  }
  
  String _formatDuration(Duration? duration) {
    if (duration == null) return '--:--';
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
  
  double _getProgress() {
    if (_duration == null || _position == null) return 0.0;
    if (_duration!.inSeconds == 0) return 0.0;
    return _position!.inSeconds / _duration!.inSeconds;
  }
  
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isSentByMe 
      ? const Color(0xFF128C7E)
      : const Color(0xFFECE5DD);
    final textColor = widget.isSentByMe 
      ? Colors.white 
      : Colors.black;
    
    return Container(
      constraints: const BoxConstraints(maxWidth: 250),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Иконка и кнопка воспроизведения
          Row(
            children: [
              GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: textColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: _isLoading
                      ? const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: textColor,
                          size: 24,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Прогресс бар
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Время
                    Text(
                      _formatDuration(_position ?? _duration),
                      style: TextStyle(
                        fontSize: 12,
                        color: textColor.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Прогресс бар
                    LinearProgressIndicator(
                      value: _getProgress(),
                      backgroundColor: textColor.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.isSentByMe ? Colors.white : const Color(0xFF128C7E),
                      ),
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Продолжительность (если есть в сообщении)
          if (widget.message.audioDuration != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '${widget.message.audioDuration} сек',
                style: TextStyle(
                  fontSize: 12,
                  color: textColor.withOpacity(0.7),
                ),
              ),
            ),
        ],
      ),
    );
  }
} 