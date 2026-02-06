import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:vibration/vibration.dart';
import 'dart:io';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Notification channels
  static const AndroidNotificationChannel _messagesChannel =
      AndroidNotificationChannel(
    'monolith_chat_messages',
    'Monolith Chat Messages',
    description: 'Уведомления о новых сообщениях',
    importance: Importance.high,
    priority: Priority.high,
    sound: RawResourceAndroidNotificationSound('message_tone'),
    enableVibration: true,
    vibrationPattern: Int64List.fromList([0, 250, 250, 250]),
    showBadge: true,
  );

  static const AndroidNotificationChannel _callsChannel =
      AndroidNotificationChannel(
    'monolith_chat_calls',
    'Monolith Chat Calls',
    description: 'Уведомления о звонках',
    importance: Importance.max,
    priority: Priority.max,
    sound: RawResourceAndroidNotificationSound('call_tone'),
    enableVibration: true,
    vibrationPattern: Int64List.fromList([1000, 1000, 1000, 1000]),
    showBadge: true,
  );

  static const AndroidNotificationChannel _statusChannel =
      AndroidNotificationChannel(
    'monolith_chat_status',
    'Monolith Chat Status Updates',
    description: 'Уведомления об обновлениях статусов',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
    enableVibration: false,
    showBadge: false,
  );

  // Initialize notifications
  Future<void> initialize() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );
    
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
    
    // Create notification channels (Android 8.0+)
    if (Platform.isAndroid) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_messagesChannel);
      
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_callsChannel);
      
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_statusChannel);
    }
  }

  // Show new message notification
  Future<void> showMessageNotification({
    required String title,
    required String body,
    required String chatId,
    required String messageId,
    String? imageUrl,
    bool isGroup = false,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'monolith_chat_messages',
      'Monolith Chat Messages',
      channelDescription: 'Уведомления о новых сообщениях',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Новое сообщение',
      colorized: true,
      color: Color(0xFF075E54),
      styleInformation: BigTextStyleInformation(body),
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      showWhen: true,
      autoCancel: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 250, 250, 250]),
      visibility: NotificationVisibility.public,
      category: AndroidNotificationCategory.message,
      actions: [
        AndroidNotificationAction(
          'reply',
          'Ответить',
          titleColor: Color(0xFF25D366),
        ),
        AndroidNotificationAction(
          'mark_as_read',
          'Прочитано',
        ),
      ],
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'message_tone.aiff',
      badgeNumber: 1,
      threadIdentifier: chatId,
      categoryIdentifier: 'MESSAGE',
    );
    
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notificationsPlugin.show(
      _generateNotificationId(chatId, messageId),
      isGroup ? 'Группа: $title' : title,
      body,
      details,
      payload: json.encode({
        'type': 'message',
        'chatId': chatId,
        'messageId': messageId,
        'isGroup': isGroup,
      }),
    );
    
    // Vibrate if enabled
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(pattern: [0, 250, 250, 250]);
    }
  }

  // Show call notification
  Future<void> showCallNotification({
    required String callerName,
    required String callerUIN,
    required bool isVideoCall,
    String? avatarUrl,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'monolith_chat_calls',
      'Monolith Chat Calls',
      channelDescription: 'Уведомления о звонках',
      importance: Importance.max,
      priority: Priority.max,
      ticker: 'Входящий звонок',
      ongoing: true,
      autoCancel: false,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([1000, 1000, 1000, 1000]),
      fullScreenIntent: true,
      category: AndroidNotificationCategory.call,
      actions: [
        AndroidNotificationAction(
          'answer',
          'Ответить',
          titleColor: Color(0xFF25D366),
        ),
        AndroidNotificationAction(
          'decline',
          'Отклонить',
          titleColor: Colors.red,
        ),
      ],
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'call_tone.caf',
      badgeNumber: 1,
      threadIdentifier: 'calls',
      categoryIdentifier: 'CALL',
    );
    
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notificationsPlugin.show(
      _generateNotificationId('call', callerUIN),
      isVideoCall ? 'Видеозвонок' : 'Звонок',
      '$callerName вызывает вас',
      details,
      payload: json.encode({
        'type': 'call',
        'callerUIN': callerUIN,
        'callerName': callerName,
        'isVideoCall': isVideoCall,
      }),
    );
  }

  // Show typing notification (heads-up)
  Future<void> showTypingNotification(String contactName) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'monolith_chat_messages',
      'Monolith Chat Messages',
      channelDescription: 'Уведомления о новых сообщениях',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Печатает...',
      timeoutAfter: 3000,
      showWhen: false,
      autoCancel: true,
      enableVibration: false,
      category: AndroidNotificationCategory.status,
    );
    
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(presentAlert: false),
    );
    
    await _notificationsPlugin.show(
      _generateNotificationId('typing', contactName),
      contactName,
      'печатает...',
      details,
      payload: 'typing',
    );
  }

  // Schedule reminder notification
  Future<void> scheduleReminder({
    required String title,
    required String body,
    required DateTime scheduleTime,
    required String reminderId,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      _generateNotificationId('reminder', reminderId),
      title,
      body,
      tz.TZDateTime.from(scheduleTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'monolith_chat_reminders',
          'Напоминания',
          channelDescription: 'Напоминания о сообщениях',
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: json.encode({
        'type': 'reminder',
        'reminderId': reminderId,
      }),
    );
  }

  // Cancel specific notification
  Future<void> cancelNotification(String chatId, String messageId) async {
    await _notificationsPlugin.cancel(
      _generateNotificationId(chatId, messageId),
    );
  }

  // Cancel all notifications for chat
  Future<void> cancelChatNotifications(String chatId) async {
    // In real implementation, you would track notification IDs
    // For simplicity, we cancel all
    await _notificationsPlugin.cancelAll();
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  // Get notification count
  Future<int> getNotificationCount() async {
    if (Platform.isAndroid) {
      return await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.getActiveNotificationCount() ?? 0;
    }
    return 0;
  }

  // Generate unique notification ID
  int _generateNotificationId(String prefix, String suffix) {
    final combined = '$prefix$suffix';
    var hash = 0;
    for (var i = 0; i < combined.length; i++) {
      hash = combined.codeUnitAt(i) + ((hash << 5) - hash);
    }
    return hash.abs() % 100000;
  }

  // Handle notification response
  static void _onDidReceiveNotificationResponse(
    NotificationResponse response,
  ) {
    final payload = response.payload;
    if (payload != null) {
      try {
        final data = json.decode(payload) as Map<String, dynamic>;
        // Handle different notification types
        switch (data['type']) {
          case 'message':
            // Navigate to chat
            _handleMessageNotification(data);
            break;
          case 'call':
            // Handle call
            _handleCallNotification(data);
            break;
          case 'reminder':
            // Handle reminder
            _handleReminderNotification(data);
            break;
        }
      } catch (e) {
        print('Error parsing notification payload: $e');
      }
    }
    
    // Handle action buttons
    if (response.actionId == 'reply') {
      // Show reply interface
      _showQuickReply(response.payload ?? '');
    } else if (response.actionId == 'mark_as_read') {
      // Mark as read
      _markAsRead(response.payload ?? '');
    } else if (response.actionId == 'answer') {
      // Answer call
      _answerCall(response.payload ?? '');
    } else if (response.actionId == 'decline') {
      // Decline call
      _declineCall(response.payload ?? '');
    }
  }

  // Handle iOS notification
  static void _onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) {
    // Handle iOS notification
  }

  // Notification handlers
  static void _handleMessageNotification(Map<String, dynamic> data) {
    // In real app, navigate to chat screen
    print('Navigate to chat: ${data['chatId']}');
  }
  
  static void _handleCallNotification(Map<String, dynamic> data) {
    print('Handle call from: ${data['callerName']}');
  }
  
  static void _handleReminderNotification(Map<String, dynamic> data) {
    print('Handle reminder: ${data['reminderId']}');
  }
  
  static void _showQuickReply(String payload) {
    print('Show quick reply for: $payload');
  }
  
  static void _markAsRead(String payload) {
    print('Mark as read: $payload');
  }
  
  static void _answerCall(String payload) {
    print('Answer call: $payload');
  }
  
  static void _declineCall(String payload) {
    print('Decline call: $payload');
  }
}