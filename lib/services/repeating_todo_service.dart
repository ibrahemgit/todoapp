import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo_model.dart';
import '../providers/todo_provider.dart';
import 'enhanced_notification_service.dart';
import 'notification_log_service.dart';
import '../models/notification_log_model.dart';

/// خدمة إدارة المهام المتكررة الذكية
class RepeatingTodoService {
  static final RepeatingTodoService _instance = RepeatingTodoService._internal();
  factory RepeatingTodoService() => _instance;
  RepeatingTodoService._internal();

  final EnhancedNotificationService _notificationService = EnhancedNotificationService();
  Timer? _dailyCheckTimer;
  ProviderContainer? _container;

  /// تهيئة الخدمة
  void initialize(ProviderContainer container) {
    _container = container;
    _startDailyCheck();
    print('تم تهيئة خدمة المهام المتكررة');
  }

  /// بدء فحص يومي للمهام المتكررة
  void _startDailyCheck() {
    // إلغاء المؤقت السابق إذا كان موجوداً
    _dailyCheckTimer?.cancel();
    
    // حساب الوقت حتى منتصف الليل التالي
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final timeUntilMidnight = tomorrow.difference(now);
    
    // جدولة الفحص الأول
    _dailyCheckTimer = Timer(timeUntilMidnight, () {
      _checkAndCreateRepeatingTodos();
      _startDailyCheck(); // إعادة جدولة الفحص التالي
    });
    
    print('تم جدولة فحص المهام المتكررة لـ ${timeUntilMidnight.inHours} ساعة');
  }

  /// فحص وإنشاء المهام المتكررة
  Future<void> _checkAndCreateRepeatingTodos() async {
    try {
      if (_container == null) return;
      
      final todos = _container!.read(todoListProvider);
      final now = DateTime.now();
      
      for (final todo in todos) {
        if (todo.isRepeating && todo.repeatingType != null) {
          await _processRepeatingTodo(todo, now);
        }
      }
      
      print('تم فحص المهام المتكررة بنجاح');
    } catch (e) {
      print('خطأ في فحص المهام المتكررة: $e');
      
      // تسجيل الخطأ
      await NotificationLogService.addQuickLog(
        title: 'خطأ في فحص المهام المتكررة',
        description: 'فشل في فحص المهام المتكررة: $e',
        type: NotificationLogType.error,
      );
    }
  }

  /// معالجة مهمة متكررة واحدة
  Future<void> _processRepeatingTodo(TodoModel todo, DateTime now) async {
    try {
      // التحقق من أن المهمة مكتملة
      if (todo.status != TodoStatus.completed) return;
      
      // التحقق من أن المهمة مكتملة اليوم
      if (todo.completedAt == null) return;
      
      final completedDate = DateTime(
        todo.completedAt!.year,
        todo.completedAt!.month,
        todo.completedAt!.day,
      );
      
      final today = DateTime(now.year, now.month, now.day);
      
      // إذا لم تكن مكتملة اليوم، لا نحتاج لإنشاء نسخة جديدة
      if (!completedDate.isAtSameMomentAs(today)) return;
      
      // حساب التاريخ التالي للمهمة
      final nextDate = _calculateNextRepeatingDate(todo, now);
      if (nextDate == null) return;
      
      // إنشاء المهمة الجديدة
      await _createNextRepeatingTodo(todo, nextDate);
      
    } catch (e) {
      print('خطأ في معالجة المهمة المتكررة ${todo.title}: $e');
    }
  }

  /// حساب التاريخ التالي للمهمة المتكررة
  DateTime? _calculateNextRepeatingDate(TodoModel todo, DateTime now) {
    if (todo.repeatingType == null) return null;
    
    final baseDate = todo.dueDate ?? todo.reminderTime ?? now;
    
    switch (todo.repeatingType!) {
      case RepeatingType.daily:
        return baseDate.add(const Duration(days: 1));
      case RepeatingType.weekly:
        return baseDate.add(const Duration(days: 7));
      case RepeatingType.monthly:
        return DateTime(
          baseDate.year,
          baseDate.month + 1,
          baseDate.day,
          baseDate.hour,
          baseDate.minute,
        );
      case RepeatingType.yearly:
        return DateTime(
          baseDate.year + 1,
          baseDate.month,
          baseDate.day,
          baseDate.hour,
          baseDate.minute,
        );
    }
  }

  /// إنشاء المهمة المتكررة التالية
  Future<void> _createNextRepeatingTodo(TodoModel originalTodo, DateTime nextDate) async {
    try {
      if (_container == null) return;
      
      // إنشاء المهمة الجديدة
      final newTodo = TodoModel(
        title: originalTodo.title,
        description: originalTodo.description,
        priority: originalTodo.priority,
        status: TodoStatus.pending,
        dueDate: originalTodo.dueDate != null ? nextDate : null,
        reminderTime: originalTodo.reminderTime != null 
            ? DateTime(
                nextDate.year,
                nextDate.month,
                nextDate.day,
                originalTodo.reminderTime!.hour,
                originalTodo.reminderTime!.minute,
              )
            : null,
        isRepeating: true,
        repeatingType: originalTodo.repeatingType,
        tags: List.from(originalTodo.tags),
      );
      
      // إضافة المهمة الجديدة
      await _container!.read(todoListProvider.notifier).addTodo(newTodo);
      
      // تسجيل الحدث
      await NotificationLogService.addQuickLog(
        title: 'تم إنشاء مهمة متكررة',
        description: 'تم إنشاء نسخة جديدة من المهمة المتكررة: ${originalTodo.title}',
        type: NotificationLogType.taskCreated,
        taskId: newTodo.id,
        taskTitle: newTodo.title,
        metadata: {
          'originalTaskId': originalTodo.id,
          'repeatingType': originalTodo.repeatingType?.name,
          'nextDate': nextDate.toIso8601String(),
        },
      );
      
      print('تم إنشاء مهمة متكررة جديدة: ${newTodo.title}');
      
    } catch (e) {
      print('خطأ في إنشاء المهمة المتكررة: $e');
      
      // تسجيل الخطأ
      await NotificationLogService.addQuickLog(
        title: 'خطأ في إنشاء مهمة متكررة',
        description: 'فشل في إنشاء مهمة متكررة: ${originalTodo.title} - $e',
        type: NotificationLogType.error,
        taskId: originalTodo.id,
        taskTitle: originalTodo.title,
      );
    }
  }

  /// معالجة إتمام مهمة متكررة
  Future<void> handleRepeatingTodoCompletion(TodoModel todo) async {
    try {
      if (!todo.isRepeating || todo.repeatingType == null) return;
      
      // تسجيل إتمام المهمة المتكررة
      await NotificationLogService.addQuickLog(
        title: 'تم إتمام مهمة متكررة',
        description: 'تم إتمام المهمة المتكررة: ${todo.title}',
        type: NotificationLogType.taskCompleted,
        taskId: todo.id,
        taskTitle: todo.title,
        metadata: {
          'repeatingType': todo.repeatingType?.name,
          'completedAt': DateTime.now().toIso8601String(),
        },
      );
      
      // إظهار إشعار تأكيد للمهمة المتكررة
      await _showRepeatingTodoCompletionNotification(todo);
      
    } catch (e) {
      print('خطأ في معالجة إتمام المهمة المتكررة: $e');
    }
  }

  /// إظهار إشعار تأكيد للمهمة المتكررة
  Future<void> _showRepeatingTodoCompletionNotification(TodoModel todo) async {
    try {
      String nextOccurrenceText = '';
      
      if (todo.repeatingType != null) {
        switch (todo.repeatingType!) {
          case RepeatingType.daily:
            nextOccurrenceText = 'ستظهر مرة أخرى غداً';
            break;
          case RepeatingType.weekly:
            nextOccurrenceText = 'ستظهر مرة أخرى الأسبوع القادم';
            break;
          case RepeatingType.monthly:
            nextOccurrenceText = 'ستظهر مرة أخرى الشهر القادم';
            break;
          case RepeatingType.yearly:
            nextOccurrenceText = 'ستظهر مرة أخرى السنة القادمة';
            break;
        }
      }
      
      await _notificationService.showTaskNotification(
        taskTitle: 'تم إتمام مهمة متكررة',
        taskDescription: '${todo.title}\n$nextOccurrenceText',
        taskId: 'repeating_completion_${todo.id}',
        taskDueTime: DateTime.now(),
      );
      
    } catch (e) {
      print('خطأ في إظهار إشعار المهمة المتكررة: $e');
    }
  }

  /// الحصول على إحصائيات المهام المتكررة
  Map<String, int> getRepeatingTodoStats() {
    if (_container == null) return {};
    
    final todos = _container!.read(todoListProvider);
    final repeatingTodos = todos.where((todo) => todo.isRepeating).toList();
    
    return {
      'total': repeatingTodos.length,
      'daily': repeatingTodos.where((todo) => todo.repeatingType == RepeatingType.daily).length,
      'weekly': repeatingTodos.where((todo) => todo.repeatingType == RepeatingType.weekly).length,
      'monthly': repeatingTodos.where((todo) => todo.repeatingType == RepeatingType.monthly).length,
      'yearly': repeatingTodos.where((todo) => todo.repeatingType == RepeatingType.yearly).length,
      'completed': repeatingTodos.where((todo) => todo.status == TodoStatus.completed).length,
      'pending': repeatingTodos.where((todo) => todo.status == TodoStatus.pending).length,
    };
  }

  /// إيقاف الخدمة
  void dispose() {
    _dailyCheckTimer?.cancel();
    _dailyCheckTimer = null;
    print('تم إيقاف خدمة المهام المتكررة');
  }

  /// إعادة تشغيل الفحص اليدوي
  Future<void> manualCheck() async {
    await _checkAndCreateRepeatingTodos();
  }
}
