import 'package:riverpod/riverpod.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:photo_view/photo_view.dart';
import '../../domain/entities/status.dart';
import '../providers/status_provider.dart';
import '../widgets/status_viewer.dart';

class StatusScreen extends ConsumerWidget {
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusesAsync = ref.watch(statusProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Статусы'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showOptions(context),
          ),
        ],
      ),
      body: statusesAsync.when(
        data: (statuses) {
          if (statuses.isEmpty) {
            return _buildEmptyState(context);
          }
          
          return ListView(
            children: [
              // My status
              _buildMyStatus(context, ref),
              
              // Recent updates
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Недавние обновления',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              
              // Status list
              ...statuses.map((status) => _buildStatusItem(context, status)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Ошибка: $error')),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'camera',
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            onPressed: () => _createPhotoStatus(context),
            child: const Icon(Icons.camera_alt),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'text_status',
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            onPressed: () => _createTextStatus(context),
            child: const Icon(Icons.text_fields),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMyStatus(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.value;
    final myStatuses = ref.watch(statusProvider
        .select((value) => value.value?.where((s) => s.creatorUIN == user?.uin).toList() ?? []));
    
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey[300],
            backgroundImage: user?.avatarUrl != null
                ? NetworkImage(user!.avatarUrl!)
                : null,
            child: user?.avatarUrl == null
                ? Icon(
                    Icons.person,
                    size: 32,
                    color: Colors.grey[600],
                  )
                : null,
          ),
          if (myStatuses.isNotEmpty)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    myStatuses.length.toString(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        user?.name ?? 'Мой статус',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: myStatuses.isNotEmpty
          ? Text(
              '${myStatuses.length} обновлений',
              style: const TextStyle(color: Colors.green),
            )
          : const Text('Добавить статус'),
      trailing: myStatuses.isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: () => _showMyStatusOptions(context),
            )
          : null,
      onTap: myStatuses.isNotEmpty
          ? () => _viewMyStatuses(context, myStatuses)
          : () => _addStatus(context),
    );
  }
  
  Widget _buildStatusItem(BuildContext context, Status status) {
    final isExpired = status.isExpired;
    
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey[300],
            backgroundImage: status.avatarUrl != null
                ? NetworkImage(status.avatarUrl!)
                : null,
            child: status.avatarUrl == null
                ? Icon(
                    Icons.person,
                    size: 24,
                    color: Colors.grey[600],
                  )
                : null,
          ),
          if (!isExpired)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        status.creatorName ?? status.creatorUIN,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isExpired ? Colors.grey : Colors.black,
        ),
      ),
      subtitle: Text(
        status.createdAtFormatted,
        style: TextStyle(
          color: isExpired ? Colors.grey : Colors.grey[600],
        ),
      ),
      trailing: isExpired
          ? null
          : Text(
              status.timeLeftFormatted,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
      onTap: isExpired
          ? null
          : () => _viewStatus(context, status),
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_camera,
            size: 80,
            color: Colors.grey.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'Нет обновлений статусов',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Добавьте свой первый статус',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => _addStatus(context),
            child: const Text('Добавить статус'),
          ),
        ],
      ),
    );
  }
  
  void _addStatus(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddStatusSheet(
        onTextStatus: () => _createTextStatus(context),
        onPhotoStatus: () => _createPhotoStatus(context),
        onVideoStatus: () => _createVideoStatus(context),
      ),
    );
  }
  
  void _createTextStatus(BuildContext context) {
    Navigator.pop(context);
    
    showDialog(
      context: context,
      builder: (context) => TextStatusDialog(
        onCreate: (text) {
          // TODO: Create text status
        },
      ),
    );
  }
  
  void _createPhotoStatus(BuildContext context) {
    Navigator.pop(context);
    // TODO: Pick photo and create status
  }
  
  void _createVideoStatus(BuildContext context) {
    Navigator.pop(context);
    // TODO: Pick video and create status
  }
  
  void _viewStatus(BuildContext context, Status status) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatusViewerScreen(
          status: status,
          onReply: (text) {
            // TODO: Send reply to status
          },
          onViewInfo: () => _showStatusInfo(context, status),
        ),
      ),
    );
  }
  
  void _viewMyStatuses(BuildContext context, List<Status> statuses) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyStatusesScreen(
          statuses: statuses,
          onDelete: (statusId) {
            // TODO: Delete status
          },
          onShare: (statusId) {
            // TODO: Share status
          },
        ),
      ),
    );
  }
  
  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatusOptionsSheet(
        onMuteAll: () {
          Navigator.pop(context);
          // TODO: Mute all statuses
        },
        onSettings: () {
          Navigator.pop(context);
          // TODO: Open status settings
        },
        onPrivacy: () {
          Navigator.pop(context);
          // TODO: Open privacy settings
        },
      ),
    );
  }
  
  void _showMyStatusOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => MyStatusOptionsSheet(
        onDeleteAll: () {
          Navigator.pop(context);
          _deleteAllStatuses(context);
        },
        onShareAll: () {
          Navigator.pop(context);
          // TODO: Share all statuses
        },
        onSettings: () {
          Navigator.pop(context);
          // TODO: Open status settings
        },
      ),
    );
  }
  
  void _showStatusInfo(BuildContext context, Status status) {
    showDialog(
      context: context,
      builder: (context) => StatusInfoDialog(status: status),
    );
  }
  
  void _deleteAllStatuses(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить все статусы?'),
        content: const Text('Все ваши статусы будут удалены. Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Delete all statuses
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Все статусы удалены')),
              );
            },
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}

// Status Viewer Screen
class StatusViewerScreen extends StatefulWidget {
  final Status status;
  final Function(String)? onReply;
  final VoidCallback? onViewInfo;
  
  const StatusViewerScreen({
    super.key,
    required this.status,
    this.onReply,
    this.onViewInfo,
  });
  
  @override
  State<StatusViewerScreen> createState() => _StatusViewerScreenState();
}

class _StatusViewerScreenState extends State<StatusViewerScreen> {
  late VideoPlayerController _videoController;
  late Future<void> _initializeVideoPlayerFuture;
  bool _isPlaying = true;
  
  @override
  void initState() {
    super.initState();
    
    if (widget.status.type == StatusType.video && widget.status.mediaUrl != null) {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.status.mediaUrl!),
      );
      _initializeVideoPlayerFuture = _videoController.initialize();
      _videoController.setLooping(true);
      _videoController.play();
    }
  }
  
  @override
  void dispose() {
    if (widget.status.type == StatusType.video) {
      _videoController.dispose();
    }
    super.dispose();
  }
  
  void _togglePlayPause() {
    setState(() {
      if (_videoController.value.isPlaying) {
        _videoController.pause();
        _isPlaying = false;
      } else {
        _videoController.play();
        _isPlaying = true;
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Status content
            Center(
              child: widget.status.type == StatusType.text
                  ? _buildTextStatus()
                  : widget.status.type == StatusType.image
                      ? _buildImageStatus()
                      : _buildVideoStatus(),
            ),
            
            // Header
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: _buildHeader(),
            ),
            
            // Footer
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: _buildFooter(),
            ),
            
            // Video controls
            if (widget.status.type == StatusType.video)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _togglePlayPause,
                  child: Container(
                    color: Colors.transparent,
                    child: Center(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: _isPlaying ? 0 : 1,
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 64,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTextStatus() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Text(
        widget.status.text ?? '',
        style: const TextStyle(
          fontSize: 24,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
  
  Widget _buildImageStatus() {
    return PhotoView(
      imageProvider: NetworkImage(widget.status.mediaUrl!),
      minScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.covered * 2,
      heroAttributes: PhotoViewHeroAttributes(tag: widget.status.id),
      backgroundDecoration: const BoxDecoration(color: Colors.black),
    );
  }
  
  Widget _buildVideoStatus() {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AspectRatio(
            aspectRatio: _videoController.value.aspectRatio,
            child: VideoPlayer(_videoController),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
  
  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: widget.status.avatarUrl != null
              ? NetworkImage(widget.status.avatarUrl!)
              : null,
          radius: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.status.creatorName ?? widget.status.creatorUIN,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.status.createdAtFormatted,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: widget.onViewInfo,
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
  
  Widget _buildFooter() {
    return Column(
      children: [
        // Progress indicator
        LinearProgressIndicator(
          value: widget.status.timeLeft.inSeconds / (24 * 60 * 60),
          backgroundColor: Colors.white30,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        ),
        const SizedBox(height: 16),
        
        // Reply input
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Ответить...',
                  hintStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                onSubmitted: (text) {
                  if (text.isNotEmpty && widget.onReply != null) {
                    widget.onReply!(text);
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.green),
              onPressed: () {
                // TODO: Send reply
              },
            ),
          ],
        ),
      ],
    );
  }
}