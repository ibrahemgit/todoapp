import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_log_service.dart';
import '../models/notification_log_model.dart';

/// خدمة خلفية لضمان عمل الإشعارات حتى عند إغلاق التطبيق
class BackgroundService {
  static final BackgroundService _instance = BackgroundService._internal();
  factory BackgroundService() => _instance;
  BackgroundService._internal();

  Timer? _keepAliveTimer;
  bool _isRunning = false;

  /// بدء الخدمة الخلفية
  Future<void> startBackgroundService() async {
    try {
      if (_isRunning) return;
      
      print('🔄 بدء الخدمة الخلفية...');
      
      // بدء مؤقت للحفاظ على الخدمة نشطة
      _startKeepAliveTimer();
      
      _isRunning = true;
      print('✅ تم بدء الخدمة الخلفية بنجاح');
      
    } catch (e) {
      print('❌ خطأ في بدء الخدمة الخلفية: $e');
    }
  }

  /// إيقاف الخدمة الخلفية
  Future<void> stopBackgroundService() async {
    try {
      if (!_isRunning) return;
      
      print('🛑 إيقاف الخدمة الخلفية...');
      
      _keepAliveTimer?.cancel();
      _keepAliveTimer = null;
      
      _isRunning = false;
      print('✅ تم إيقاف الخدمة الخلفية');
      
    } catch (e) {
      print('❌ خطأ في إيقاف الخدمة الخلفية: $e');
    }
  }

  /// بدء مؤقت للحفاظ على الخدمة نشطة
  void _startKeepAliveTimer() {
    _keepAliveTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _performKeepAlive();
    });
  }

  /// تنفيذ عمليات الحفاظ على الخدمة نشطة
  Future<void> _performKeepAlive() async {
    try {
      // تحديث timestamp في SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('background_service_last_activity', DateTime.now().millisecondsSinceEpoch);
      
      // تسجيل النشاط في السجل
      await NotificationLogService.addQuickLog(
        title: 'الخدمة الخلفية نشطة',
        description: 'الخدمة الخلفية تعمل بشكل طبيعي',
        type: NotificationLogType.info,
      );
      
      print('💓 الخدمة الخلفية نشطة');
    } catch (e) {
      print('❌ خطأ في الحفاظ على الخدمة: $e');
    }
  }



  /// معالجة المهام المحفوظة من الخدمة الخلفية
  Future<void> processBackgroundTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // معالجة المهام المكتملة من Android
      final completedTasks = prefs.getStringList('completed_from_background') ?? [];
      if (completedTasks.isNotEmpty) {
        print('📋 معالجة ${completedTasks.length} مهمة مكتملة من الخلفية');
        // سيتم معالجة هذه المهام في TodoProvider
        await prefs.remove('completed_from_background');
      }
      
      // معالجة المهام المؤجلة من Android
      final snoozedTasks = prefs.getStringList('snoozed_from_background') ?? [];
      if (snoozedTasks.isNotEmpty) {
        print('📋 معالجة ${snoozedTasks.length} مهمة مؤجلة من الخلفية');
        await prefs.remove('snoozed_from_background');
      }
      
      // معالجة المهمة المطلوب فتحها من Android
      final taskToOpen = prefs.getString('task_to_open_from_background');
      if (taskToOpen != null) {
        print('📋 معالجة مهمة مطلوب فتحها: $taskToOpen');
        await prefs.remove('task_to_open_from_background');
      }
      
    } catch (e) {
      print('❌ خطأ في معالجة المهام من الخلفية: $e');
    }
  }

  /// التحقق من حالة الخدمة الخلفية
  bool get isRunning => _isRunning;

  /// تنظيف الموارد
  void dispose() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = null;
    _isRunning = false;
  }
}
