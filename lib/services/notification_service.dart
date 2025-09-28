import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart' as permission_handler;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notification_settings_provider.dart';

  /// خدمة الإشعارات التفاعلية
  /// توفر نظام إشعارات مستمرة مع تفاعل المستخدم
  class NotificationService {
    static final NotificationService _instance = NotificationService._internal();
    factory NotificationService() => _instance;
    NotificationService._internal();

    // Provider container للوصول للإعدادات
    late ProviderContainer _container;
    bool _initialized = false;
    
    // Callback functions للتفاعل مع التطبيق
    Function(String)? _onTaskCompleted;
    Function(String)? _onTaskTapped;

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static const int _notificationId = 1;
  static const String _channelId = 'todo_notifications';
  static const String _channelName = 'إشعارات المهام';
  static const String _channelDescription = 'إشعارات مستمرة للمهام المهمة';

  /// تهيئة خدمة الإشعارات
  Future<void> initializeNotifications() async {
    try {
      // تهيئة Provider container
      if (!_initialized) {
        _container = ProviderContainer();
        _initialized = true;
      }
      
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
      final AndroidNotificationChannel channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.max,
        enableVibration: true,
        enableLights: true,
        playSound: true,
        sound: null, // استخدام الصوت الافتراضي للنظام
        showBadge: true,
        vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
      );

      await _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  /// الحصول على مدة التأجيل من الإعدادات
  int _getSnoozeMinutes() {
    try {
      if (_initialized) {
        final settings = _container.read(notificationSettingsProvider);
        return settings.snoozeMinutes;
      }
    } catch (e) {
      print('خطأ في الحصول على إعدادات التأجيل: $e');
    }
    // القيمة الافتراضية
    return 5;
  }

  /// الحصول على إعدادات الإشعارات الحالية
  NotificationSettings _getNotificationSettings() {
    try {
      if (_initialized) {
        return _container.read(notificationSettingsProvider);
      }
    } catch (e) {
      print('خطأ في الحصول على إعدادات الإشعارات: $e');
    }
    // الإعدادات الافتراضية
    return const NotificationSettings();
  }

  /// طلب الصلاحيات المطلوبة
  Future<bool> requestPermissions() async {
    try {
      // طلب صلاحية الإشعارات
      final notificationStatus = await permission_handler.Permission.notification.request();
      
      // طلب صلاحية الجدولة الدقيقة
      final scheduleStatus = await permission_handler.Permission.scheduleExactAlarm.request();
      
      // طلب صلاحية full screen intent
      final fullScreenStatus = await permission_handler.Permission.systemAlertWindow.request();
      
      // طلب صلاحية تجاهل تحسينات البطارية
      final batteryStatus = await permission_handler.Permission.ignoreBatteryOptimizations.request();
      
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

  /// تشغيل صوت الإشعار
  Future<void> _playNotificationSound() async {
    try {
      // استخدام SystemSound لتشغيل صوت الإشعار
      await SystemSound.play(SystemSoundType.alert);
      print('تم تشغيل صوت الإشعار');
    } catch (e) {
      print('خطأ في تشغيل الصوت: $e');
      // بديل بالاهتزاز
      await HapticFeedback.mediumImpact();
    }
  }

  /// عرض إشعار مستمر
  Future<void> showPersistentNotification({
    required String title,
    required String body,
    String? taskId,
  }) async {
    try {
      // الحصول على الإعدادات الحالية
      final settings = _getNotificationSettings();
      
      // تشغيل الصوت أولاً إذا كان مفعلاً
      if (settings.soundEnabled) {
        await _playNotificationSound();
      }
      
      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        ongoing: true,
        autoCancel: false,
        fullScreenIntent: true,
        enableVibration: settings.vibrationEnabled,
        playSound: settings.soundEnabled,
        sound: null, // استخدام الصوت الافتراضي للنظام
        vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
        additionalFlags: Int32List.fromList([
          4, // AndroidNotificationFlag.insistent
        ]),
        actions: [
          AndroidNotificationAction(
            'complete_task',
            'إتمام المهمة',
            showsUserInterface: true,
          ),
          AndroidNotificationAction(
            'snooze_task',
            'تأجيل ${_getSnoozeMinutes()} دقيقة',
            showsUserInterface: true,
          ),
        ],
      );

      final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: settings.soundEnabled,
        sound: null, // استخدام الصوت الافتراضي للنظام
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
      // الحصول على الإعدادات الحالية
      final settings = _getNotificationSettings();
      
      // تشغيل الصوت أولاً إذا كان مفعلاً
      if (settings.soundEnabled) {
        await _playNotificationSound();
      }
      
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
        enableVibration: settings.vibrationEnabled,
        playSound: settings.soundEnabled,
        sound: null, // استخدام الصوت الافتراضي للنظام
        vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
        additionalFlags: Int32List.fromList([
          4, // AndroidNotificationFlag.insistent
        ]),
        actions: [
          AndroidNotificationAction(
            'complete_task',
            'إتمام المهمة',
            showsUserInterface: true,
          ),
          AndroidNotificationAction(
            'snooze_task',
            'تأجيل ${_getSnoozeMinutes()} دقيقة',
            showsUserInterface: true,
          ),
        ],
      );

      final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: settings.soundEnabled,
        sound: null, // استخدام الصوت الافتراضي للنظام
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
      
      // استدعاء callback إذا كان موجوداً
      if (payload != null && _onTaskCompleted != null) {
        _onTaskCompleted!(payload);
      }
      
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
      
      // الحصول على مدة التأجيل من الإعدادات
      final snoozeMinutes = _getSnoozeMinutes();
      
      // جدولة إشعار جديد بعد المدة المحددة
      scheduleDelayedNotification(
        title: 'تذكير المهمة',
        body: 'حان وقت المهمة مرة أخرى!',
        delay: Duration(minutes: snoozeMinutes),
        taskId: payload,
      );
      
      // إظهار رسالة تأجيل
      _showInfoMessage('تم تأجيل المهمة لمدة $snoozeMinutes دقيقة');
      
      print('تم تأجيل المهمة: $payload لمدة $snoozeMinutes دقيقة');
    } catch (e) {
      print('خطأ في معالجة تأجيل المهمة: $e');
    }
  }

  /// معالجة النقر العادي على الإشعار
  void _handleDefaultTap(String? payload) {
    try {
      // استدعاء callback إذا كان موجوداً
      if (payload != null && _onTaskTapped != null) {
        _onTaskTapped!(payload);
      }
      
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
      final notificationStatus = await permission_handler.Permission.notification.isGranted;
      final scheduleStatus = await permission_handler.Permission.scheduleExactAlarm.isGranted;
      final fullScreenStatus = await permission_handler.Permission.systemAlertWindow.isGranted;
      final batteryStatus = await permission_handler.Permission.ignoreBatteryOptimizations.isGranted;

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
      // استخدام الدالة من permission_handler package
      await permission_handler.openAppSettings();
    } catch (e) {
      print('خطأ في فتح إعدادات التطبيق: $e');
    }
  }

  /// إرسال إشعار اختبار
  static Future<void> showTestNotification() async {
    try {
      final instance = NotificationService();
      await instance._showTestNotification();
    } catch (e) {
      print('خطأ في إرسال إشعار الاختبار: $e');
      rethrow;
    }
  }

  /// إرسال إشعار اختبار مع إعدادات مخصصة
  static Future<void> showTestNotificationWithSettings({
    required bool soundEnabled,
    required bool vibrationEnabled,
    required bool showOnLockScreen,
    required int snoozeMinutes,
  }) async {
    try {
      final instance = NotificationService();
      await instance._showTestNotificationWithSettings(
        soundEnabled: soundEnabled,
        vibrationEnabled: vibrationEnabled,
        showOnLockScreen: showOnLockScreen,
        snoozeMinutes: snoozeMinutes,
      );
    } catch (e) {
      print('خطأ في إرسال إشعار الاختبار: $e');
      rethrow;
    }
  }

  /// إرسال إشعار اختبار داخلي
  Future<void> _showTestNotification() async {
    try {
      // الحصول على الإعدادات الحالية
      final settings = _getNotificationSettings();
      
      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableLights: true,
        enableVibration: settings.vibrationEnabled,
        playSound: settings.soundEnabled,
        // استخدام الصوت الافتراضي
        ongoing: true, // إشعار مستمر
        autoCancel: false, // لا يُلغى تلقائياً
        category: AndroidNotificationCategory.reminder,
        visibility: settings.showOnLockScreen ? NotificationVisibility.public : NotificationVisibility.private,
        fullScreenIntent: true,
        actions: [
          AndroidNotificationAction(
            'complete_task',
            'إتمام المهمة',
            showsUserInterface: true,
          ),
          AndroidNotificationAction(
            'snooze_task',
            'تأجيل ${_getSnoozeMinutes()} دقيقة',
            showsUserInterface: true,
          ),
        ],
      );

      final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: settings.soundEnabled,
        // استخدام الصوت الافتراضي
        categoryIdentifier: 'todo_reminder',
        threadIdentifier: 'todo_test',
      );

      final NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        _notificationId + 1000, // استخدام ID مختلف للاختبار
        'اختبار الإشعار',
        'هذا إشعار اختبار للتطبيق',
        details,
        payload: 'test_notification_${DateTime.now().millisecondsSinceEpoch}',
      );

      print('تم إرسال إشعار الاختبار بنجاح');
    } catch (e) {
      print('خطأ في إرسال إشعار الاختبار: $e');
      rethrow;
    }
  }

  /// إرسال إشعار اختبار مع إعدادات مخصصة داخلي
  Future<void> _showTestNotificationWithSettings({
    required bool soundEnabled,
    required bool vibrationEnabled,
    required bool showOnLockScreen,
    required int snoozeMinutes,
  }) async {
    try {
      // الحصول على الإعدادات الحالية
      final settings = _getNotificationSettings();
      
      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableLights: true,
        enableVibration: settings.vibrationEnabled && vibrationEnabled,
        playSound: settings.soundEnabled && soundEnabled,
        ongoing: true, // إشعار مستمر
        autoCancel: false, // لا يُلغى تلقائياً
        category: AndroidNotificationCategory.reminder,
        visibility: (settings.showOnLockScreen && showOnLockScreen) ? NotificationVisibility.public : NotificationVisibility.private,
        fullScreenIntent: true,
        actions: [
          AndroidNotificationAction(
            'complete_task',
            'إتمام المهمة',
            showsUserInterface: true,
          ),
          AndroidNotificationAction(
            'snooze_task',
            'تأجيل ${settings.snoozeMinutes} دقيقة',
            showsUserInterface: true,
          ),
        ],
      );

      final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: settings.soundEnabled,
        categoryIdentifier: 'todo_reminder',
        threadIdentifier: 'todo_test',
      );

      final NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        _notificationId + 1000, // استخدام ID مختلف للاختبار
        'اختبار الإشعار',
        'هذا إشعار اختبار للتطبيق',
        details,
        payload: 'test_notification_${DateTime.now().millisecondsSinceEpoch}',
      );

      print('تم إرسال إشعار الاختبار مع الإعدادات المخصصة بنجاح');
    } catch (e) {
      print('خطأ في إرسال إشعار الاختبار مع الإعدادات: $e');
      rethrow;
    }
  }

  /// تعيين ProviderContainer من الخارج
  void setProviderContainer(ProviderContainer container) {
    _container = container;
    print('✅ تم تعيين ProviderContainer في خدمة الإشعارات');
  }

  /// تعيين callback لإتمام المهمة
  void setTaskCompletedCallback(Function(String) callback) {
    _onTaskCompleted = callback;
    print('✅ تم تعيين callback لإتمام المهمة');
  }

  /// تعيين callback للنقر على المهمة
  void setTaskTappedCallback(Function(String) callback) {
    _onTaskTapped = callback;
    print('✅ تم تعيين callback للنقر على المهمة');
  }

  /// جدولة إشعار مهمة
  Future<void> scheduleTaskNotification({
    required String taskTitle,
    required String taskDescription,
    required String taskId,
    required DateTime taskDueTime,
  }) async {
    try {
      // حساب الوقت المتبقي
      final now = DateTime.now();
      final timeDifference = taskDueTime.difference(now);
      
      if (timeDifference.isNegative) {
        print('المهمة متأخرة، لن يتم جدولة إشعار');
        return;
      }
      
      // جدولة الإشعار
      await scheduleDelayedNotification(
        title: taskTitle,
        body: taskDescription,
        delay: timeDifference,
        taskId: taskId,
      );
      
      print('تم جدولة إشعار للمهمة: $taskTitle في ${timeDifference.inMinutes} دقيقة');
    } catch (e) {
      print('خطأ في جدولة إشعار المهمة: $e');
    }
  }

  /// إلغاء إشعار مهمة
  Future<void> cancelTaskNotification(String taskId) async {
    try {
      await cancelNotification();
      print('تم إلغاء إشعار المهمة: $taskId');
    } catch (e) {
      print('خطأ في إلغاء إشعار المهمة: $e');
    }
  }

  /// إلغاء جميع الإشعارات
  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      print('تم إلغاء جميع الإشعارات');
    } catch (e) {
      print('خطأ في إلغاء جميع الإشعارات: $e');
    }
  }
}
