import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart' as permission_handler;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/notification_settings_provider.dart';
import '../providers/todo_provider.dart';
import 'notification_log_service.dart';
import '../models/notification_log_model.dart';

/// خدمة الإشعارات المحسنة للمرحلة التالية
/// تدعم التحكم في أوقات التأجيل ومعالجة المهام الفعلية
class EnhancedNotificationService {
  static final EnhancedNotificationService _instance = EnhancedNotificationService._internal();
  factory EnhancedNotificationService() => _instance;
  EnhancedNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static const String _channelId = 'enhanced_todo_notifications';
  static const String _channelName = 'إشعارات المهام المحسنة';
  static const String _channelDescription = 'إشعارات ذكية مع تحكم متقدم في التأجيل';
  

  // Provider container للوصول للإعدادات
  ProviderContainer? _container;
  bool _initialized = false;
  
  // Callback functions للتفاعل مع التطبيق
  Function(String)? _onTaskCompleted;
  Function(String)? _onTaskTapped;
  
  // Cache للإشعارات المعلقة لتحسين الأداء
  final Map<String, NotificationAppLaunchDetails> _notificationCache = {};
  bool _cacheInitialized = false;
  
  // منع الضغط المتكرر على أزرار الإشعارات
  final Set<String> _processingTasks = {};

  // إعدادات التأجيل
  static const List<Duration> _snoozeOptions = [
    Duration(minutes: 1),
    Duration(minutes: 5),
    Duration(minutes: 15),
    Duration(minutes: 30),
    Duration(hours: 1),
    Duration(hours: 2),
  ];

  static const List<String> _snoozeLabels = [
    'دقيقة واحدة',
    '5 دقائق',
    '15 دقيقة',
    '30 دقيقة',
    'ساعة واحدة',
    'ساعتان',
  ];

  /// تعيين ProviderContainer من الخارج
  void setProviderContainer(ProviderContainer container) {
    _container = container;
    print('✅ تم تعيين ProviderContainer في خدمة الإشعارات');
    
    // اختبار الحصول على الإعدادات فوراً
    try {
      final settings = _container!.read(notificationSettingsProvider);
      print('✅ تم التحقق من الإعدادات - مدة التأجيل: ${settings.snoozeMinutes} دقيقة');
    } catch (e) {
      print('❌ خطأ في التحقق من الإعدادات: $e');
    }
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

  /// تهيئة cache الإشعارات لتحسين الأداء
  Future<void> _initializeNotificationCache() async {
    if (_cacheInitialized) return;
    
    try {
      print('🔄 تهيئة cache الإشعارات...');
      
      // الحصول على تفاصيل الإشعارات المعلقة
      final NotificationAppLaunchDetails? notificationAppLaunchDetails =
          await _notifications.getNotificationAppLaunchDetails();
      
      if (notificationAppLaunchDetails != null) {
        final String? payload = notificationAppLaunchDetails.notificationResponse?.payload;
        if (payload != null) {
          _notificationCache[payload] = notificationAppLaunchDetails;
          print('✅ تم حفظ إشعار في cache: $payload');
        }
      }
      
      _cacheInitialized = true;
      print('✅ تم تهيئة cache الإشعارات بنجاح');
      
    } catch (e) {
      print('❌ خطأ في تهيئة cache الإشعارات: $e');
    }
  }

  /// الحصول على تفاصيل الإشعار من cache
  NotificationAppLaunchDetails? getCachedNotification(String payload) {
    return _notificationCache[payload];
  }

  /// مسح cache الإشعارات
  void clearNotificationCache() {
    _notificationCache.clear();
    _cacheInitialized = false;
    print('🗑️ تم مسح cache الإشعارات');
  }

  /// معالجة سريعة لأزرار الإشعار
  Future<void> handleNotificationActionFast(String payload, String actionId) async {
    try {
      // منع الضغط المتكرر
      if (_processingTasks.contains(payload)) {
        print('⚠️ المهمة قيد المعالجة بالفعل: $payload');
        return;
      }
      
      _processingTasks.add(payload);
      
      print('⚡ معالجة سريعة لإجراء الإشعار: $actionId للمهمة: $payload');
      
      // إغلاق الإشعار فوراً قبل المعالجة
      await _dismissNotificationFast(payload);
      
      // معالجة فورية بدون انتظار
      if (actionId == 'complete_task') {
        await _completeTaskFast(payload);
        await _showConfirmationNotification('تم إتمام المهمة', 'تم إتمام المهمة بنجاح');
      } else if (actionId == 'snooze_task') {
        await _snoozeTaskFast(payload);
        await _showConfirmationNotification('تم تأجيل المهمة', 'تم تأجيل المهمة بنجاح');
      } else if (actionId == 'tap_task') {
        await _openTaskFast(payload);
      }
      
      // إزالة المهمة من قائمة المعالجة
      _processingTasks.remove(payload);
      
    } catch (e) {
      print('❌ خطأ في المعالجة السريعة: $e');
      // إزالة المهمة من قائمة المعالجة في حالة الخطأ
      _processingTasks.remove(payload);
    }
  }

  /// إتمام المهمة بسرعة
  Future<void> _completeTaskFast(String taskId) async {
    try {
      // حفظ في SharedPreferences فوراً
      final prefs = await SharedPreferences.getInstance();
      final completedTasks = prefs.getStringList('completed_from_notification') ?? [];
      if (!completedTasks.contains(taskId)) {
        completedTasks.add(taskId);
        await prefs.setStringList('completed_from_notification', completedTasks);
      }
      
      // تحديث Provider إذا كان متاحاً
      if (_container != null) {
        try {
          final todoNotifier = _container!.read(todoListProvider.notifier);
          todoNotifier.toggleTodoStatus(taskId);
        } catch (e) {
          print('⚠️ لم يتم تحديث Provider، سيتم التحديث لاحقاً: $e');
        }
      }
      
      print('✅ تم إتمام المهمة بسرعة: $taskId');
    } catch (e) {
      print('❌ خطأ في إتمام المهمة السريع: $e');
    }
  }

  /// تأجيل المهمة بسرعة
  Future<void> _snoozeTaskFast(String taskId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final snoozeMinutes = prefs.getInt('snooze_minutes') ?? 15;
      
      // حفظ المهمة المؤجلة
      final snoozedTasks = prefs.getStringList('snoozed_tasks') ?? [];
      if (!snoozedTasks.contains(taskId)) {
        snoozedTasks.add(taskId);
        await prefs.setStringList('snoozed_tasks', snoozedTasks);
      }
      
      // جدولة إشعار جديد
      await scheduleSnoozeNotification(taskId, snoozeMinutes);
      
      print('⏰ تم تأجيل المهمة بسرعة: $taskId لـ $snoozeMinutes دقيقة');
    } catch (e) {
      print('❌ خطأ في تأجيل المهمة السريع: $e');
    }
  }

  /// فتح المهمة بسرعة
  Future<void> _openTaskFast(String taskId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('task_to_open', taskId);
      print('👆 تم حفظ المهمة للفتح: $taskId');
    } catch (e) {
      print('❌ خطأ في فتح المهمة السريع: $e');
    }
  }

  /// إغلاق الإشعار بسرعة
  Future<void> _dismissNotificationFast(String payload) async {
    try {
      final notificationId = _getNotificationId(payload);
      
      // إغلاق فوري بطرق متعددة
      await Future.wait([
        // طريقة 1: إغلاق باستخدام معرف المهمة
        _notifications.cancel(notificationId),
        
        // طريقة 2: إغلاق باستخدام الـ tag
        _notifications.cancel(notificationId, tag: 'persistent_task_$payload'),
        
        // طريقة 3: إغلاق جميع الإشعارات مع نفس الـ tag
        _notifications.cancel(0, tag: 'persistent_task_$payload'),
        
        // طريقة 4: إغلاق باستخدام معرفات مختلفة
        _notifications.cancel(notificationId + 1000),
        _notifications.cancel(notificationId + 2000),
        _notifications.cancel(notificationId + 3000),
      ]);
      
      // إغلاق من SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final notificationIds = prefs.getStringList('notification_ids_$payload') ?? [];
      
      if (notificationIds.isNotEmpty) {
        await Future.wait(
          notificationIds.map((id) => _notifications.cancel(int.parse(id)))
        );
        await prefs.remove('notification_ids_$payload');
      }
      
      // إغلاق جميع الإشعارات كحل أخير
      await _notifications.cancelAll();
      
      print('🗑️ تم إغلاق الإشعار بسرعة: $payload');
    } catch (e) {
      print('❌ خطأ في إغلاق الإشعار السريع: $e');
      // محاولة إغلاق جميع الإشعارات كحل أخير
      try {
        await _notifications.cancelAll();
      } catch (e2) {
        print('❌ فشل حتى إغلاق جميع الإشعارات: $e2');
      }
    }
  }

  /// معالجة الإشعارات عند فتح التطبيق
  Future<void> _handleNotificationAppLaunch() async {
    try {
      // استخدام cache إذا كان متاحاً، وإلا الحصول على التفاصيل مباشرة
      NotificationAppLaunchDetails? notificationAppLaunchDetails;
      
      if (_cacheInitialized && _notificationCache.isNotEmpty) {
        // استخدام أول إشعار من cache
        notificationAppLaunchDetails = _notificationCache.values.first;
        print('📱 استخدام إشعار من cache');
      } else {
        notificationAppLaunchDetails = await _notifications.getNotificationAppLaunchDetails();
        print('📱 الحصول على إشعار مباشرة');
      }

      if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
        final String? payload = notificationAppLaunchDetails!.notificationResponse?.payload;
        final String? actionId = notificationAppLaunchDetails.notificationResponse?.actionId;
        
        if (payload != null) {
          print('تم فتح التطبيق من إشعار: $payload, action: $actionId');
          
          // معالجة الإشعار حسب نوع الإجراء
          if (actionId == 'complete_task') {
            await _saveTaskToComplete(payload);
            print('تم حفظ المهمة المطلوب إتمامها: $payload');
          } else if (actionId == 'snooze_task') {
            final snoozeMinutes = _getSnoozeMinutes();
            await _saveTaskToSnooze(payload, snoozeMinutes);
            print('تم حفظ المهمة المطلوب تأجيلها: $payload لـ $snoozeMinutes دقيقة');
          } else {
            // النقر العادي على الإشعار
            await _saveTaskToOpen(payload);
            print('تم حفظ المهمة المطلوب فتحها: $payload');
          }
          
          // معالجة الإشعار حسب نوعه
          await _processNotificationPayload(payload);
        }
      }
    } catch (e) {
      print('خطأ في معالجة إشعار فتح التطبيق: $e');
    }
  }

  /// معالجة payload الإشعار
  Future<void> _processNotificationPayload(String payload) async {
    try {
      // تحليل payload لفهم نوع الإجراء
      if (payload.startsWith('complete_')) {
        final taskId = payload.substring(9); // إزالة 'complete_'
        print('إتمام المهمة من الإشعار: $taskId');
        if (_onTaskCompleted != null) {
          _onTaskCompleted!(taskId);
        } else {
          _completeTaskInProvider(taskId);
        }
      } else if (payload.startsWith('snooze_')) {
        final taskId = payload.substring(7); // إزالة 'snooze_'
        print('تأجيل المهمة من الإشعار: $taskId');
        
        // جدولة إشعار تأجيل جديد
        final snoozeMinutes = _getSnoozeMinutes();
        final snoozeDuration = Duration(minutes: snoozeMinutes);
        await _scheduleSnoozeNotification(taskId, snoozeDuration);
      } else {
        // النقر العادي على الإشعار
        print('فتح تفاصيل المهمة من الإشعار: $payload');
        if (_onTaskTapped != null) {
          _onTaskTapped!(payload);
        } else {
          _openTaskDetails(payload);
        }
      }
    } catch (e) {
      print('خطأ في معالجة payload الإشعار: $e');
    }
  }

  /// معالجة المهام المحفوظة عند فتح التطبيق مع إشعارات تأكيد
  Future<void> processPendingTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // معالجة المهمة المطلوب إتمامها
      final taskToComplete = prefs.getString('task_to_complete');
      if (taskToComplete != null) {
        print('معالجة المهمة المطلوب إتمامها: $taskToComplete');
        
        // الحصول على عنوان المهمة قبل الإتمام
        String taskTitle = 'مهمة غير معروفة';
        if (_container != null) {
          try {
            final todos = _container!.read(todoListProvider);
            final task = todos.firstWhere((todo) => todo.id == taskToComplete);
            taskTitle = task.title;
          } catch (e) {
            print('لم يتم العثور على المهمة: $e');
          }
        }
        
        // إتمام المهمة
        if (_onTaskCompleted != null) {
          _onTaskCompleted!(taskToComplete);
        } else {
          _completeTaskInProvider(taskToComplete);
        }
        
        // إرسال إشعار تأكيد الإتمام داخل التطبيق
        await _showTaskCompletionConfirmation(taskTitle);
        
        await prefs.remove('task_to_complete');
        await prefs.remove('action_type');
      }
      
      // معالجة المهمة المطلوب تأجيلها
      final taskToSnooze = prefs.getString('task_to_snooze');
      final snoozeMinutes = prefs.getInt('snooze_minutes') ?? 5;
      if (taskToSnooze != null) {
        print('معالجة المهمة المطلوب تأجيلها: $taskToSnooze لـ $snoozeMinutes دقيقة');
        
        // الحصول على عنوان المهمة قبل التأجيل
        String taskTitle = 'مهمة غير معروفة';
        if (_container != null) {
          try {
            final todos = _container!.read(todoListProvider);
            final task = todos.firstWhere((todo) => todo.id == taskToSnooze);
            taskTitle = task.title;
          } catch (e) {
            print('لم يتم العثور على المهمة: $e');
          }
        }
        
        // جدولة إشعار تأجيل جديد
        final snoozeDuration = Duration(minutes: snoozeMinutes);
        await _scheduleSnoozeNotification(taskToSnooze, snoozeDuration);
        
        // إرسال إشعار تأكيد التأجيل داخل التطبيق
        await _showTaskSnoozeConfirmation(taskTitle, snoozeMinutes);
        
        await prefs.remove('task_to_snooze');
        await prefs.remove('snooze_minutes');
        await prefs.remove('action_type');
      }
      
      // معالجة المهمة المطلوب فتحها
      final taskToOpen = prefs.getString('task_to_open');
      if (taskToOpen != null) {
        print('معالجة المهمة المطلوب فتحها: $taskToOpen');
        if (_onTaskTapped != null) {
          _onTaskTapped!(taskToOpen);
        } else {
          _openTaskDetails(taskToOpen);
        }
        await prefs.remove('task_to_open');
      }
      
    } catch (e) {
      print('خطأ في معالجة المهام المحفوظة: $e');
    }
  }

  /// تحديث الإشعارات الموجودة بالإعدادات الجديدة
  Future<void> updateNotificationSettings() async {
    try {
      if (_initialized && _container != null) {
        final settings = _container!.read(notificationSettingsProvider);
        print('تم تحديث إعدادات الإشعارات - مدة التأجيل: ${settings.snoozeMinutes} دقيقة');
        
        // إلغاء جميع الإشعارات الموجودة
        await cancelAllNotifications();
        
        // إعادة إنشاء الإشعارات بالإعدادات الجديدة
        print('تم إلغاء جميع الإشعارات الموجودة لإعادة إنشائها بالإعدادات الجديدة');
      }
    } catch (e) {
      print('خطأ في تحديث إعدادات الإشعارات: $e');
    }
  }

  /// إعادة إنشاء الإشعارات الموجودة بالإعدادات الجديدة
  Future<void> refreshNotificationsWithNewSettings() async {
    try {
      if (_initialized && _container != null) {
        final settings = _container!.read(notificationSettingsProvider);
        print('تحديث إعدادات الإشعارات - مدة التأجيل: ${settings.snoozeMinutes} دقيقة');
        
        // إلغاء جميع الإشعارات الموجودة
        await cancelAllNotifications();
        
        print('تم تحديث إعدادات الإشعارات - ستُطبق على الإشعارات الجديدة');
      }
    } catch (e) {
      print('خطأ في تحديث إعدادات الإشعارات: $e');
    }
  }

  /// طلب الإذونات المطلوبة للإشعارات
  Future<void> _requestPermissions() async {
    try {
      print('🔐 بدء طلب الإذونات...');
      
      // طلب إذونات Android
      if (Platform.isAndroid) {
        await _requestAndroidPermissions();
      }
      
      // طلب إذونات iOS
      if (Platform.isIOS) {
        await _requestIOSPermissions();
      }
      
    } catch (e) {
      print('❌ خطأ في طلب الإذونات: $e');
    }
  }

  /// طلب إذونات Android الأساسية والإضافية
  Future<void> _requestAndroidPermissions() async {
    try {
      print('🤖 طلب إذونات Android الأساسية والإضافية...');
      
      // طلب إذن الإشعارات (مطلوب لـ Android 13+)
      final notificationStatus = await permission_handler.Permission.notification.request();
      print('🤖 إذن الإشعارات: $notificationStatus');
      
      // طلب إذن جدولة التنبيهات الدقيقة (مطلوب للجدولة الدقيقة)
      final alarmStatus = await permission_handler.Permission.scheduleExactAlarm.request();
      print('🤖 إذن التنبيهات الدقيقة: $alarmStatus');
      
      // طلب إذن تجاهل تحسين البطارية (لضمان عمل الإشعارات)
      try {
        final batteryStatus = await permission_handler.Permission.ignoreBatteryOptimizations.request();
        print('🤖 إذن تجاهل تحسين البطارية: $batteryStatus');
      } catch (e) {
        print('⚠️ لا يمكن طلب إذن تحسين البطارية: $e');
      }
      
      // طلب إذونات إضافية للإشعارات المستمرة
      try {
        final systemAlertStatus = await permission_handler.Permission.systemAlertWindow.request();
        print('🤖 إذن النوافذ المنبثقة: $systemAlertStatus');
      } catch (e) {
        print('⚠️ لا يمكن طلب إذن النوافذ المنبثقة: $e');
      }
      
      // إزالة wakeLock لعدم توافقه مع الإصدار الحالي
      
    } catch (e) {
      print('❌ خطأ في طلب إذونات Android: $e');
    }
  }

  /// طلب إذونات iOS
  Future<void> _requestIOSPermissions() async {
    try {
      print('🍎 طلب إذونات iOS...');
      
      // طلب إذن الإشعارات
      final notificationStatus = await permission_handler.Permission.notification.request();
      print('🍎 إذن الإشعارات: $notificationStatus');
      
    } catch (e) {
      print('❌ خطأ في طلب إذونات iOS: $e');
    }
  }

  /// تهيئة خدمة الإشعارات المحسنة
  Future<void> initializeNotifications() async {
    try {
      // تهيئة Provider container إذا لم يتم تعيينه من الخارج
      if (!_initialized) {
        if (_container == null) {
          _container = ProviderContainer();
        }
        _initialized = true;
      }
      
      // طلب الإذونات المطلوبة
      await _requestPermissions();
      
      // تهيئة timezone
      tz.initializeTimeZones();
      
      // تهيئة cache الإشعارات
      await _initializeNotificationCache();
      
      // معالجة الإشعارات عند فتح التطبيق
      await _handleNotificationAppLaunch();
      
      // إعداد Android مع تحسينات للأجهزة الحقيقية
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      
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

      final bool? initialized = await _notifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      
      if (initialized == true) {
        print('✅ تم تهيئة الإشعارات بنجاح');
      } else {
        print('❌ فشل في تهيئة الإشعارات');
      }

      // إنشاء قناة الإشعارات المحسنة
      await _createEnhancedNotificationChannel();
      
      // طلب الصلاحيات
      await requestPermissions();
      
      print('تم تهيئة خدمة الإشعارات المحسنة بنجاح');
    } catch (e) {
      print('خطأ في تهيئة الإشعارات المحسنة: $e');
    }
  }

  /// الحصول على مدة التأجيل من الإعدادات
  int _getSnoozeMinutes() {
    print('🔍 محاولة الحصول على مدة التأجيل...');
    print('🔧 حالة التهيئة: $_initialized');
    print('🔧 حالة Container: ${_container != null}');
    
    try {
      if (_initialized && _container != null) {
        final settings = _container!.read(notificationSettingsProvider);
        print('✅ تم الحصول على مدة التأجيل من الإعدادات: ${settings.snoozeMinutes} دقيقة');
        return settings.snoozeMinutes;
      } else {
        print('⚠️ Container غير متاح - حالة التهيئة: $_initialized, Container: ${_container != null}');
      }
    } catch (e) {
      print('❌ خطأ في الحصول على إعدادات التأجيل: $e');
    }
    // القيمة الافتراضية
    print('🔄 استخدام القيمة الافتراضية للتأجيل: 5 دقائق');
    return 5;
  }

  /// الحصول على مدة التذكير من الإعدادات
  int _getReminderMinutes() {
    print('🔍 محاولة الحصول على مدة التذكير...');
    print('🔧 حالة التهيئة: $_initialized');
    print('🔧 حالة Container: ${_container != null}');
    
    try {
      if (_initialized && _container != null) {
        final settings = _container!.read(notificationSettingsProvider);
        print('✅ تم الحصول على مدة التذكير من الإعدادات: ${settings.reminderBeforeDueMinutes} دقيقة');
        return settings.reminderBeforeDueMinutes;
      } else {
        print('⚠️ Container غير متاح - حالة التهيئة: $_initialized, Container: ${_container != null}');
      }
    } catch (e) {
      print('❌ خطأ في الحصول على إعدادات التذكير: $e');
    }
    // القيمة الافتراضية
    print('🔄 استخدام القيمة الافتراضية للتذكير: 15 دقيقة');
    return 15;
  }


  /// إنشاء قناة الإشعارات المحسنة
  Future<void> _createEnhancedNotificationChannel() async {
    if (Platform.isAndroid) {
      // قناة الإشعارات الرئيسية للمهام
      final AndroidNotificationChannel mainChannel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.max,
        enableVibration: true,
        enableLights: true,
        playSound: true,
        showBadge: true,
        sound: null, // استخدام الصوت الافتراضي
        vibrationPattern: Int64List.fromList([0, 1000, 500, 1000, 500, 1000]),
      );

      // قناة إشعارات التأكيد
      final AndroidNotificationChannel confirmationChannel = AndroidNotificationChannel(
        'confirmation_channel',
        'تأكيدات الإجراءات',
        description: 'إشعارات تأكيد الإجراءات',
        importance: Importance.high, // أهمية عالية
        enableVibration: true, // تفعيل الاهتزاز
        enableLights: true,
        playSound: true, // تفعيل الصوت
        showBadge: true,
      );

      final androidImplementation = _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(mainChannel);
        await androidImplementation.createNotificationChannel(confirmationChannel);
        print('✅ تم إنشاء قنوات الإشعارات المحسنة');
      } else {
        print('❌ فشل في الحصول على تطبيق Android للإشعارات');
      }
    }
  }

  // تم إزالة قناة إشعارات التأكيد لعدم الحاجة إليها

  /// طلب الصلاحيات المطلوبة
  Future<bool> requestPermissions() async {
    try {
      // طلب صلاحية الإشعارات (مطلوب لـ Android 13+)
      final notificationStatus = await permission_handler.Permission.notification.request();
      
      // طلب صلاحية الجدولة الدقيقة (مطلوب للجدولة الدقيقة)
      final scheduleStatus = await permission_handler.Permission.scheduleExactAlarm.request();
      
      // طلب صلاحية تجاهل تحسين البطارية (لضمان عمل الإشعارات)
      final batteryStatus = await permission_handler.Permission.ignoreBatteryOptimizations.request();
      
      // طلب صلاحيات إضافية للإشعارات المستمرة
      final systemAlertStatus = await permission_handler.Permission.systemAlertWindow.request();
      
      final allGranted = notificationStatus.isGranted && scheduleStatus.isGranted;
      
      print('حالة الصلاحيات:');
      print('الإشعارات: ${notificationStatus.isGranted}');
      print('الجدولة: ${scheduleStatus.isGranted}');
      print('البطارية: ${batteryStatus.isGranted}');
      print('النوافذ المنبثقة: ${systemAlertStatus.isGranted}');
      
      if (!allGranted) {
        print('⚠️ لم يتم منح جميع الصلاحيات المطلوبة');
        print('قد لا تعمل الإشعارات بشكل صحيح');
      }
      
      return allGranted;
    } catch (e) {
      print('❌ خطأ في طلب الصلاحيات: $e');
      return false;
    }
  }

  /// تشغيل صوت الإشعار المحسن
  Future<void> _playNotificationSound() async {
    try {
      print('🔊 بدء تشغيل صوت الإشعار المحسن...');
      
      // 5 أصوات متتالية قوية
      for (int i = 0; i < 5; i++) {
        await SystemSound.play(SystemSoundType.alert);
        await Future.delayed(Duration(milliseconds: 400));
      }
      
      // أصوات متنوعة للتأكيد
      await SystemSound.play(SystemSoundType.click);
      await Future.delayed(Duration(milliseconds: 200));
      await SystemSound.play(SystemSoundType.alert);
      
      // اهتزاز قوي ومتدرج
      await HapticFeedback.heavyImpact();
      await Future.delayed(Duration(milliseconds: 150));
      await HapticFeedback.mediumImpact();
      await Future.delayed(Duration(milliseconds: 150));
      await HapticFeedback.lightImpact();
      
      print('✅ تم تشغيل صوت الإشعار المحسن بنجاح');
    } catch (e) {
      print('❌ خطأ في تشغيل الصوت: $e');
      // بديل بالاهتزاز فقط
      try {
        for (int i = 0; i < 5; i++) {
          await HapticFeedback.heavyImpact();
          await Future.delayed(Duration(milliseconds: 200));
        }
        print('📳 تم تشغيل الاهتزاز كبديل');
      } catch (e2) {
        print('❌ فشل حتى الاهتزاز: $e2');
      }
    }
  }

  /// عرض إشعار مهمة محسن مع أزرار تفاعلية ملونة ومستمر على الشاشة
  Future<void> showTaskNotification({
    required String taskTitle,
    required String taskDescription,
    required String taskId,
    required DateTime taskDueTime,
    Duration? advanceNotificationTime,
  }) async {
    try {
      print('🔔 بدء إنشاء إشعار مهمة مستمر: $taskTitle');
      print('🔧 معرف المهمة: $taskId');
      
      // استخدام معرف ثابت ومميز للإشعار
      final notificationId = _getNotificationId(taskId);
      print('🔧 معرف الإشعار: $notificationId');
      
      // إنشاء الأزرار التفاعلية المحسنة
      List<AndroidNotificationAction> actions = [
        AndroidNotificationAction(
          'complete_task',
          '✅ إتمام المهمة',
          titleColor: const Color(0xFF4CAF50), // لون أخضر للإتمام
          showsUserInterface: true,
        ),
      ];

      // إضافة زر التأجيل مع المدة الديناميكية ولون مميز
      final snoozeMinutes = _getSnoozeMinutes();
      print('إنشاء إشعار مهمة - مدة التأجيل: $snoozeMinutes دقيقة');
      actions.add(
        AndroidNotificationAction(
          'snooze_task',
          '⏰ تأجيل $snoozeMinutes دقيقة',
          titleColor: const Color(0xFFFF9800), // لون برتقالي للتأجيل
          showsUserInterface: true,
        ),
      );

      // استخدام الدالة المحسنة للإشعارات المستمرة
      await _showPersistentNotification(
        notificationId: notificationId,
        title: taskTitle,
        body: taskDescription,
        actions: actions,
        taskId: taskId,
      );

      print('تم عرض إشعار المهمة المستمر بنجاح: $taskTitle');
      
      // تسجيل نجاح الإشعار في السجل
      await NotificationLogService.addQuickLog(
        title: 'إشعار مهمة مستمر',
        description: 'تم عرض إشعار مهمة مستمر بنجاح: $taskTitle',
        type: NotificationLogType.info,
        taskId: taskId,
        taskTitle: taskTitle,
      );
      
    } catch (e) {
      print('خطأ في عرض إشعار المهمة: $e');
      
      // تسجيل الخطأ في سجل الإشعارات
      await NotificationLogService.addQuickLog(
        title: 'خطأ في إرسال إشعار مهمة',
        description: 'فشل في إرسال إشعار للمهمة: $taskTitle - $e',
        type: NotificationLogType.error,
        taskId: taskId,
        taskTitle: taskTitle,
      );
    }
  }

  /// جدولة إشعار مهمة قبل موعدها مع أزرار تفاعلية ملونة ومستمر على الشاشة
  Future<void> scheduleTaskNotification({
    required String taskTitle,
    required String taskDescription,
    required String taskId,
    required DateTime taskDueTime,
    Duration? advanceNotificationTime,
  }) async {
    try {
      // الحصول على مدة التذكير من الإعدادات
      final reminderMinutes = _getReminderMinutes();
      final actualAdvanceTime = advanceNotificationTime ?? Duration(minutes: reminderMinutes);
      final notificationTime = taskDueTime.subtract(actualAdvanceTime);
      
      // التأكد من أن وقت الإشعار في المستقبل
      if (notificationTime.isBefore(DateTime.now())) {
        print('وقت الإشعار في الماضي، سيتم عرض الإشعار فوراً');
        await showTaskNotification(
          taskTitle: taskTitle,
          taskDescription: taskDescription,
          taskId: taskId,
          taskDueTime: taskDueTime,
        );
        return;
      }

      // إنشاء الأزرار التفاعلية الملونة للإشعار المجدول بدون contextual
      List<AndroidNotificationAction> actions = [
        AndroidNotificationAction(
          'complete_task',
          '✅ إتمام المهمة',
          titleColor: const Color(0xFF4CAF50), // لون أخضر للإتمام
          showsUserInterface: true,
        ),
      ];

      // إضافة زر التأجيل مع المدة الديناميكية ولون مميز
      final snoozeMinutes = _getSnoozeMinutes();
      print('جدولة إشعار مهمة - مدة التأجيل: $snoozeMinutes دقيقة');
      actions.add(
        AndroidNotificationAction(
          'snooze_task',
          '⏰ تأجيل $snoozeMinutes دقيقة',
          titleColor: const Color(0xFFFF9800), // لون برتقالي للتأجيل
          showsUserInterface: true,
        ),
      );

      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        ongoing: true, // إشعار مستمر - لا يمكن إزالته بالسحب
        autoCancel: false, // لا يختفي تلقائياً
        fullScreenIntent: true, // يظهر على الشاشة الكاملة
        enableVibration: true,
        playSound: true,
        sound: null, // استخدام الصوت الافتراضي
        color: const Color(0xFF2196F3), // لون أزرق للإشعار
        ledColor: const Color(0xFF2196F3), // لون LED أزرق
        ledOnMs: 1000,
        ledOffMs: 500,
        vibrationPattern: Int64List.fromList([0, 1000, 500, 1000, 500, 1000]),
        additionalFlags: Int32List.fromList([4, 32]), // insistent + no_clear
        actions: actions,
        category: AndroidNotificationCategory.alarm, // تصنيف الإشعار كتنبيه
        visibility: NotificationVisibility.public, // مرئي على شاشة القفل
        showWhen: true,
        when: DateTime.now().millisecondsSinceEpoch,
        timeoutAfter: null, // لا يوجد timeout للإشعار
        tag: 'persistent_task_$taskId', // علامة مميزة للإشعار
        colorized: true, // تفعيل التلوين
        ticker: 'تذكير مهمة', // نص التمرير
        onlyAlertOnce: false, // تنبيه مستمر
        silent: false, // ليس صامت
        usesChronometer: false,
        showProgress: false,
        maxProgress: 0,
        progress: 0,
        indeterminate: false,
        styleInformation: const BigTextStyleInformation(
          '',
          htmlFormatBigText: true,
          contentTitle: '',
          htmlFormatContentTitle: true,
          summaryText: 'تذكير مهم: لا تنسى إنجاز مهامك المهمة',
          htmlFormatSummaryText: true,
        ),
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final scheduledTime = tz.TZDateTime.from(notificationTime, tz.local);

      // استخدام معرف ثابت ومميز للإشعار
      final notificationId = _getNotificationId(taskId);
      print('🔧 معرف الإشعار المجدول المستمر: $notificationId');

      await _notifications.zonedSchedule(
        notificationId, // استخدام معرف ثابت ومميز
        taskTitle,
        taskDescription,
        scheduledTime,
        details,
        payload: taskId,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );

      print('تم جدولة إشعار المهمة المستمر لـ ${actualAdvanceTime.inMinutes} دقيقة قبل الموعد: $taskTitle');
      
      // تسجيل جدولة الإشعار في السجل
      await NotificationLogService.addQuickLog(
        title: 'تم جدولة إشعار',
        description: 'تم جدولة إشعار مستمر للمهمة "$taskTitle" لـ ${actualAdvanceTime.inMinutes} دقيقة قبل الموعد',
        type: NotificationLogType.notificationScheduled,
        taskId: taskId,
        taskTitle: taskTitle,
      );
    } catch (e) {
      print('خطأ في جدولة إشعار المهمة: $e');
      
      // تسجيل الخطأ في سجل الإشعارات
      await NotificationLogService.addQuickLog(
        title: 'خطأ في جدولة إشعار',
        description: 'فشل في جدولة إشعار للمهمة: $taskTitle - $e',
        type: NotificationLogType.error,
        taskId: taskId,
        taskTitle: taskTitle,
      );
    }
  }

  /// إلغاء إشعار مهمة محددة
  Future<void> cancelTaskNotification(String taskId) async {
    try {
      final notificationId = _getNotificationId(taskId);
      
      // طريقة خاصة لإلغاء الإشعارات المستمرة
      await _cancelPersistentNotification(notificationId, taskId);
      
      print('تم إلغاء إشعار المهمة: $taskId (معرف الإشعار: $notificationId)');
      
      // لا نحتاج لتسجيل إلغاء الإشعار في السجل
    } catch (e) {
      print('خطأ في إلغاء إشعار المهمة: $e');
      
      // تسجيل الخطأ في سجل الإشعارات
      await NotificationLogService.addQuickLog(
        title: 'خطأ في إلغاء إشعار',
        description: 'فشل في إلغاء إشعار المهمة: $taskId - $e',
        type: NotificationLogType.error,
        taskId: taskId,
      );
    }
  }

  /// إلغاء الإشعارات المستمرة بطريقة خاصة
  Future<void> _cancelPersistentNotification(int notificationId, String taskId) async {
    try {
      // طريقة 1: إلغاء عادي
      await _notifications.cancel(notificationId);
      
      // طريقة 2: إلغاء باستخدام الـ tag
      await _notifications.cancel(notificationId, tag: 'persistent_task_$taskId');
      
      // طريقة 3: إلغاء باستخدام معرف 0 مع الـ tag
      await _notifications.cancel(0, tag: 'persistent_task_$taskId');
      
      // طريقة 4: إنشاء إشعار فارغ لإلغاء الإشعار المستمر
      await _notifications.show(
        notificationId,
        '',
        '',
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.min,
            priority: Priority.min,
            ongoing: false,
            autoCancel: true,
            silent: true,
            showWhen: false,
            when: DateTime.now().millisecondsSinceEpoch,
          ),
        ),
      );
      
      // طريقة 5: إلغاء الإشعار الفارغ
      await _notifications.cancel(notificationId);
      
      // طريقة 6: إلغاء باستخدام معرف مختلف
      await _notifications.cancel(notificationId + 100000);
      
      // طريقة 7: إلغاء جميع الإشعارات مع نفس الـ tag
      await _notifications.cancelAll();
      
      print('تم إلغاء الإشعار المستمر: $notificationId للمهمة: $taskId');
    } catch (e) {
      print('خطأ في إلغاء الإشعار المستمر: $e');
      throw e;
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


  /// معالجة تفاعل الإشعار المحسن
  void _onNotificationTapped(NotificationResponse response) {
    final actionId = response.actionId;
    final payload = response.payload;

    print('تم التفاعل مع الإشعار: $actionId, payload: $payload');

    if (payload == null) return;

    switch (actionId) {
      case 'complete_task':
        _handleCompleteTask(payload);
        break;
      case 'snooze_task':
        _handleSnoozeTask(payload, actionId ?? 'snooze_task');
        break;
      case null:
        // النقر العادي على الإشعار
        _handleTaskTap(payload);
        break;
      default:
        // معالجة أزرار التأجيل القديمة (للتوافق)
        if (actionId.startsWith('snooze_')) {
          _handleSnoozeTask(payload, actionId);
        }
        break;
    }
  }

  /// معالجة إتمام المهمة
  void _handleCompleteTask(String taskId) async {
    try {
      // إلغاء الإشعار أولاً
      await cancelTaskNotification(taskId);
      
      // تشغيل صوت التأكيد
      SystemSound.play(SystemSoundType.alert);
      
      // إظهار رسالة نجاح
      _showSuccessMessage('تم إتمام المهمة بنجاح!');
      
      print('تم إتمام المهمة: $taskId');
      
      // تسجيل الحدث في سجل الإشعارات (بدون await)
      NotificationLogService.addQuickLog(
        title: 'تم إتمام مهمة من الإشعار',
        description: 'تم إتمام المهمة: $taskId من خلال الإشعار',
        type: NotificationLogType.taskCompleted,
        taskId: taskId,
      );
      
      // إتمام المهمة باستخدام callback أو TodoProvider
      if (_onTaskCompleted != null) {
        _onTaskCompleted!(taskId);
        print('تم إتمام المهمة باستخدام callback: $taskId');
      } else {
        // حفظ المهمة في SharedPreferences للتعامل معها عند فتح التطبيق
        _saveTaskToComplete(taskId);
        _completeTaskInProvider(taskId);
      }
      
    } catch (e) {
      print('خطأ في معالجة إتمام المهمة: $e');
      // في حالة الخطأ، احفظ المهمة للتعامل معها لاحقاً
      _saveTaskToComplete(taskId);
    }
  }

  /// إتمام المهمة في TodoProvider
  void _completeTaskInProvider(String taskId) {
    try {
      if (_container != null) {
        // الحصول على TodoProvider من Container
        final todoNotifier = _container!.read(todoListProvider.notifier);
        
        // إتمام المهمة
        todoNotifier.toggleTodoStatus(taskId);
        
        print('تم إتمام المهمة في TodoProvider: $taskId');
      } else {
        print('Container غير متاح لإتمام المهمة');
      }
    } catch (e) {
      print('خطأ في إتمام المهمة في TodoProvider: $e');
    }
  }

  /// معالجة تأجيل المهمة
  void _handleSnoozeTask(String taskId, String actionId) async {
    try {
      // الحصول على مدة التأجيل من الإعدادات بدلاً من actionId
      final snoozeMinutes = _getSnoozeMinutes();
      final snoozeDuration = Duration(minutes: snoozeMinutes);
      
      // إلغاء الإشعار الحالي أولاً
      await cancelTaskNotification(taskId);
      
      // تشغيل صوت تأكيد التأجيل
      SystemSound.play(SystemSoundType.click);
      
      // حفظ معلومات التأجيل في SharedPreferences
      _saveTaskToSnooze(taskId, snoozeMinutes);
      
      // جدولة إشعار جديد بعد مدة التأجيل
      _scheduleSnoozeNotification(taskId, snoozeDuration);
      
      // إظهار رسالة تأجيل
      _showInfoMessage('تم تأجيل المهمة بنجاح');
      
      print('تم تأجيل المهمة: $taskId لـ ${snoozeMinutes} دقيقة');
      
      // لا نحتاج لتسجيل تأجيل الإشعار في السجل
      
    } catch (e) {
      print('خطأ في معالجة تأجيل المهمة: $e');
      // في حالة الخطأ، احفظ المهمة للتعامل معها لاحقاً
      _saveTaskToSnooze(taskId, _getSnoozeMinutes());
      
      // تسجيل الخطأ في سجل الإشعارات (بدون await)
      NotificationLogService.addQuickLog(
        title: 'خطأ في تأجيل إشعار',
        description: 'فشل في تأجيل إشعار المهمة: $taskId - $e',
        type: NotificationLogType.error,
        taskId: taskId,
      );
    }
  }

  /// جدولة إشعار التأجيل (دالة عامة)
  Future<void> scheduleSnoozeNotification(String taskId, int snoozeMinutes) async {
    try {
      final snoozeDuration = Duration(minutes: snoozeMinutes);
      await _scheduleSnoozeNotification(taskId, snoozeDuration);
      print('✅ تم جدولة إشعار التأجيل للمهمة $taskId بعد $snoozeMinutes دقيقة');
    } catch (e) {
      print('❌ خطأ في جدولة إشعار التأجيل: $e');
    }
  }

  /// جدولة إشعار التأجيل (دالة داخلية)
  Future<void> _scheduleSnoozeNotification(String taskId, Duration snoozeDuration) async {
    try {
      final scheduledTime = tz.TZDateTime.now(tz.local).add(snoozeDuration);
      
      // الحصول على معلومات المهمة من Provider إذا كان متاحاً
      String taskTitle = 'تذكير المهمة';
      String taskDescription = 'تذكير مهم: يرجى إنجاز مهامك في الوقت المحدد';
      
      if (_container != null) {
        try {
          final todos = _container!.read(todoListProvider);
          final task = todos.firstWhere((todo) => todo.id == taskId);
          taskTitle = task.title;
          taskDescription = task.description ?? 'تذكير مهم: يرجى إنجاز مهامك في الوقت المحدد';
        } catch (e) {
          print('لم يتم العثور على المهمة في Provider: $e');
        }
      }
      
      // إنشاء الأزرار التفاعلية المحسنة مع ألوان مميزة بدون contextual
      List<AndroidNotificationAction> actions = [
        AndroidNotificationAction(
          'complete_task',
          '✅ إتمام المهمة',
          titleColor: const Color(0xFF4CAF50), // لون أخضر للإتمام
          showsUserInterface: true,
        ),
      ];

      // إضافة زر التأجيل الواحد مع المدة الديناميكية ولون مميز
      final snoozeMinutes = _getSnoozeMinutes();
      print('إنشاء إشعار تأجيل - مدة التأجيل: $snoozeMinutes دقيقة');
      actions.add(
        AndroidNotificationAction(
          'snooze_task',
          '⏰ تأجيل $snoozeMinutes دقيقة',
          titleColor: const Color(0xFFFF9800), // لون برتقالي للتأجيل
          showsUserInterface: true,
        ),
      );

      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        ongoing: true, // إشعار مستمر - لا يمكن إزالته بالسحب
        autoCancel: false, // لا يختفي تلقائياً
        fullScreenIntent: true, // يظهر على الشاشة الكاملة
        enableVibration: true,
        playSound: true,
        sound: null, // استخدام الصوت الافتراضي
        color: const Color(0xFF2196F3), // لون أزرق للإشعار
        ledColor: const Color(0xFF2196F3), // لون LED أزرق
        ledOnMs: 1000,
        ledOffMs: 500,
        vibrationPattern: Int64List.fromList([0, 1000, 500, 1000, 500, 1000]),
        additionalFlags: Int32List.fromList([4, 32]), // insistent + no_clear
        actions: actions,
        category: AndroidNotificationCategory.alarm, // تصنيف الإشعار كتنبيه
        visibility: NotificationVisibility.public, // مرئي على شاشة القفل
        showWhen: true,
        when: DateTime.now().millisecondsSinceEpoch,
        timeoutAfter: null, // لا يوجد timeout للإشعار
        tag: 'persistent_task_$taskId', // علامة مميزة للإشعار
        colorized: true, // تفعيل التلوين
        ticker: 'تذكير مهمة', // نص التمرير
        onlyAlertOnce: false, // تنبيه مستمر
        silent: false, // ليس صامت
        usesChronometer: false,
        showProgress: false,
        maxProgress: 0,
        progress: 0,
        indeterminate: false,
        styleInformation: const BigTextStyleInformation(
          '',
          htmlFormatBigText: true,
          contentTitle: '',
          htmlFormatContentTitle: true,
          summaryText: 'تذكير مهم: لا تنسى إنجاز مهامك المهمة',
          htmlFormatSummaryText: true,
        ),
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // استخدام معرف ثابت ومميز للإشعار المؤجل
      final notificationId = _getNotificationId(taskId);
      print('🔧 معرف الإشعار المؤجل: $notificationId');

      await _notifications.zonedSchedule(
        notificationId,
        taskTitle,
        taskDescription,
        scheduledTime,
        details,
        payload: taskId,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );

      print('تم جدولة إشعار التأجيل لـ ${snoozeDuration.inMinutes} دقيقة');
      
      // تسجيل نجاح جدولة التأجيل في السجل
      await NotificationLogService.addQuickLog(
        title: 'جدولة إشعار تأجيل',
        description: 'تم جدولة إشعار تأجيل لـ ${snoozeDuration.inMinutes} دقيقة',
        type: NotificationLogType.info,
        taskId: taskId,
      );
    } catch (e) {
      print('خطأ في جدولة إشعار التأجيل: $e');
      
      // تسجيل الخطأ في سجل الإشعارات
      await NotificationLogService.addQuickLog(
        title: 'خطأ في جدولة إشعار التأجيل',
        description: 'فشل في جدولة إشعار التأجيل: $e',
        type: NotificationLogType.error,
        taskId: taskId,
      );
    }
  }

  /// معالجة النقر العادي على الإشعار
  void _handleTaskTap(String taskId) {
    try {
      print('تم النقر على إشعار المهمة: $taskId');
      
      // تسجيل النقر في السجل
      NotificationLogService.addQuickLog(
        title: 'نقر على إشعار',
        description: 'تم النقر على إشعار المهمة: $taskId',
        type: NotificationLogType.info,
        taskId: taskId,
      );
      
      // حفظ المهمة المطلوب فتحها في SharedPreferences
      _saveTaskToOpen(taskId);
      
      // فتح تفاصيل المهمة باستخدام callback أو الطريقة العادية
      if (_onTaskTapped != null) {
        _onTaskTapped!(taskId);
        print('تم فتح تفاصيل المهمة باستخدام callback: $taskId');
      } else {
        _openTaskDetails(taskId);
      }
    } catch (e) {
      print('خطأ في معالجة النقر على الإشعار: $e');
      
      // تسجيل الخطأ في السجل
      NotificationLogService.addQuickLog(
        title: 'خطأ في النقر على الإشعار',
        description: 'فشل في معالجة النقر على إشعار المهمة: $taskId - $e',
        type: NotificationLogType.error,
        taskId: taskId,
      );
      
      // في حالة الخطأ، احفظ المهمة للتعامل معها لاحقاً
      _saveTaskToOpen(taskId);
    }
  }

  /// فتح تفاصيل المهمة
  void _openTaskDetails(String taskId) {
    try {
      if (_container != null) {
        // الحصول على المهمة من TodoProvider
        final todos = _container!.read(todoListProvider);
        final task = todos.firstWhere((todo) => todo.id == taskId);
        
        // تعيين المهمة المحددة
        _container!.read(selectedTodoProvider.notifier).state = task;
        
        print('تم فتح تفاصيل المهمة: ${task.title}');
      } else {
        print('Container غير متاح لفتح تفاصيل المهمة');
      }
    } catch (e) {
      print('خطأ في فتح تفاصيل المهمة: $e');
    }
  }


  /// إظهار رسالة نجاح
  void _showSuccessMessage(String message) {
    print('✅ $message');
    // TODO: يمكن استخدام SnackBar أو Toast هنا
  }

  /// إظهار رسالة معلومات
  void _showInfoMessage(String message) {
    print('ℹ️ $message');
    // TODO: يمكن استخدام SnackBar أو Toast هنا
  }

  /// حفظ المهمة المطلوب إتمامها في SharedPreferences
  Future<void> _saveTaskToComplete(String taskId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('task_to_complete', taskId);
      await prefs.setString('action_type', 'complete');
      print('تم حفظ المهمة المطلوب إتمامها: $taskId');
    } catch (e) {
      print('خطأ في حفظ المهمة المطلوب إتمامها: $e');
    }
  }

  /// حفظ المهمة المطلوب تأجيلها في SharedPreferences
  Future<void> _saveTaskToSnooze(String taskId, int snoozeMinutes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('task_to_snooze', taskId);
      await prefs.setInt('snooze_minutes', snoozeMinutes);
      await prefs.setString('action_type', 'snooze');
      print('تم حفظ المهمة المطلوب تأجيلها: $taskId لـ $snoozeMinutes دقيقة');
    } catch (e) {
      print('خطأ في حفظ المهمة المطلوب تأجيلها: $e');
    }
  }

  /// حفظ المهمة المطلوب فتحها في SharedPreferences
  Future<void> _saveTaskToOpen(String taskId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('task_to_open', taskId);
      print('تم حفظ المهمة المطلوب فتحها: $taskId');
    } catch (e) {
      print('خطأ في حفظ المهمة المطلوب فتحها: $e');
    }
  }

  /// الحصول على معرف ثابت ومميز للإشعار
  int _getNotificationId(String taskId) {
    // استخدام hash للمهمة مع إضافة prefix لضمان التفرد
    final hash = taskId.hashCode;
    // إضافة رقم ثابت لضمان عدم التداخل مع إشعارات أخرى
    return (hash.abs() % 100000) + 1000; // معرف بين 1000 و 101000
  }

  /// إظهار إشعار تأكيد بسيط ومؤقت
  Future<void> _showConfirmationNotification(String title, String message) async {
    try {
      print('✅ إظهار إشعار تأكيد: $title');
      
      // معرف فريد للإشعار
      final notificationId = DateTime.now().millisecondsSinceEpoch % 100000;
      
      await _notifications.show(
        notificationId,
        title,
        message,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'confirmation_channel',
            'تأكيدات الإجراءات',
            channelDescription: 'إشعارات تأكيد الإجراءات',
            importance: Importance.high, // أهمية عالية لضمان الظهور
            priority: Priority.high, // أولوية عالية
            autoCancel: true,
            enableVibration: true, // تفعيل الاهتزاز
            playSound: true, // تفعيل الصوت
            color: const Color(0xFF4CAF50), // لون أخضر للتأكيد
            ledColor: const Color(0xFF4CAF50),
            ledOnMs: 1000,
            ledOffMs: 500,
            timeoutAfter: 5000, // يختفي بعد 5 ثوان
            fullScreenIntent: false, // لا يظهر على الشاشة الكاملة
            ongoing: false, // ليس مستمر
            showWhen: true,
            when: DateTime.now().millisecondsSinceEpoch,
            styleInformation: const BigTextStyleInformation(
              '',
              htmlFormatBigText: true,
              contentTitle: '',
              htmlFormatContentTitle: true,
              summaryText: 'تم تنفيذ الإجراء بنجاح',
              htmlFormatSummaryText: true,
            ),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
      
      // إغلاق الإشعار تلقائياً بعد 5 ثوان
      Timer(const Duration(seconds: 5), () async {
        try {
          await _notifications.cancel(notificationId);
        } catch (e) {
          print('❌ خطأ في إغلاق إشعار التأكيد: $e');
        }
      });
      
      print('✅ تم إرسال إشعار التأكيد');
    } catch (e) {
      print('❌ خطأ في إرسال إشعار التأكيد: $e');
    }
  }

  /// إظهار إشعار تأكيد إتمام المهمة داخل التطبيق
  Future<void> _showTaskCompletionConfirmation(String taskTitle) async {
    try {
      print('✅ إظهار تأكيد إتمام المهمة: $taskTitle');
      
      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch % 100000, // معرف فريد
        '✅ تم إتمام المهمة',
        'مهمتك "$taskTitle" تمت بنجاح',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'confirmation_channel',
            'تأكيدات الإجراءات',
            channelDescription: 'إشعارات تأكيد الإجراءات داخل التطبيق',
            importance: Importance.low,
            priority: Priority.low,
            autoCancel: true,
            enableVibration: false,
            playSound: false,
            color: const Color(0xFF4CAF50), // لون أخضر للتأكيد
            ledColor: const Color(0xFF4CAF50),
            ledOnMs: 500,
            ledOffMs: 500,
            styleInformation: const BigTextStyleInformation(
              '',
              htmlFormatBigText: true,
              contentTitle: '✅ تم إتمام المهمة',
              htmlFormatContentTitle: true,
              summaryText: 'تم تنفيذ الإجراء بنجاح',
              htmlFormatSummaryText: true,
            ),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: false,
          ),
        ),
      );
      
      print('✅ تم إرسال إشعار تأكيد الإتمام');
    } catch (e) {
      print('❌ خطأ في إرسال إشعار تأكيد الإتمام: $e');
    }
  }

  /// إظهار إشعار تأكيد تأجيل المهمة داخل التطبيق
  Future<void> _showTaskSnoozeConfirmation(String taskTitle, int snoozeMinutes) async {
    try {
      print('⏰ إظهار تأكيد تأجيل المهمة: $taskTitle لـ $snoozeMinutes دقيقة');
      
      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch % 100000, // معرف فريد
        '⏰ تم تأجيل المهمة',
        'مهمتك "$taskTitle" تم تأجيلها لـ $snoozeMinutes دقيقة',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'confirmation_channel',
            'تأكيدات الإجراءات',
            channelDescription: 'إشعارات تأكيد الإجراءات داخل التطبيق',
            importance: Importance.low,
            priority: Priority.low,
            autoCancel: true,
            enableVibration: false,
            playSound: false,
            color: const Color(0xFFFF9800), // لون برتقالي للتأجيل
            ledColor: const Color(0xFFFF9800),
            ledOnMs: 500,
            ledOffMs: 500,
            styleInformation: BigTextStyleInformation(
              '',
              htmlFormatBigText: true,
              contentTitle: '⏰ تم تأجيل المهمة',
              htmlFormatContentTitle: true,
              summaryText: 'سيتم تذكيرك مرة أخرى بعد $snoozeMinutes دقيقة',
              htmlFormatSummaryText: true,
            ),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: false,
          ),
        ),
      );
      
      print('⏰ تم إرسال إشعار تأكيد التأجيل');
    } catch (e) {
      print('❌ خطأ في إرسال إشعار تأكيد التأجيل: $e');
    }
  }

  /// الحصول على خيارات التأجيل المتاحة
  List<Duration> getSnoozeOptions() => _snoozeOptions;

  /// الحصول على تسميات خيارات التأجيل
  List<String> getSnoozeLabels() => _snoozeLabels;

  /// الحصول على حالة الصلاحيات
  Future<Map<String, bool>> getPermissionsStatus() async {
    try {
      final notificationStatus = await permission_handler.Permission.notification.isGranted;
      final scheduleStatus = await permission_handler.Permission.scheduleExactAlarm.isGranted;

      return {
        'notification': notificationStatus,
        'schedule': scheduleStatus,
      };
    } catch (e) {
      print('خطأ في الحصول على حالة الصلاحيات: $e');
      return {
        'notification': false,
        'schedule': false,
      };
    }
  }

  /// فتح إعدادات التطبيق
  Future<void> openAppSettings() async {
    try {
      await permission_handler.openAppSettings();
    } catch (e) {
      print('خطأ في فتح إعدادات التطبيق: $e');
    }
  }

  /// تشغيل صوت الإشعار فقط (للاستخدام في الاختبارات)
  Future<void> playNotificationSoundOnly() async {
    try {
      await _playNotificationSound();
      print('تم تشغيل صوت الإشعار المحسن فقط');
    } catch (e) {
      print('خطأ في تشغيل صوت الإشعار: $e');
    }
  }

  /// اختبار أصوات النظام المحسنة
  Future<void> testOptimizedSystemSounds() async {
    try {
      print('🔊 بدء اختبار أصوات النظام المحسنة...');
      
      // اختبار أصوات متعددة
      for (int i = 0; i < 3; i++) {
        print('اختبار صوت ${i + 1}/3');
        await SystemSound.play(SystemSoundType.alert);
        await Future.delayed(Duration(milliseconds: 300));
      }
      
      // اختبار الاهتزاز
      print('اختبار الاهتزاز...');
      await HapticFeedback.heavyImpact();
      
      print('✅ تم اختبار أصوات النظام المحسنة بنجاح');
    } catch (e) {
      print('❌ خطأ في اختبار أصوات النظام: $e');
    }
  }

  /// إنشاء إشعار محسن يبقى ظاهراً بشكل دائم
  Future<void> _showPersistentNotification({
    required int notificationId,
    required String title,
    required String body,
    required List<AndroidNotificationAction> actions,
    String? taskId,
  }) async {
    try {
      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        ongoing: true, // إشعار مستمر - لا يمكن إزالته بالسحب
        autoCancel: false, // لا يختفي تلقائياً
        fullScreenIntent: true, // يظهر على الشاشة الكاملة
        enableVibration: true,
        playSound: true,
        sound: null, // استخدام الصوت الافتراضي
        ticker: 'إشعار مهم', // نص التمرير
        color: const Color(0xFF2196F3),
        ledColor: const Color(0xFF2196F3),
        ledOnMs: 1000,
        ledOffMs: 500,
        vibrationPattern: Int64List.fromList([0, 1000, 500, 1000, 500, 1000]),
        additionalFlags: Int32List.fromList([4, 32]), // insistent + no_clear
        actions: actions,
        category: AndroidNotificationCategory.alarm,
        visibility: NotificationVisibility.public,
        showWhen: true,
        when: DateTime.now().millisecondsSinceEpoch,
        timeoutAfter: null, // لا يختفي أبداً
        usesChronometer: false,
        showProgress: false,
        maxProgress: 0,
        progress: 0,
        indeterminate: false,
        onlyAlertOnce: false, // تنبيه مستمر
        silent: false, // ليس صامت
        styleInformation: const BigTextStyleInformation(
          '',
          htmlFormatBigText: true,
          contentTitle: '',
          htmlFormatContentTitle: true,
          summaryText: 'إشعار مستمر - لن يختفي إلا عند التفاعل مع الأزرار',
          htmlFormatSummaryText: true,
        ),
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        notificationId,
        title,
        body,
        details,
        payload: taskId,
      );

      print('تم عرض إشعار مستمر محسن: $title');
      
      // تسجيل نجاح الإشعار في السجل
      await NotificationLogService.addQuickLog(
        title: 'إشعار مستمر محسن',
        description: 'تم عرض إشعار مستمر بنجاح: $title',
        type: NotificationLogType.info,
        taskId: taskId,
        taskTitle: title,
      );
    } catch (e) {
      print('خطأ في عرض الإشعار المستمر المحسن: $e');
      
      // تسجيل الخطأ في سجل الإشعارات
      await NotificationLogService.addQuickLog(
        title: 'خطأ في الإشعار المستمر',
        description: 'فشل في عرض الإشعار المستمر المحسن: $title - $e',
        type: NotificationLogType.error,
        taskId: taskId,
        taskTitle: title,
      );
    }
  }


  /// تسجيل الأخطاء في سجل الإشعارات بطريقة موحدة
  Future<void> _logError(String title, String description, String? taskId, String? taskTitle) async {
    try {
      await NotificationLogService.addQuickLog(
        title: title,
        description: description,
        type: NotificationLogType.error,
        taskId: taskId,
        taskTitle: taskTitle,
      );
    } catch (e) {
      print('خطأ في تسجيل الخطأ في السجل: $e');
    }
  }

  /// تسجيل المعلومات في سجل الإشعارات بطريقة موحدة
  Future<void> _logInfo(String title, String description, String? taskId, String? taskTitle) async {
    try {
      await NotificationLogService.addQuickLog(
        title: title,
        description: description,
        type: NotificationLogType.info,
        taskId: taskId,
        taskTitle: taskTitle,
      );
    } catch (e) {
      print('خطأ في تسجيل المعلومات في السجل: $e');
    }
  }

  /// اختبار إشعار مستمر - يبقى ظاهراً حتى التفاعل معه
  Future<void> testOngoingNotification() async {
    final actions = <AndroidNotificationAction>[
      AndroidNotificationAction(
        'complete_task',
        '✅ إتمام المهمة',
        titleColor: const Color(0xFF4CAF50),
        showsUserInterface: true,
      ),
      AndroidNotificationAction(
        'snooze_task',
        '⏰ تأجيل 5 دقائق',
        titleColor: const Color(0xFFFF9800),
        showsUserInterface: true,
      ),
    ];

    await _showPersistentNotification(
      notificationId: 888888,
      title: 'اختبار الإشعار المستمر',
      body: 'هذا إشعار مستمر يبقى ظاهراً حتى تتفاعل مع الأزرار أدناه. جرب الضغط على الأزرار لترى كيف يعمل.',
      actions: actions,
      taskId: 'test_task',
    );
  }


  /// اختبار إشعار بسيط للتحقق من عمل النظام
  Future<void> testSimpleNotification() async {
    try {
      await _notifications.show(
        999999, // معرف ثابت للاختبار
        'اختبار الإشعارات',
        'هذا إشعار تجريبي بسيط لاختبار عمل الإشعارات',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'test_channel',
            'اختبار الإشعارات',
            channelDescription: 'قناة اختبار الإشعارات',
            importance: Importance.high,
            priority: Priority.high,
            autoCancel: true,
            enableVibration: true,
            playSound: true,
          ),
        ),
      );
      
      print('تم إرسال إشعار بسيط للاختبار');
      
      // تسجيل نجاح الاختبار في السجل
      await _logInfo(
        'اختبار إشعار بسيط',
        'تم إرسال إشعار بسيط للاختبار بنجاح',
        'test_simple',
        'اختبار الإشعارات',
      );
    } catch (e) {
      print('خطأ في اختبار الإشعار البسيط: $e');
      
      // تسجيل الخطأ في السجل
      await _logError(
        'خطأ في اختبار الإشعار البسيط',
        'فشل في إرسال إشعار بسيط للاختبار: $e',
        'test_simple',
        'اختبار الإشعارات',
      );
    }
  }

  /// اختبار إشعار مستمر محسن - يبقى ظاهراً حتى التفاعل معه
  Future<void> testPersistentNotification() async {
    try {
      final actions = <AndroidNotificationAction>[
        AndroidNotificationAction(
          'complete_task',
          '✅ إتمام المهمة',
          titleColor: const Color(0xFF4CAF50),
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'snooze_task',
          '⏰ تأجيل 5 دقائق',
          titleColor: const Color(0xFFFF9800),
          showsUserInterface: true,
        ),
      ];

      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'test_persistent_channel',
        'اختبار الإشعارات المستمرة',
        channelDescription: 'قناة اختبار الإشعارات المستمرة',
        importance: Importance.max,
        priority: Priority.high,
        ongoing: true, // إشعار مستمر
        autoCancel: false, // لا يختفي تلقائياً
        fullScreenIntent: true, // يظهر على الشاشة الكاملة
        enableVibration: true,
        playSound: true,
        sound: null,
        ticker: 'اختبار مستمر',
        color: const Color(0xFF2196F3),
        ledColor: const Color(0xFF2196F3),
        ledOnMs: 1000,
        ledOffMs: 500,
        vibrationPattern: Int64List.fromList([0, 1000, 500, 1000, 500, 1000]),
        additionalFlags: Int32List.fromList([4, 32]), // insistent + no_clear
        actions: actions,
        category: AndroidNotificationCategory.alarm,
        visibility: NotificationVisibility.public,
        showWhen: true,
        when: DateTime.now().millisecondsSinceEpoch,
        timeoutAfter: null, // لا يختفي أبداً
        onlyAlertOnce: false, // تنبيه مستمر
        silent: false, // ليس صامت
        styleInformation: const BigTextStyleInformation(
          '',
          htmlFormatBigText: true,
          contentTitle: 'اختبار الإشعار المستمر المحسن',
          htmlFormatContentTitle: true,
          summaryText: 'إشعار مستمر - لن يختفي إلا عند التفاعل مع الأزرار',
          htmlFormatSummaryText: true,
        ),
      );

      final NotificationDetails details = NotificationDetails(
        android: androidDetails,
      );

      await _notifications.show(
        777777, // معرف فريد للاختبار المستمر
        'اختبار الإشعار المستمر المحسن',
        'هذا إشعار مستمر محسن يبقى ظاهراً على الشاشة حتى تتفاعل مع الأزرار أدناه',
        details,
        payload: 'test_persistent',
      );
      
      print('تم إرسال إشعار مستمر محسن للاختبار');
      
      // تسجيل نجاح الاختبار في السجل
      await _logInfo(
        'اختبار إشعار مستمر محسن',
        'تم إرسال إشعار مستمر محسن للاختبار بنجاح',
        'test_persistent',
        'اختبار الإشعار المستمر المحسن',
      );
    } catch (e) {
      print('خطأ في اختبار الإشعار المستمر المحسن: $e');
      
      // تسجيل الخطأ في السجل
      await _logError(
        'خطأ في اختبار الإشعار المستمر المحسن',
        'فشل في إرسال إشعار مستمر محسن للاختبار: $e',
        'test_persistent',
        'اختبار الإشعار المستمر المحسن',
      );
    }
  }

}


