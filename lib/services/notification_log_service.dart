import 'package:hive/hive.dart';
import '../models/notification_log_model.dart';

/// خدمة إدارة سجل الإشعارات
class NotificationLogService {
  static const String _boxName = 'notification_logs';
  static Box<NotificationLogModel>? _box;

  /// تهيئة الخدمة
  static Future<void> init() async {
    try {
      _box = await Hive.openBox<NotificationLogModel>(_boxName);
      print('تم تهيئة خدمة سجل الإشعارات بنجاح');
    } catch (e) {
      print('خطأ في تهيئة خدمة سجل الإشعارات: $e');
    }
  }

  /// الحصول على صندوق البيانات
  static Box<NotificationLogModel> get box {
    if (_box == null) {
      throw Exception('خدمة سجل الإشعارات غير مهيأة');
    }
    return _box!;
  }

  /// إضافة سجل جديد
  static Future<void> addLog(NotificationLogModel log) async {
    try {
      await box.put(log.id, log);
      print('تم إضافة سجل إشعار: ${log.title}');
    } catch (e) {
      print('خطأ في إضافة سجل إشعار: $e');
    }
  }

  /// إضافة سجل سريع
  static Future<void> addQuickLog({
    required String title,
    required String description,
    required NotificationLogType type,
    String? taskId,
    String? taskTitle,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final log = NotificationLogModel.create(
        title: title,
        description: description,
        type: type,
        taskId: taskId,
        taskTitle: taskTitle,
        metadata: metadata,
      );
      await addLog(log);
    } catch (e) {
      print('خطأ في إضافة سجل سريع: $e');
    }
  }

  /// الحصول على جميع السجلات
  static List<NotificationLogModel> getAllLogs() {
    try {
      return box.values.toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // الأحدث أولاً
    } catch (e) {
      print('خطأ في الحصول على السجلات: $e');
      return [];
    }
  }

  /// الحصول على السجلات حسب النوع
  static List<NotificationLogModel> getLogsByType(NotificationLogType type) {
    try {
      return box.values
          .where((log) => log.type == type)
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      print('خطأ في الحصول على السجلات حسب النوع: $e');
      return [];
    }
  }

  /// الحصول على السجلات غير المقروءة
  static List<NotificationLogModel> getUnreadLogs() {
    try {
      return box.values
          .where((log) => !log.isRead)
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      print('خطأ في الحصول على السجلات غير المقروءة: $e');
      return [];
    }
  }

  /// الحصول على السجلات حسب المهمة
  static List<NotificationLogModel> getLogsByTask(String taskId) {
    try {
      return box.values
          .where((log) => log.taskId == taskId)
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      print('خطأ في الحصول على السجلات حسب المهمة: $e');
      return [];
    }
  }

  /// الحصول على السجلات في فترة زمنية
  static List<NotificationLogModel> getLogsInRange(DateTime start, DateTime end) {
    try {
      return box.values
          .where((log) => 
              log.timestamp.isAfter(start) && 
              log.timestamp.isBefore(end))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      print('خطأ في الحصول على السجلات في الفترة الزمنية: $e');
      return [];
    }
  }

  /// الحصول على السجلات اليوم
  static List<NotificationLogModel> getTodayLogs() {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      return getLogsInRange(startOfDay, endOfDay);
    } catch (e) {
      print('خطأ في الحصول على سجلات اليوم: $e');
      return [];
    }
  }

  /// الحصول على السجلات هذا الأسبوع
  static List<NotificationLogModel> getThisWeekLogs() {
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final startOfWeekDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      final endOfWeek = startOfWeekDay.add(const Duration(days: 7));
      return getLogsInRange(startOfWeekDay, endOfWeek);
    } catch (e) {
      print('خطأ في الحصول على سجلات هذا الأسبوع: $e');
      return [];
    }
  }

  /// تحديث حالة القراءة
  static Future<void> markAsRead(String logId) async {
    try {
      final log = box.get(logId);
      if (log != null) {
        final updatedLog = log.copyWith(isRead: true);
        await box.put(logId, updatedLog);
        print('تم تحديث حالة القراءة للسجل: $logId');
      }
    } catch (e) {
      print('خطأ في تحديث حالة القراءة: $e');
    }
  }

  /// تحديث جميع السجلات كمقروءة
  static Future<void> markAllAsRead() async {
    try {
      final logs = box.values.toList();
      for (final log in logs) {
        if (!log.isRead) {
          final updatedLog = log.copyWith(isRead: true);
          await box.put(log.id, updatedLog);
        }
      }
      print('تم تحديث جميع السجلات كمقروءة');
    } catch (e) {
      print('خطأ في تحديث جميع السجلات: $e');
    }
  }

  /// حذف سجل
  static Future<void> deleteLog(String logId) async {
    try {
      await box.delete(logId);
      print('تم حذف السجل: $logId');
    } catch (e) {
      print('خطأ في حذف السجل: $e');
    }
  }

  /// حذف جميع السجلات
  static Future<void> deleteAllLogs() async {
    try {
      await box.clear();
      print('تم حذف جميع السجلات');
    } catch (e) {
      print('خطأ في حذف جميع السجلات: $e');
    }
  }

  /// حذف السجلات القديمة (أكثر من 30 يوم)
  static Future<void> deleteOldLogs() async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final oldLogs = box.values
          .where((log) => log.timestamp.isBefore(thirtyDaysAgo))
          .toList();
      
      for (final log in oldLogs) {
        await box.delete(log.id);
      }
      
      print('تم حذف ${oldLogs.length} سجل قديم');
    } catch (e) {
      print('خطأ في حذف السجلات القديمة: $e');
    }
  }

  /// الحصول على إحصائيات السجلات
  static Map<String, int> getLogStatistics() {
    try {
      final logs = box.values.toList();
      final stats = <String, int>{};
      
      // إحصائيات حسب النوع
      for (final type in NotificationLogType.values) {
        stats[type.arabicLabel] = logs.where((log) => log.type == type).length;
      }
      
      // إحصائيات إضافية
      stats['إجمالي السجلات'] = logs.length;
      stats['السجلات غير المقروءة'] = logs.where((log) => !log.isRead).length;
      stats['سجلات اليوم'] = getTodayLogs().length;
      stats['سجلات هذا الأسبوع'] = getThisWeekLogs().length;
      
      return stats;
    } catch (e) {
      print('خطأ في الحصول على إحصائيات السجلات: $e');
      return {};
    }
  }

  /// البحث في السجلات
  static List<NotificationLogModel> searchLogs(String query) {
    try {
      final lowerQuery = query.toLowerCase();
      return box.values
          .where((log) => 
              log.title.toLowerCase().contains(lowerQuery) ||
              log.description.toLowerCase().contains(lowerQuery) ||
              (log.taskTitle?.toLowerCase().contains(lowerQuery) ?? false))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      print('خطأ في البحث في السجلات: $e');
      return [];
    }
  }

  /// تصدير السجلات إلى JSON
  static List<Map<String, dynamic>> exportLogs() {
    try {
      return box.values.map((log) => log.toMap()).toList();
    } catch (e) {
      print('خطأ في تصدير السجلات: $e');
      return [];
    }
  }

  /// استيراد السجلات من JSON
  static Future<void> importLogs(List<Map<String, dynamic>> logs) async {
    try {
      for (final logMap in logs) {
        final log = NotificationLogModel.fromMap(logMap);
        await box.put(log.id, log);
      }
      print('تم استيراد ${logs.length} سجل');
    } catch (e) {
      print('خطأ في استيراد السجلات: $e');
    }
  }

  /// إغلاق الخدمة
  static Future<void> close() async {
    try {
      await _box?.close();
      _box = null;
      print('تم إغلاق خدمة سجل الإشعارات');
    } catch (e) {
      print('خطأ في إغلاق خدمة سجل الإشعارات: $e');
    }
  }
}
