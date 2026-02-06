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

  // Каналы уведомлений
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

  // Инициализация уведомлений
  Future<void> initialize() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
    
    // Создание каналов уведомлений (Android 8.0+)
    if (Platform.isAndroid) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_messagesChannel);
    }
  }

  // Показать уведомление о новом сообщении
  Future<void> showMessageNotification({
    required String title,
    required String body,
    required String chatId,
    required String messageId,
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
    );
    
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notificationsPlugin.show(
      _generateNotificationId(chatId, messageId),
      title,
      body,
      details,
      payload: 'chat:$chatId:message:$messageId',
    );
    
    // Вибрация
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(pattern: [0, 250, 250, 250]);
    }
  }

  // Показать уведомление о звонке
  Future<void> showCallNotification({
    required String callerName,
    required String callerUIN,
    required bool isVideoCall,
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
        ),
        AndroidNotificationAction(
          'decline',
          'Отклонить',
        ),
      ],
    );
    
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
    
    await _notificationsPlugin.show(
      _generateNotificationId('call', callerUIN),
      isVideoCall ? 'Видеозвонок' : 'Звонок',
      '$callerName вызывает вас',
      details,
      payload: 'call:$callerUIN:${isVideoCall ? 'video' : 'audio'}',
    );
  }

  // Отменить все уведомления
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  // Отменить уведомления для конкретного чата
  Future<void> cancelChatNotifications(String chatId) async {
    final pendingNotifications = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.getActiveNotifications();
    
    if (pendingNotifications != null) {
      for (final notification in pendingNotifications) {
        if (notification.payload?.contains('chat:$chatId') ?? false) {
          await _notificationsPlugin.cancel(notification.id);
        }
      }
    }
  }

  // Генерация ID уведомления
  int _generateNotificationId(String prefix, String suffix) {
    final combined = '$prefix$suffix';
    var hash = 0;
    for (var i = 0; i < combined.length; i++) {
      hash = combined.codeUnitAt(i) + ((hash << 5) - hash);
    }
    return hash.abs() % 100000;
  }

  // Обработка нажатия на уведомление
  static void _onDidReceiveNotificationResponse(
    NotificationResponse response,
  ) {
    final payload = response.payload;
    if (payload != null) {
      _handleNotificationPayload(payload);
    }
    
    // Обработка action кнопок
    if (response.actionId == 'reply') {
      _handleReplyAction(response.payload);
    } else if (response.actionId == 'mark_as_read') {
      _handleMarkAsReadAction(response.payload);
    } else if (response.actionId == 'answer') {
      _handleAnswerCallAction(response.payload);
    } else if (response.actionId == 'decline') {
      _handleDeclineCallAction(response.payload);
    }
  }

  static void _handleNotificationPayload(String payload) {
    if (payload.startsWith('chat:')) {
      final parts = payload.split(':');
      if (parts.length >= 3) {
        final chatId = parts[1];
        final messageId = parts[3];
        // TODO: Навигация к чату
        print('Navigate to chat: $chatId, message: $messageId');
      }
    } else if (payload.startsWith('call:')) {
      final parts = payload.split(':');
      if (parts.length >= 3) {
        final callerUIN = parts[1];
        final callType = parts[2];
        // TODO: Обработка звонка
        print('Handle call from: $callerUIN, type: $callType');
      }
    }
  }

  static void _handleReplyAction(String? payload) {
    // TODO: Показать интерфейс быстрого ответа
    print('Quick reply for: $payload');
  }

  static void _handleMarkAsReadAction(String? payload) {
    // TODO: Пометить как прочитанное
    print('Mark as read: $payload');
  }

  static void _handleAnswerCallAction(String? payload) {
    // TODO: Ответить на звонок
    print('Answer call: $payload');
  }

  static void _handleDeclineCallAction(String? payload) {
    // TODO: Отклонить звонок
    print('Decline call: $payload');
  }
}