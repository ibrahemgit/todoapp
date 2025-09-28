import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

/// خدمة الإشعارات التفاعلية
/// توفر نظام إشعارات مستمرة مع تفاعل المستخدم
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static const int _notificationId = 1;
  static const String _channelId = 'todo_notifications';
  static const String _channelName = 'إشعارات المهام';
  static const String _channelDescription = 'إشعارات مستمرة للمهام المهمة';

  /// تهيئة خدمة الإشعارات
  Future<void> initializeNotifications() async {
    try {
      // تهيئة timezone
      tz.initializeTimeZones();
      
      // إعداد Android
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // إعداد iOS
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // إنشاء قناة الإشعارات
      await _createNotificationChannel();
      
      // طلب الصلاحيات
      await requestPermissions();
      
      print('تم تهيئة خدمة الإشعارات بنجاح');
    } catch (e) {
      print('خطأ في تهيئة الإشعارات: $e');
    }
  }

  /// إنشاء قناة الإشعارات
  Future<void> _createNotificationChannel() async {
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.max,
        enableVibration: true,
        enableLights: true,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('notification_sound'),
      );

      await _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  /// طلب الصلاحيات المطلوبة
  Future<bool> requestPermissions() async {
    try {
      // طلب صلاحية الإشعارات
      final notificationStatus = await Permission.notification.request();
      
      // طلب صلاحية الجدولة الدقيقة
      final scheduleStatus = await Permission.scheduleExactAlarm.request();
      
      // طلب صلاحية full screen intent
      final fullScreenStatus = await Permission.systemAlertWindow.request();
      
      // طلب صلاحية تجاهل تحسينات البطارية
      final batteryStatus = await Permission.ignoreBatteryOptimizations.request();
      
      final allGranted = notificationStatus.isGranted && 
                        scheduleStatus.isGranted && 
                        fullScreenStatus.isGranted && 
                        batteryStatus.isGranted;
      
      if (!allGranted) {
        print('لم يتم منح جميع الصلاحيات المطلوبة');
        print('الإشعارات: ${notificationStatus.isGranted}');
        print('الجدولة: ${scheduleStatus.isGranted}');
        print('النافذة الكاملة: ${fullScreenStatus.isGranted}');
        print('البطارية: ${batteryStatus.isGranted}');
      }
      
      return allGranted;
    } catch (e) {
      print('خطأ في طلب الصلاحيات: $e');
      return false;
    }
  }

  /// عرض إشعار مستمر
  Future<void> showPersistentNotification({
    required String title,
    required String body,
    String? taskId,
  }) async {
    try {
      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        ongoing: true,
        autoCancel: false,
        fullScreenIntent: true,
        enableVibration: true,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('notification_sound'),
        additionalFlags: Int32List.fromList([
          4, // AndroidNotificationFlag.insistent
        ]),
        actions: [
          AndroidNotificationAction(
            'complete_task',
            'إتمام المهمة',
            icon: DrawableResourceAndroidBitmap('@drawable/ic_check'),
            showsUserInterface: true,
          ),
          AndroidNotificationAction(
            'snooze_task',
            'تأجيل دقيقة',
            icon: DrawableResourceAndroidBitmap('@drawable/ic_snooze'),
            showsUserInterface: true,
          ),
        ],
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'notification_sound.wav',
        interruptionLevel: InterruptionLevel.critical,
        categoryIdentifier: 'TODO_CATEGORY',
      );

      final NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        _notificationId,
        title,
        body,
        details,
        payload: taskId ?? 'test_task',
      );

      print('تم عرض الإشعار المستمر بنجاح');
    } catch (e) {
      print('خطأ في عرض الإشعار: $e');
    }
  }

  /// إلغاء الإشعار
  Future<void> cancelNotification() async {
    try {
      await _notifications.cancel(_notificationId);
      print('تم إلغاء الإشعار');
    } catch (e) {
      print('خطأ في إلغاء الإشعار: $e');
    }
  }

  /// جدولة إشعار مؤجل
  Future<void> scheduleDelayedNotification({
    required String title,
    required String body,
    Duration delay = const Duration(minutes: 1),
    String? taskId,
  }) async {
    try {
      final scheduledTime = tz.TZDateTime.now(tz.local).add(delay);
      
      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        ongoing: true,
        autoCancel: false,
        fullScreenIntent: true,
        enableVibration: true,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('notification_sound'),
        additionalFlags: Int32List.fromList([
          4, // AndroidNotificationFlag.insistent
        ]),
        actions: [
          AndroidNotificationAction(
            'complete_task',
            'إتمام المهمة',
            icon: DrawableResourceAndroidBitmap('@drawable/ic_check'),
            showsUserInterface: true,
          ),
          AndroidNotificationAction(
            'snooze_task',
            'تأجيل دقيقة',
            icon: DrawableResourceAndroidBitmap('@drawable/ic_snooze'),
            showsUserInterface: true,
          ),
        ],
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'notification_sound.wav',
        interruptionLevel: InterruptionLevel.critical,
        categoryIdentifier: 'TODO_CATEGORY',
      );

      final NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.zonedSchedule(
        _notificationId,
        title,
        body,
        scheduledTime,
        details,
        payload: taskId ?? 'test_task',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );

      print('تم جدولة الإشعار المؤجل لـ ${delay.inMinutes} دقيقة');
    } catch (e) {
      print('خطأ في جدولة الإشعار المؤجل: $e');
    }
  }

  /// معالجة تفاعل الإشعار
  void _onNotificationTapped(NotificationResponse response) {
    final actionId = response.actionId;
    final payload = response.payload;

    print('تم التفاعل مع الإشعار: $actionId, payload: $payload');

    switch (actionId) {
      case 'complete_task':
        _handleCompleteTask(payload);
        break;
      case 'snooze_task':
        _handleSnoozeTask(payload);
        break;
      default:
        _handleDefaultTap(payload);
        break;
    }
  }

  /// معالجة إتمام المهمة
  void _handleCompleteTask(String? payload) {
    try {
      // إلغاء الإشعار
      cancelNotification();
      
      // إظهار رسالة نجاح
      _showSuccessMessage('تم إتمام المهمة بنجاح!');
      
      print('تم إتمام المهمة: $payload');
    } catch (e) {
      print('خطأ في معالجة إتمام المهمة: $e');
    }
  }

  /// معالجة تأجيل المهمة
  void _handleSnoozeTask(String? payload) {
    try {
      // إلغاء الإشعار الحالي
      cancelNotification();
      
      // جدولة إشعار جديد بعد دقيقة
      scheduleDelayedNotification(
        title: 'تذكير المهمة',
        body: 'حان وقت المهمة مرة أخرى!',
        delay: const Duration(minutes: 1),
        taskId: payload,
      );
      
      // إظهار رسالة تأجيل
      _showInfoMessage('تم تأجيل المهمة لمدة دقيقة');
      
      print('تم تأجيل المهمة: $payload');
    } catch (e) {
      print('خطأ في معالجة تأجيل المهمة: $e');
    }
  }

  /// معالجة النقر العادي على الإشعار
  void _handleDefaultTap(String? payload) {
    try {
      // يمكن إضافة منطق إضافي هنا
      print('تم النقر على الإشعار: $payload');
    } catch (e) {
      print('خطأ في معالجة النقر على الإشعار: $e');
    }
  }

  /// إظهار رسالة نجاح
  void _showSuccessMessage(String message) {
    // يمكن استخدام SnackBar أو Toast هنا
    print('✅ $message');
  }

  /// إظهار رسالة معلومات
  void _showInfoMessage(String message) {
    // يمكن استخدام SnackBar أو Toast هنا
    print('ℹ️ $message');
  }

  /// الحصول على حالة الصلاحيات
  Future<Map<String, bool>> getPermissionsStatus() async {
    try {
      final notificationStatus = await Permission.notification.isGranted;
      final scheduleStatus = await Permission.scheduleExactAlarm.isGranted;
      final fullScreenStatus = await Permission.systemAlertWindow.isGranted;
      final batteryStatus = await Permission.ignoreBatteryOptimizations.isGranted;

      return {
        'notification': notificationStatus,
        'schedule': scheduleStatus,
        'fullScreen': fullScreenStatus,
        'battery': batteryStatus,
      };
    } catch (e) {
      print('خطأ في الحصول على حالة الصلاحيات: $e');
      return {
        'notification': false,
        'schedule': false,
        'fullScreen': false,
        'battery': false,
      };
    }
  }

  /// فتح إعدادات التطبيق
  Future<void> openAppSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      print('خطأ في فتح إعدادات التطبيق: $e');
    }
  }
}
